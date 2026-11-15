# Mars Outpost Commander

[![Godot Engine](https://img.shields.io/badge/Godot-4.7.2--stable-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org)
[![NASA Space Apps Challenge](https://img.shields.io/badge/NASA%20Space%20Apps-2026-0b3d91?logo=nasa&logoColor=white)](https://www.spaceappschallenge.org/)
[![Status](https://img.shields.io/badge/Status-Foundations%20%26%20Architecture-orange)](#development-status)

**Mars Outpost Commander** is a 2D base-management strategy game developed for the **NASA Space Apps Challenge 2026**. 

In the game, players assume the role of an Outpost Commander tasked with building, expanding, and sustaining humanity's first permanent research and settlement facility on the hostile surface of Mars. Players must manage life-critical resources, expand specialized habitat modules, and respond to unpredictable environmental hazards such as solar radiation storms, habitat breaches, and power grid failures.

---

## Game Overview

- **Genre:** 2D Base-Management / Survival Strategy
- **Target Platform:** Desktop (Windows, macOS, Linux) & Web (HTML5)
- **Viewport Resolution:** 1280x720 (16:9 Landscape, responsive canvas scaling)
- **Engine:** Godot Engine 4.7.2 (GL Compatibility renderer)
- **Language:** GDScript 2.0 (strongly typed)

### Core Pillars
1. **Critical Resource Management:** Balance four life-sustaining systems:
   - **Oxygen (O₂):** Atmospheric scrubbers, MOXIE electrolysis, pressure maintenance.
   - **Energy (Power):** Solar arrays, RTGs/fission reactors, battery reserves during dust storms.
   - **Food:** Hydroponic greenhouses, nutritional rationing, water recycling.
   - **Radiation Protection:** Regolith shielding, active magnetic deflection, colonist radiation exposure limits.
2. **Dynamic Emergency Events:** Real-time crisis response to solar particle events, micrometeroid impacts, system leaks, and equipment brownouts.
3. **Decisive Command Choices:** High-stakes decision cards where commanders weigh risk, material expenditure, and human survival.

---

## Project Structure

The project follows a clean, modular structure designed for scalability and clean separation of concerns:

```text
mars-outpost-commander/
├── assets/                  # Raw and imported media assets
│   ├── audio/              # Sound effects, ambient sounds, music
│   ├── fonts/              # Typography and TTF/OTF resources
│   ├── sprites/            # Base modules, Martian terrain, UI sprites
│   └── ui/                 # UI skins, icons, borders, HUD elements
├── scenes/                  # Godot scene trees (.tscn)
│   ├── base/               # Outpost grid, modules, structures
│   ├── events/             # Crisis dialogs, decision popups, notifications
│   ├── main/               # Main menu, game bootstrap, game loop wrapper
│   └── ui/                 # HUD, resource meters, command overlays
├── scripts/                 # Source code (GDScript)
│   ├── data/               # Static models, data schemas, structures
│   ├── managers/           # Autoload singletons (GameManager, ResourceManager, etc.)
│   └── systems/            # Subsystem logic (PowerGrid, LifeSupport, EventEngine)
├── resources/               # Godot custom Resource instances (.tres)
├── data/                    # Data tables, event definitions (JSON/Resource)
├── docs/                    # Game design & architectural documentation
│   ├── GAME_DESIGN.md
│   └── TECHNICAL_ARCHITECTURE.md
├── addons/
│   └── godot_ai/           # Godot AI MCP integration & editor helpers
└── project.godot            # Engine project configuration
```

---

## Documentation

Detailed design specifications, scientific baselines, and architectural guidelines are available in the [`docs/`](file:///c:/Users/hp%20pavilion/Documents/mars-outpost-commander/docs/) folder:
- [**Scientific References & Systems Validation (`docs/SCIENTIFIC_REFERENCES.md`)**](file:///c:/Users/hp%20pavilion/Documents/mars-outpost-commander/docs/SCIENTIFIC_REFERENCES.md): Full empirical NASA citations (BVAD, MOXIE, Curiosity RAD, Mars Fact Sheet) and mapping of real physical units to game metrics.
- [**Game Design Document (`docs/GAME_DESIGN.md`)**](file:///c:/Users/hp%20pavilion/Documents/mars-outpost-commander/docs/GAME_DESIGN.md): Detailed mechanics, resource economy, hazard systems, and victory/defeat criteria.
- [**Technical Architecture (`docs/TECHNICAL_ARCHITECTURE.md`)**](file:///c:/Users/hp%20pavilion/Documents/mars-outpost-commander/docs/TECHNICAL_ARCHITECTURE.md): Decoupled state and simulation architecture, UI controllers, and deterministic progression.

---

## Development Status

| Milestone | Status | Description |
| :--- | :---: | :--- |
| **Milestone 1: Project Foundations** | **Completed** | Directory structure, project configuration, and architectural blueprints. |
| **Milestone 2: Playable MVP & Telemetry** | **Completed** | Full playable 10-Sol prototype with resource drain, triage actions, and crisis cards. |
| **Milestone 3: Scientific Verification** | **Completed** | NASA BVAD, MOXIE, and Curiosity RAD cross-referencing and validation documentation. |
| **Milestone 4: Extended Survival & Visuals** | *Planned* | 50-Sol progression, diurnal night cycle, custom sci-fi sprites, and audio. |
| **Milestone 5: NASA API Integration** | *Planned* | Live InSight weather data and DONKI space weather telemetry feeds. |
| **Milestone 6: Submission & Polish** | *Planned* | Final balance tuning, HTML5 web export, and challenge presentation. |

---

## Educational Disclaimer & NASA Attribution

*Mars Outpost Commander* is an educational student project created for the **NASA Space Apps Challenge 2026**.  
Scientific parameters are sourced from publicly available NASA research and published planetary science literature.  
This project is an independent hackathon entry and is **not officially affiliated with, certified by, or endorsed by NASA or the United States Government**.

---

## Getting Started

### Prerequisites
- [Godot Engine 4.7.2](https://godotengine.org/download) (Standard build, 64-bit).

### Running in Godot
1. Clone or download this repository.
2. Open the Godot Project Manager.
3. Click **Import** and browse to `mars-outpost-commander/project.godot`.
4. Open the project in the Godot Editor.
