# Mars Outpost Commander

[![Godot Engine](https://img.shields.io/badge/Godot-4.7.2--stable-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org)
[![NASA Space Apps Challenge](https://img.shields.io/badge/NASA%20Space%20Apps-2026-0b3d91?logo=nasa&logoColor=white)](https://www.spaceappschallenge.org/)
[![Status](https://img.shields.io/badge/Status-Completed%20MVP%20%26%20NASA%20Integrated-brightgreen)](#development-status)

**Mars Outpost Commander** is a 2D base-management survival strategy game developed for the **NASA Space Apps Challenge 2026**. 

In the game, players assume the role of an Outpost Commander tasked with sustaining humanity's first research and settlement facility in the Jezero Crater on Mars. Players manage life-critical resources, triage operational maintenance, respond to unpredictable environmental emergencies, and track real-time space weather data directly integrated from NASA's Space Weather Database of Notifications, Knowledge, Information (DONKI).

---

## Game Overview

- **Genre:** 2D Base-Management / Survival Strategy
- **Implemented Build Platform:** Windows Desktop (x86_64 standalone executable & PCK)
- **Planned Target Platforms:** Web (HTML5), Linux, macOS
- **Viewport Resolution:** 1280x720 (16:9 Landscape, responsive canvas scaling)
- **Engine:** Godot Engine 4.7.2 (GL Compatibility renderer)
- **Language:** GDScript 2.0 (strongly typed)

### Implemented Core Pillars
1. **Critical Resource Management:** Balance four life-sustaining systems on a normalized 0–100 scale:
   - **Oxygen (O₂):** Atmospheric extraction via MOXIE solid oxide electrolysis ($2\text{CO}_2 \rightarrow 2\text{CO} + \text{O}_2$), air scrubbers, and habitat pressure maintenance. *(Note: Perseverance's flight MOXIE was a technology demonstrator producing $\approx 12\text{ g } O_2/\text{hr}$; full-scale $2\text{–}3\text{ kg/hr}$ industrial plants are sized for Mars Ascent Vehicle rocket propellant oxidizer, not crew breathing requirements of $\sim 3.58\text{ kg/Sol}$ for 4 crew per NASA BVAD).*
   - **Energy (Power):** Photovoltaic solar array maintenance, battery storage, and power distribution during dust accumulation.
   - **Food (Rations):** Hydroponic greenhouse harvesting, nutrient recycling, and caloric rationing for the 4-person crew.
   - **Radiation Protection:** Sintered regolith shielding, crew exposure limits, and active magnetic deflectors *(explicitly a fictional gameplay abstraction; not established Mars radiation-protection technology)*.
2. **Operational Triage Actions:** Execute tactical commands each Sol to manage resource trade-offs:
   - *Generate Oxygen (Run MOXIE):* Electrolyzes ambient Martian atmospheric CO₂ into breathable O₂ (-12 Energy, +14 Oxygen).
   - *Clean Solar Arrays:* Crew EVA clears abrasive dust from photovoltaic fields (-8 Food, -6 Rad Shield, +14 Energy).
   - *Harvest Hydroponics:* Cycles nutrient baths and grow lights to yield fresh rations (-10 Energy, -8 Oxygen, +12 Food).
   - *Reinforce Radiation Shielding:* Robotic rovers 3D-sinter basaltic regolith tiles onto habitat shells (-10 Energy, +10 Radiation Shield).
3. **Dynamic Emergency Events:** Real-time crisis response with 3-way triage cards:
   - *Habitat Oxygen Leak:* Seal breaches in low-pressure ambient atmosphere (Emergency EVA Patch, Bulkhead Quarantine, or Overdrive MOXIE).
   - *Solar Storm (Coronal Mass Ejection):* Space weather triage response (Regolith Bunker Lockdown, Overcharge Magnetic Deflectors [fictional abstraction], or Maintain Surface Operations — noting that while modeled CME shock propagation poses potential radiation risks, actual surface exposure depends on particle energy, atmospheric shielding, and habitat protection, distinct from simulated gameplay mechanics).
   - *Power Grid Substation Failure:* Charged dust short-circuit (Reroute Fuel Cells, Emergency Reactor Vent, or Controlled Rolling Blackout).
4. **NASA DONKI Space Weather Telemetry Integration:**
   - Real-time heliospheric observations queried from the NASA Community Coordinated Modeling Center (CCMC) DONKI API and Moon to Mars (M2M) Space Weather Office.
   - Evaluates WSA-ENLIL 3D solar wind numerical simulations for Mars-directed CME shock impacts, arrival timestamps, and plasma propagation speeds.
   - Resilient 3-tier fallback architecture: **LIVE** (asynchronous non-blocking HTTP), **CACHED** (local `user://space_weather_cache.json`), and **OFFLINE** (bundled snapshot of 34 authentic NASA CCMC events in `res://data/space_weather_fallback.json`).
   - Dynamically enriches in-game emergency incident alerts with authentic CME observations and modeled WSA-ENLIL shock arrival projections, distinguishing model predictions from simulated gameplay triage.

---

## Project Structure

The project follows a clean, modular structure designed for scalability and separation of concerns:

```text
mars-outpost-commander/
├── assets/                  # Raw and imported media assets (audio, fonts, sprites, ui)
├── scenes/                  # Godot scene trees (.tscn)
│   ├── base/               # Outpost layout and module templates
│   ├── events/             # Crisis dialogs and popup overlays
│   └── main/               # Main playable game scene (main.tscn, main.gd)
├── scripts/                 # Source code (GDScript 2.0)
│   ├── data/               # Simulation state and rules (game_state.gd)
│   ├── managers/           # System singletons and global handlers
│   └── systems/            # Subsystem logic:
│       ├── emergency_system.gd            # Crisis event rolls and triage outcomes
│       └── nasa_space_weather_service.gd  # NASA CCMC DONKI integration & WSA-ENLIL parser
├── data/                    # Bundled datasets
│   └── space_weather_fallback.json        # 34 authentic NASA CCMC DONKI CME records
├── docs/                    # Game design & scientific documentation
│   ├── GAME_DESIGN.md
│   ├── SCIENTIFIC_REFERENCES.md
│   └── TECHNICAL_ARCHITECTURE.md
├── Mars Outpost Commander.exe         # Compiled Windows 64-bit standalone executable
├── Mars Outpost Commander.pck         # Game data package
├── project.godot            # Engine project configuration
└── export_presets.cfg       # Export presets configuration
```

---

## Documentation

Comprehensive design specifications, empirical NASA benchmarks, and architectural documentation are available in the [`docs/`](docs/) folder:
- [**Scientific References & Systems Validation (`docs/SCIENTIFIC_REFERENCES.md`)**](docs/SCIENTIFIC_REFERENCES.md): Full empirical NASA citations (BVAD, MOXIE, Curiosity RAD, Mars Fact Sheet) and mapping of physical units to normalized gameplay mechanics.
- [**Game Design Document (`docs/GAME_DESIGN.md`)**](docs/GAME_DESIGN.md): Detailed game loop mechanics, resource economy, emergency event framework, and victory/defeat conditions.
- [**Technical Architecture (`docs/TECHNICAL_ARCHITECTURE.md`)**](docs/TECHNICAL_ARCHITECTURE.md): Decoupled state and simulation architecture, NASA space weather telemetry pipeline, and resilient fallback models.

> [!NOTE]
> **Key Scientific Baselines & MOXIE Clarification:**  
> - **NASA BVAD (2022):** 4 crew require $\sim 3.58\text{ kg } O_2/\text{Sol}$ ($0.895\text{ kg/CM-d}$) and $\sim 3.20\text{ kg dry matter/Sol}$ ($0.800\text{ kg/CM-d}$).  
> - **MOXIE Scale Clarification:** The flight MOXIE instrument on Perseverance demonstrated up to $\approx 12\text{ g } O_2/\text{hr}$. Projected full-scale $2\text{–}3\text{ kg } O_2/\text{hr}$ plants are engineered to produce $25\text{–}30\text{ metric tons of LOX}$ to launch the Mars Ascent Vehicle (MAV), not for immediate crew breathing.  
> - **Radiation & Deflectors:** Curiosity RAD surface dosimetry measured an average of $0.64 \pm 0.12\text{ mSv/day}$. Active magnetic deflectors and 0–100 integer bars are simplified fictional gameplay abstractions for strategic triage.

---

## Development Status

| Milestone | Status | Description |
| :--- | :---: | :--- |
| **Milestone 1: Project Foundations** | **Completed** | Clean directory structure, Godot 4.7.2 configuration, and architectural blueprints. |
| **Milestone 2: Playable MVP & Telemetry** | **Completed** | Playable 10-Sol survival loop with resource drain, triage actions, and crisis decision cards. |
| **Milestone 3: Scientific Verification** | **Completed** | Full NASA BVAD, MOXIE, Curiosity RAD, and Mars Fact Sheet scientific validation document. |
| **Milestone 4: NASA DONKI Telemetry Integration** | **Completed** | Live NASA CCMC DONKI CME telemetry, WSA-ENLIL Mars trajectory shock analysis, and 3-tier resilience. |
| **Milestone 5: Extended Survival & Visuals** | *Planned* | 50-Sol progression, diurnal night cycle, custom sci-fi sprites, and ambient audio. |
| **Milestone 6: Web Export & Cross-Platform** | *Planned* | HTML5 web export and multi-platform distribution. |

---

## Educational Disclaimer & NASA Attribution

*Mars Outpost Commander* is an educational student project created for the **NASA Space Apps Challenge 2026**.  
Scientific parameters are sourced from publicly available NASA research and published planetary science literature.  
This project is an independent hackathon entry and is **not officially affiliated with, certified by, or endorsed by NASA or the United States Government**.

---

## Getting Started

### Running the Pre-Compiled Windows Build
The repository includes a pre-compiled Windows 64-bit standalone build ready to play:
1. Clone or download this repository.
2. Launch `Mars Outpost Commander.exe` directly (ensure `Mars Outpost Commander.pck` is in the same directory).

### Running in Godot Engine
1. Download and install [Godot Engine 4.7.2](https://godotengine.org/download) (64-bit).
2. Open the Godot Project Manager.
3. Click **Import** and select `mars-outpost-commander/project.godot`.
4. Open the project and press **F5** (or click **Play**) to launch the main scene (`res://scenes/main/main.tscn`).
