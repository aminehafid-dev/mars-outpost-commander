# Game Design Document: Mars Outpost Commander

**Project:** Mars Outpost Commander  
**Target:** NASA Space Apps Challenge 2026  
**Engine:** Godot Engine 4.7.2  
**Genre:** 2D Base-Management / Survival Strategy  
**Perspective:** Top-Down / Isometric 2D Outpost Management  

---

## 1. Executive Summary & Vision

### 1.1 Premise
Humanity has established its first permanent research outpost in the Jezero Crater on Mars. As the **Outpost Commander**, the player bears ultimate responsibility for keeping the crew alive, balancing resource production, expanding scientific infrastructure, and withstanding the brutal Martian environment.

### 1.2 Core Experience
- **Realistic Survival Pressure:** Mars is unforgiving. Every breath of air, calorie of food, watt of electricity, and millimeter of regolith shielding must be accounted for.
- **Tense Triage Decisions:** When emergencies strike, commanders cannot save everything. Every decision requires balancing immediate crew safety against long-term outpost survival.
- **Scientific Authenticity:** Inspired by NASA Artemis and Mars Exploration architectures (In-Situ Resource Utilization, MOXIE atmospheric oxygen extraction, Kilopower fission reactors, regolith radiation mitigation). All assumptions are cross-referenced with NASA BVAD (2022), Mars 2020 MOXIE flight telemetry, Curiosity RAD dosimetry, and the NASA Mars Fact Sheet. Full data mappings are documented in [SCIENTIFIC_REFERENCES.md](SCIENTIFIC_REFERENCES.md).

---

## 2. Core Game Loop

```
+-----------------------------------------------------------+
|                     OUTPOST PLANNING                      |
|  * Review status meters, grid efficiency, module upkeep   |
|  * Queue module construction or upgrades                  |
+-----------------------------+-----------------------------+
                              |
                              v
+-----------------------------------------------------------+
|                   SIMULATION TICK (SOL)                   |
|  * Resource production (solar, MOXIE, hydroponics)        |
|  * Resource consumption (colonist life support, heating)  |
|  * Environmental fluctuations (day/night, temperature)    |
+-----------------------------+-----------------------------+
                              |
                              v
+-----------------------------------------------------------+
|                 DYNAMIC EVENT / EMERGENCY                 |
|  * Solar particle event, oxygen line leak, power fault    |
|  * Commander alerted with multi-choice crisis card        |
+-----------------------------+-----------------------------+
                              |
                              v
+-----------------------------------------------------------+
|                  DECISION TRIAGE & RESOLUTION             |
|  * Allocate emergency power, deploy repair crew, evacuate |
|  * Consequences applied to resources, modules, & crew     |
+-----------------------------+-----------------------------+
                              |
                              v
+-----------------------------------------------------------+
|                   SURVIVAL EVALUATION                     |
|  * Check win/loss thresholds                              |
|  * Progress to next Sol or trigger end-game state         |
+-----------------------------------------------------------+
```

---

## 3. The Four Vital Resources

The game centers on four interconnected resource pillars. Neglecting any one of them leads directly to catastrophe. Note that all in-game resource values (0–100) are normalized fictional gameplay units designed for strategic balance, not direct NASA measurements (see [SCIENTIFIC_REFERENCES.md](SCIENTIFIC_REFERENCES.md)):

| Resource | Primary Source | Primary Drain | Critical Failure State | Scientific Reality & Scale Context |
| :--- | :--- | :--- | :--- | :--- |
| **Oxygen (O₂)** | MOXIE atmospheric extractors, Algae scrubbers | Crew respiration, module pressure upkeep, hull breaches | **Asphyxiation:** Rapid colonist incapacitation within turns. | 4 crew require $\sim 3.58\text{ kg } O_2/\text{Sol}$ (NASA BVAD: $0.895\text{ kg/CM-d}$). MOXIE demonstrated up to $\sim 12\text{ g/hr}$ on Perseverance; 2–3 kg/hr industrial plants are sized for MAV rocket oxidizer, not crew breathing. |
| **Energy (Power)** | Photovoltaic arrays, RTG / Kilopower reactors, battery banks | Life support machinery, water pumps, heaters, active shields | **Outpost Freeze:** Blackout disables O₂ generation and heating, causing cascading failures. | Mars surface insolation is $\sim 586.2\text{ W/m}^2$ ($\sim 43\%$ Earth). Atmospheric dust settling ($0.1\%\text{–}0.3\%/\text{Sol}$) requires EVA dust mitigation. |
| **Food (Rations)** | Hydroponic greenhouses, emergency survival rations | Daily crew consumption, crop spoilage | **Malnutrition:** Colonist efficiency collapses, morale tanks, starvation deaths. | 4 crew require $\sim 3.20\text{ kg dry solids/Sol}$ and $\sim 51.1\text{ MJ/Sol}$ (NASA BVAD: $0.800\text{ kg/CM-d}$, $12.778\text{ MJ/CM-d}$). Hydroponic harvest O2 cost abstracts water treatment & microbial aeration. |
| **Radiation Protection** | Sintered regolith shielding, electromagnetic deflector coils | Background GCR degradation, deflector power drain, solar flux | **Lethal Exposure:** Crew radiation sickness, incapacitation, mission abort. | Normalized fictional integrity score (0–100). Curiosity RAD measured an average surface GCR dose-equivalent rate of $0.64 \pm 0.12\text{ mSv/day}$ (absorbed dose $\approx 0.21\text{ mGy/day}$ in silicon); SPE radiation enhancements vary widely with event intensity, spectrum, and shielding. |

### 3.1 Resource Interdependencies
- **Power powers Life Support:** Without continuous Energy, Oxygen generators halt.
- **Oxygen & Energy support Food:** Greenhouses consume power and aeration to sustain crops and water recycling loops. (In physical botany, plants produce net O₂; the game abstracts life support loop aeration costs into harvest requirements).
- **Radiation Protection requires Power or Mass:** Active shields consume wattage; passive regolith shields require robotic construction labor.
- **Crew enables Maintenance:** Incapacitated crew from radiation or starvation cannot repair oxygen leaks or power substations.

---

## 4. Base Infrastructure & Modules

The base is built upon a modular grid layout on the Martian surface:

1. **Command Central (Core Module):**
   - Houses the command uplink, sensor telemetry, and primary emergency controls.
2. **Life Support Node:**
   - Houses MOXIE CO₂-to-O₂ conversion units, nitrogen balancing, and air filtration scrubbers.
3. **Power Station & Battery Depot:**
   - Manages photovoltaic field output, Kilopower reactor throttling, and backup batteries for Martian night.
4. **Hydroponic Greenhouse:**
   - Cultivates spirulina algae and engineered crops under LED grow lights using recycled graywater.
5. **Radiation Storm Shelter (The Vault):**
   - Deeply buried under 3 meters of compacted Martian regolith; provides high radiation attenuation during solar storms.
6. **Maintenance & Drone Bay:**
   - Houses automated rovers capable of repairing external modules during hazardous weather conditions.

---

## 5. Dynamic Emergencies & Event System

Random and conditional emergencies test the player's readiness:

### 5.1 Solar Storm (Solar Particle Event)
- **Description:** A coronal mass ejection or solar proton event transiently elevates radiation flux across the Martian surface.
- **Impact:** Particle flux increases above the quiescent GCR background, modulated by event energy spectrum, duration, and atmospheric column depth. External solar arrays experience dust and particle degradation, while unshielded surface crew face acute exposure hazards, making sheltering in the regolith vault an operational priority.
- **Commander Choices:**
  - *Option A (Safe Triage):* Order all crew into the Regolith Shelter. Outpost productivity drops for 24 hours, but crew remains unharmed.
  - *Option B (Overcharge Active Shields):* Divert battery power to electromagnetic deflector coils. Crew remains at stations, but electrical grid risks brownout.
  - *Option C (Ride it Out):* Ignore warning to maintain surface tasks. Causes severe radiation damage to unshielded outpost systems and crew.

### 5.2 Oxygen Leak (Micrometeorite / Seal Failure)
- **Description:** A seal micro-fracture in Module Bravo causes atmospheric decompression into the low-pressure Martian environment ($\sim 610\text{ Pa}$).
- **Impact:** Outpost oxygen reserves vent rapidly into the ambient $CO_2$ thin atmosphere.
- **Commander Choices:**
  - *Option A (Bulkhead Quarantine):* Isolate and seal damaged Module Bravo. Halts the leak immediately, but vents the remaining compartment gas.
  - *Option B (Emergency EVA Patch):* Dispatch an engineering EVA crew to weld the exterior breach. Consumes energy and exposes crew to surface hazards.
  - *Option C (Overdrive MOXIE):* Burn heavy energy reserves to overcharge solid oxide electrolysis scrubbers and compensate for pressure drop.

### 5.3 Power Grid Overload / Substation Failure
- **Description:** Fine, electrostatically charged Martian dust accumulates in primary substation transformers, causing an explosive short circuit.
- **Impact:** Outpost power distribution collapses, disabling heating and life support scrubbers.
- **Commander Choices:**
  - *Option A (Reroute Fuel Cells):* Tap into liquid oxygen chemical fuel cells to jumpstart the grid (consumes $O_2$ reserves).
  - *Option B (Emergency Reactor Vent):* Dump reactor containment heat into radiators to bypass the short circuit (degrades radiation containment).
  - *Option C (Controlled Rolling Blackouts):* Let non-essential science and heating bays go dark until dust settles (costs heavy energy).

### 5.4 NASA Space-Weather Telemetry Integration
- **Real-Time Space Weather Telemetry:** The outpost's telemetry system integrates real-world data from the NASA Community Coordinated Modeling Center (CCMC) DONKI web service and the Moon to Mars (M2M) Space Weather Office.
- **WSA-ENLIL Mars Trajectory Modeling:** The telemetry dashboard detects whether solar wind simulations project a direct/glancing impact on Mars or general heliospheric activity.
- **Dynamic Narrative Adaptation:** When a Solar Storm crisis triggers (e.g. Sol 6 or random events), the incident alert dynamically integrates authentic CME telemetry (activity ID, solar wind velocity in km/s, arrival timestamp), creating authentic scientific immersion while preserving gameplay balance.
- **Scientific Labeling:** Telemetry displays status badges (`[LIVE]`, `[CACHED]`, `[OFFLINE]`) and clear attribution disclaimers, distinguishing authentic solar observations from normalized gameplay damage triage.

---

## 6. Player Decision Framework

Every emergency and strategic dilemma presents choices rated by:
- **Resource Cost:** Direct expenditure of O₂, Power, Food, or Radiation Shielding.
- **Triage Trade-off:** Immediate mitigation vs. long-term resource depletion.
- **Crew Safety:** Protecting the 4 active crew members who maintain base systems.

Decisions are non-reversible and compound over successive Martian Sols.

---

## 7. Victory & Defeat Conditions

### 7.1 Defeat Conditions (Game Over)
- **Life Support Failure:** Any of the four vital resources (Oxygen, Energy, Food, or Radiation Protection) reaches zero ($0.0$).
- **Failure Modes:**
  - *Oxygen = 0:* Outpost Asphyxiation.
  - *Energy = 0:* Total Blackout (life support freezes in subzero Martian ambient).
  - *Food = 0:* Famine (rations exhausted).
  - *Radiation = 0:* Lethal Exposure (shielding destroyed, habitat overwhelmed).

### 7.2 Victory / Mission Milestones
- **Phase 2 MVP Milestone (Sol 10 Survival):** Successfully manage outpost resources, sustain all 4 crew members, and survive 10 consecutive Martian Sols including multiple emergency crises.
- **Phase 3 Objective (Sol 50 Survival):** Maintain outpost stability through seasonal Martian dust storms and diurnal temperature swings.
- **Phase 4 Objective (Permanent Self-Sufficiency):** Achieve net-positive ISRU closed-loop recycling and rocket propellant (LOX) production for the Mars Ascent Vehicle (MAV).

---

## 8. NASA Attribution & Non-Endorsement

*Mars Outpost Commander* is an educational game project created for the **NASA Space Apps Challenge 2026**.  
All scientific benchmarks are derived from public NASA exploration reports and peer-reviewed literature as documented in [SCIENTIFIC_REFERENCES.md](SCIENTIFIC_REFERENCES.md).  
This project is an independent submission and is **not affiliated with, certified by, or endorsed by NASA or the United States Government**.
