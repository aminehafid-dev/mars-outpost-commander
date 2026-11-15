# Technical Architecture: Mars Outpost Commander

**Project:** Mars Outpost Commander  
**Engine:** Godot Engine 4.7.2-stable  
**Target Architecture:** Decoupled, Signal-Driven, Data-Oriented 2D Architecture  
**Scripting:** GDScript 2.0 (Strongly Typed)  

---

## 1. Architectural Philosophy

Mars Outpost Commander is designed around three core architectural tenets:
1. **Decoupled Systems via Observer Pattern:** Gameplay systems (Resource, Life Support, Emergency Engine) do not directly manipulate or reference UI nodes. Instead, state transitions publish strongly typed signals through an `EventBus` or dedicated managers.
2. **Data-Driven Configuration:** Modules, events, technologies, and disaster scenarios are defined as custom Godot `Resource` definitions (`.tres`) or structured data tables. The simulation logic operates generically on data rather than hard-coded scene nodes.
3. **Discrete Simulation Tick:** Simulation logic (resource consumption, production, environmental decay) executes on a deterministic logical tick, decoupled from variable rendering frame rates (`_process`).

---

## 2. High-Level Architecture Diagram

```
+---------------------------------------------------------------------------------+
|                                 AUTOLOAD LAYER                                  |
|   +-----------------------+   +---------------------+   +-------------------+   |
|   |      GameManager      |   |      EventBus       |   |    SaveManager    |   |
|   |  (Game state, Sol,    |   |  (Global signal     |   |  (JSON/Save file  |   |
|   |   speed, pause)       |   |   dispatcher)       |   |   serialization)  |   |
|   +-----------------------+   +---------------------+   +-------------------+   |
+---------------------------------------------------------------------------------+
                                       ^
                                       | Signals & Callbacks
                                       v
+---------------------------------------------------------------------------------+
|                               GAMEPLAY SYSTEMS                                  |
|  +---------------------+   +---------------------+   +-----------------------+  |
|  |   ResourceManager   |   |   IncidentManager   |   |     OutpostManager    |  |
|  | - Oxygen, Power,    |   | - Random emergencies|   | - Module placement    |  |
|  |   Food, Radiation   |   | - Event deck triage |   | - Power/pipe routing  |  |
|  | - Production/Drain  |   | - Choice resolution |   | - Grid adjacency      |  |
|  +---------------------+   +---------------------+   +-----------------------+  |
+---------------------------------------------------------------------------------+
                                       |
                   State Updates (Signals via EventBus)
                                       v
+---------------------------------------------------------------------------------+
|                               PRESENTATION (UI)                                 |
|  +---------------------+   +---------------------+   +-----------------------+  |
|  |      HUD View       |   |    Incident Dialog  |   |    Module Inspector   |  |
|  | - Resource bars     |   | - Crisis card popup |   | - Stats & toggles     |  |
|  | - Sol day counter   |   | - Choice buttons    |   | - Upgrade button      |  |
|  +---------------------+   +---------------------+   +-----------------------+  |
+---------------------------------------------------------------------------------+
```

---

## 3. Core Modules & Managers

### 3.1 GameManager (`scripts/managers/game_manager.gd`)
- **Type:** Autoload Singleton.
- **Responsibilities:**
  - Manages high-level game states: `TITLE_SCREEN`, `PLAYING`, `PAUSED`, `CRISIS_PAUSE`, `VICTORY`, `GAME_OVER`.
  - Drives the **Sol Clock** (e.g. 1 Sol = 60 seconds of real-time, scaled by game speed `1x`, `2x`, `3x`).
  - Emits `sol_advanced(current_sol: int)` and `game_state_changed(old_state: int, new_state: int)`.

### 3.2 EventBus (`scripts/managers/event_bus.gd`)
- **Type:** Autoload Singleton.
- **Responsibilities:**
  - Decouples producer systems from consumer UI elements.
  - Typical signals:
    ```gdscript
    signal resource_updated(resource_id: StringName, current_value: float, delta_rate: float, max_capacity: float)
    signal resource_depleted(resource_id: StringName)
    signal incident_triggered(incident: IncidentData)
    signal incident_choice_selected(incident: IncidentData, choice_index: int)
    signal incident_resolved(incident: IncidentData, outcome_description: String)
    signal module_selected(module_instance: Node2D)
    signal alert_broadcast(title: String, message: String, severity: int)
    ```

### 3.3 ResourceManager (`scripts/systems/resource_manager.gd`)
- **Type:** Scene Component / System.
- **Responsibilities:**
  - Tracks the 4 vital resources:
    1. `oxygen` (units)
    2. `energy` (kW / stored kWh)
    3. `food` (rations)
    4. `radiation_shielding` (effective millisievert protection %)
  - Computes global production and consumption balances during every simulation tick.
  - Enforces hard boundaries (clamping between `0.0` and `max_capacity`).
  - Alerts `EventBus` when any resource falls below critical warning thresholds or hits zero.

### 3.4 IncidentManager (`scripts/systems/incident_manager.gd`)
- **Type:** Scene Component / System.
- **Responsibilities:**
  - Evaluates hazard conditions (e.g., probability rolls based on current Sol, environment hazards, and base vulnerability).
  - Instantiates emergency scenarios from `IncidentData` resources.
  - Pauses or slows game simulation while presenting commander choice cards.
  - Applies outcomes (deducting resources, disabling modules, reducing crew health).

### 3.5 OutpostManager (`scripts/systems/outpost_manager.gd`)
- **Type:** Scene Component / System.
- **Responsibilities:**
  - Manages the 2D surface grid coordinate system.
  - Tracks placed base modules, connections, and structural integrity.
  - Aggregates module capabilities (e.g. sum of all solar panel outputs, sum of all life support capacities).

---

## 4. Data-Driven Architecture

All gameplay entities are defined using strongly typed Godot `Resource` classes:

### 4.1 Custom Resource Types (in `scripts/data/`)
1. **`ResourceDefinition.gd` (`class_name ResourceDefinition extends Resource`):**
   - Identifier (`id: StringName`), display name, icon texture, color theme, critical threshold.
2. **`ModuleData.gd` (`class_name ModuleData extends Resource`):**
   - Module ID, category (`LIFE_SUPPORT`, `POWER`, `FOOD`, `SHIELDING`, `UTILITY`).
   - Construction cost, power demand, production outputs, baseline degradation rate.
   - Sprite frames and footprint dimensions (e.g. 2x2 grid cells).
3. **`IncidentData.gd` (`class_name IncidentData extends Resource`):**
   - Unique identifier, title, description, illustration.
   - Severity level (`WARNING`, `CRITICAL`, `CATASTROPHIC`).
   - Array of `IncidentChoice` resources containing choice text, prerequisite checks, and direct outcome modifiers.

```
resources/
├── modules/
│   ├── moxie_generator.tres
│   ├── solar_array.tres
│   ├── hydroponics_bay.tres
│   └── regolith_vault.tres
└── incidents/
    ├── solar_storm.tres
    ├── oxygen_leak.tres
    └── power_substation_failure.tres
```

---

## 5. Simulation Tick Pipeline

To ensure consistent behavior regardless of device frame rate:
1. **Fixed Simulation Step:**
   - A simulation timer triggers a `tick` signal every fixed interval (e.g., $1.0\text{s}$).
2. **Phase Order per Tick:**
   1. *Production Phase:* Collect output from operational modules (Energy, Oxygen, Food).
   2. *Consumption Phase:* Deduct life support requirements for current crew and active modules.
   3. *Environmental Phase:* Apply day/night solar multipliers and environmental degradation.
   4. *State & Threshold Check:* Verify resource levels; trigger warnings if critical.
   5. *Incident Roll:* Check for random or scripted emergency triggers.
   6. *UI Notification:* Dispatch batched update signals through `EventBus`.

---

## 6. Save/Load & State Persistence

### 6.1 Strategy
- Game state persistence uses serialized JSON structured dictionaries saved to `user://saves/save_game.json`.
- Separation of static data (which remains in game resources) from dynamic session state (variable numbers, placed module coordinates, timestamps).

### 6.2 Save State Schema
```json
{
  "version": 1,
  "timestamp": 1794740400,
  "game_meta": {
    "current_sol": 14,
    "elapsed_time": 840.5,
    "difficulty": "standard"
  },
  "resources": {
    "oxygen": { "current": 420.0, "max": 500.0 },
    "energy": { "current": 85.0, "max": 200.0 },
    "food": { "current": 310.0, "max": 400.0 },
    "radiation_shielding": { "current": 78.5, "max": 100.0 }
  },
  "outpost": {
    "modules": [
      {
        "id": "moxie_generator_01",
        "type": "moxie_generator",
        "grid_pos": [4, 5],
        "integrity": 100.0,
        "is_active": true
      }
    ]
  },
  "incidents_history": ["solar_storm_01"]
}
```

---

## 7. Godot 4.7.2 Coding Conventions

- **Strong Static Typing:** All variables, function parameters, and return types must be explicitly typed:
  ```gdscript
  func consume_resource(type: StringName, amount: float) -> bool:
  ```
- **Class Registration:** Meaningful domain models register global names via `class_name`.
- **Node Paths & Lifecycle:**
  - Avoid fragile absolute `NodePath` traversal; use `@export` node references or dependency injection via initializers.
  - Cache node references with `@onready`.
- **UI Independence:** Presentation components connect to `EventBus` signals in `_ready()` and clean up in `_exit_tree()`.

---

## 8. NASA Live Space-Weather Telemetry Architecture

### 8.1 Service Topology
Authentic space weather data is managed by `NasaSpaceWeatherService` (`scripts/systems/nasa_space_weather_service.gd`):
```
+-------------------------------------------------------------+
|               NASA SPACE WEATHER ARCHITECTURE               |
|                                                             |
|   +--------------------------+                              |
|   | NASA Open API / CCMC     |                              |
|   | DONKI CME Web Service    |                              |
|   +--------------------------+                              |
|                |                                            |
|          Asynchronous                                       |
|          HTTPRequest                                        |
|                v                                            |
|   +--------------------------+     Saves     +----------+   |
|   |  NasaSpaceWeatherService | ------------> | user://  |   |
|   |  - Signal dispatcher     |   payload     | cache    |   |
|   |  - WSA-ENLIL parser      | <------------ | file     |   |
|   |  - Fallback coordinator  |  Loads cache  +----------+   |
|   +--------------------------+                              |
|                |                                            |
|                | Signals: data_updated, status_changed      |
|                v                                            |
|   +--------------------------+   Enriches   +-----------+   |
|   | Main UI HUD              | -----------> | Emergency |   |
|   | Space Weather Badge      |   Narrative  | System    |   |
|   | Telemetry Metrics Panel  |              | Narrative |   |
|   +--------------------------+              +-----------+   |
+-------------------------------------------------------------+
```

### 8.2 Three-Tier Resilience Model
1. **Tier 1 (LIVE):** Asynchronous non-blocking HTTP request via Godot `HTTPRequest` querying NASA Open API DONKI (`https://api.nasa.gov/DONKI/CME`) or direct CCMC endpoints with an 8-second timeout.
2. **Tier 2 (CACHED):** If network is interrupted, previously verified payloads stored in `user://space_weather_cache.json` are loaded immediately.
3. **Tier 3 (OFFLINE):** If no user cache exists, the system seamlessly initializes from a bundled snapshot of 34 authentic NASA CCMC events in `res://data/space_weather_fallback.json`.

### 8.3 Mars Trajectory Extraction
The service parses WSA-ENLIL solar wind simulations (`cmeAnalyses` -> `enlilList` -> `impactList`) and filters specifically for `"location": "Mars"`:
- `has_mars_impact`: Distinguishes Mars-directed shocks from general heliospheric CMEs.
- `mars_arrival_time`: Projected UTC arrival timestamp at Martian orbit.
- `speed` & `cme_type`: Solar wind propagation velocity (km/s) and CME morphology classification.

### 8.4 Security & Credentials
- Optional personal API keys are read from `NASA_API_KEY` environment variables or ignored config files (`res://nasa_api_key.txt`, `.env`).
- If no key is configured, the service utilizes NASA's default `DEMO_KEY` or direct endpoints.
- All credential paths are strictly excluded via `.gitignore`, never committed, and never exposed in UI or logs.
