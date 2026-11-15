# Scientific References & Systems Validation: Mars Outpost Commander

**Project:** Mars Outpost Commander  
**Target:** NASA Space Apps Challenge 2026  
**Document Status:** Baseline Verification (Phase 2 MVP)  
**Last Updated:** November 2026  

---

## 1. Executive Summary & Purpose

*Mars Outpost Commander* is a 2D base-management survival simulation developed for the NASA Space Apps Challenge. The game places players in command of humanity's first permanent surface research base in the Jezero Crater ($18.38^\circ\text{N}, 77.58^\circ\text{E}$).

The core simulation is grounded in empirical data from NASA planetary science missions, the NASA Human Research Program, and peer-reviewed aerospace literature.

> [!IMPORTANT]
> **Distinction Between Science and Fictional Gameplay Units:**  
> To create an accessible, responsive strategy experience, real physical values (kilograms of gas, megajoules of energy, millisieverts of radiation) are normalized to an intuitive 0–100 integer telemetry scale. **All in-game resource quantities (e.g., 80 Oxygen, 75 Energy, 70 Food, 65 Radiation Shielding, and daily drains of -8/-8/-8/-6) are normalized fictional gameplay units**, designed for strategic clarity and game loop balance. They are **not** direct NASA engineering measurements or official operational limits. This document explicitly differentiates **empirical NASA scientific measurements** from these **simplified fictional gameplay mechanics**, providing full mathematical transparency and primary source citations.

---

## 2. Primary Scientific Sources & Access Links

Every scientific assumption in *Mars Outpost Commander* is cross-referenced against the following five primary sources:

1. **NASA Life Support Baseline Values and Assumptions Document (BVAD)**  
   - *Citation:* Anderson, M. S., et al., *Life Support Baseline Values and Assumptions Document*, NASA/TP-2015-218570/REV2, National Aeronautics and Space Administration, Lyndon B. Johnson Space Center, Houston, Texas, February 2022.  
   - *Access URL:* [NASA Technical Reports Server (NTRS) - BVAD Rev 2](https://ntrs.nasa.gov/api/citations/20210024855/downloads/BVAD_2.15.22-final.pdf)

2. **NASA Mars 2020 MOXIE Flight Results & Acoustic Telemetry**  
   - *Citation:* Hecht, M., et al., "Mars Oxygen ISRU Experiment (MOXIE) - Overview and In-Situ Demonstration Results," NASA Jet Propulsion Laboratory / Massachusetts Institute of Technology; NASA Science Resources, 2021–2023.  
   - *Access URL:* [NASA Science - The Sound of MOXIE at Work on Mars](https://science.nasa.gov/resource/the-sound-of-moxie-at-work-on-mars/)  
   - *Access URL:* [NASA Mars 2020 Perseverance Science Instruments](https://science.nasa.gov/mission/mars-2020-perseverance/science-instruments/)

3. **NASA Goddard Planetary Fact Sheets (Mars)**  
   - *Citation:* Williams, D. R. (Ed.), *Mars Fact Sheet*, NASA Goddard Space Flight Center, Greenbelt, MD.  
   - *Access URL:* [NASA NSSDC Mars Fact Sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html)

4. **Curiosity Rover Radiation Assessment Detector (RAD) Surface Measurements**  
   - *Citation:* Hassler, D. M., et al., "Mars' Surface Radiation Environment Measured with the Mars Science Laboratory's Curiosity Rover," *Science*, Vol. 343, Issue 6169, 2014.  
   - *Access DOI:* [Science 10.1126/science.1244797](https://www.science.org/doi/10.1126/science.1244797)

5. **NASA InSight & Exploration Rover Photovoltaic Dust Deposition Data**  
   - *Citation:* Lorenz, R. D., et al., "Solar Array Dust Accumulation and Wind Clearing Rates on Mars," *Icarus* / NASA Jet Propulsion Laboratory, 2021–2023.

6. **NASA Community Coordinated Modeling Center (CCMC) DONKI & WSA-ENLIL Modeling**  
   - *Citation:* NASA Space Weather Database of Notifications, Knowledge, Information (DONKI); Moon to Mars (M2M) Space Weather Analysis Office, NASA Goddard Space Flight Center, Greenbelt, MD.  
   - *Access URL:* [NASA CCMC DONKI](https://ccmc.gsfc.nasa.gov/DONKI/)  
   - *Access URL:* [NASA CCMC API Documentation](https://ccmc.gsfc.nasa.gov/DONKI/api/)  
   - *Access URL:* [NASA CCMC Mars CME Scoreboard](https://ccmc.gsfc.nasa.gov/CMESB-Mars/)

---

## 3. Scientific Verification by Subsystem

### 3.1 Crew Metabolic Consumption: Oxygen & Food

#### Measured Scientific Values (NASA BVAD 2022)
According to the NASA BVAD (Section 4.1, Table 4.1 "Nominal Crew Metabolic Influent and Effluent Baselines"):
- **Oxygen Consumption:** **$0.895\text{ kg}$** of $O_2$ per crewmember per day (for an $82.0\text{ kg}$ nominal crewmember performing standard exploration operations).
- **Food Solids Consumption:** **$0.800\text{ kg}$** dry matter per crewmember per day (excluding packaging and rehydration water).
- **Food Energy Requirement:** **$12.778\text{ MJ}$** per crewmember per day ($\approx 3,054\text{ kcal/day}$, corresponding to a continuous metabolic power dissipation of $\approx 148\text{ W}$).

#### Outpost Requirements (4 Crew for 1 Sol)
$$\text{Daily Outpost } O_2 = 4 \times 0.895\text{ kg} = \mathbf{3.58\text{ kg } O_2\text{ / Sol}}$$
$$\text{Daily Outpost Food Solids} = 4 \times 0.800\text{ kg} = \mathbf{3.20\text{ kg dry solids / Sol}}$$
$$\text{Daily Outpost Caloric Intake} = 4 \times 12.778\text{ MJ} = \mathbf{51.11\text{ MJ} \approx 12,216\text{ kcal / Sol}}$$

#### Game Abstraction & Mapping
- *In-Game Metric:* Base daily consumption of **$8.0\text{ units of Oxygen}$** and **$8.0\text{ units of Food}$** per Sol (normalized fictional gameplay units).
- *Normalized Scaling (Educational Heuristic):*  
  $$1\text{ Fictional Unit of Oxygen} \approx 0.448\text{ kg } O_2$$  
  $$1\text{ Fictional Unit of Food} \approx 0.400\text{ kg dry rations} \approx 6.39\text{ MJ } (1,527\text{ kcal})$$
- *Outpost Reserve:* A nominal tank reading of $100\text{ units}$ represents $\sim 44.8\text{ kg of usable oxygen}$ and $\sim 40.0\text{ kg of shelf-stable freeze-dried rations}$, supplying the 4-person crew for approximately $12.5\text{ Sols}$ without replenishment. Note that these are gameplay balance conversions, not NASA specifications.

---

### 3.2 Atmospheric Oxygen Extraction: MOXIE & In-Situ Resource Utilization (ISRU)

#### Measured Scientific Values (NASA Perseverance & MIT)
The **Mars Oxygen ISRU Experiment (MOXIE)** on the Perseverance rover demonstrated solid oxide electrolysis, converting ambient Martian carbon dioxide into oxygen and carbon monoxide:
$$2\text{CO}_2 \xrightarrow{800^\circ\text{C}} 2\text{CO} + \text{O}_2$$

Key empirical benchmarks from NASA operations in Jezero Crater:
- **Demonstrator Scale:** The flight MOXIE instrument is a 17.1-kg technology demonstrator (dimensions $23.9 \times 23.9 \times 30.9\text{ cm}$, approximately car-battery-sized).
- **Measured Yield:** Produced up to **$\approx 12\text{ grams of } O_2\text{ per hour}$** (achieving $12.2\text{ g/hr}$ at peak, double its baseline design requirement of $6\text{ g/hr}$). Over its 16 successful Martian operations (2021–2023), MOXIE produced a total of $122\text{ grams of } O_2$.

#### Industrial-Scale Clarification: Propellant vs. Crew Respiration
> [!IMPORTANT]
> **Correcting the 2–3 kg/hr Scaling Figure:**  
> Studies projecting full-scale Martian oxygen plants of **$2\text{ to } 3\text{ kg } O_2\text{ / hour}$** ($\sim 25\text{–}30\text{ kW}$ continuous power) are **NOT sized for human crew breathing requirements**.  
> - 4 astronauts require only $3.58\text{ kg of } O_2\text{ per full Sol}$ ($\approx 0.15\text{ kg/hour}$).  
> - The massive $2\text{–}3\text{ kg/hour}$ industrial scale is required to produce the **$25\text{ to } 30\text{ metric tons of liquid oxygen (LOX)}$** needed as the oxidizer to launch the **Mars Ascent Vehicle (MAV)** back into orbit.  
> *Mars Outpost Commander* distinguishes between life support oxygen needs and rocket propellant production.

#### Game Abstraction & Mapping
- *In-Game Action:* "Generate Oxygen (Run MOXIE)" draws $12\text{ Energy}$ to generate $+14\text{ Oxygen}$ ($\approx 6.27\text{ kg } O_2$).
- *Fidelity:* Reflects that solid oxide electrolysis is an electro-thermal consumer requiring high electrical input ($\sim 800^\circ\text{C}$ heating and ceramic membrane polarization).

---

### 3.3 Martian Environment: Atmospheric Pressure & Dust

#### Measured Scientific Values (NASA Mars Fact Sheet)
- **Mean Surface Pressure:** **$6.1\text{ mbar}$** ($610\text{ Pa}$, or $0.006\text{ atm}$, approximately $0.6\%$ of Earth's mean sea-level pressure of $1013.25\text{ mbar}$).
- **Seasonal Range:** $4.0\text{ to } 8.7\text{ mbar}$ (due to $25\%\text{ of atmospheric } CO_2$ freezing seasonally onto the polar ice caps).
- **Composition:** $95.1\%\text{ CO}_2$, $2.59\%\text{ N}_2$, $1.94\%\text{ Ar}$, $0.16\%\text{ O}_2$, $0.06\%\text{ CO}$, $0.03\%\text{ H}_2\text{O}$.
- **Surface Density:** $\sim 0.020\text{ kg/m}^3$ (compared to Earth's $1.217\text{ kg/m}^3$).
- **Mean Solar Irradiance:** **$586.2\text{ W/m}^2$** at mean orbital radius ($1.524\text{ AU}$), roughly $43\%$ of Earth's solar constant ($1361\text{ W/m}^2$).
- **Diurnal Cycle (Sol Length):** $24\text{ hours, } 39\text{ minutes, } 35.24\text{ seconds}$ ($1.02749\text{ Earth days}$).

#### Atmospheric Correction in Gameplay
- *Correction:* Earlier prototype drafts referred colloquially to oxygen leaking into the "Martian vacuum". Mars is **not** a vacuum; it has a dynamic, low-pressure $CO_2$ gas envelope that produces winds, dust storms, and convective cooling. All in-game texts have been updated to specify the *"Martian thin atmosphere"*.
- *Dust Deposition Mechanics:* Spirit, Opportunity, and InSight demonstrated that atmospheric dust settles out of the air at rates reducing photovoltaic output by $0.1\%\text{ to } 0.3\%$ per Sol. The game mechanic ("Clean Solar Arrays") requires an EVA commitment to restore array absorption.

---

### 3.4 Radiation Environment: Curiosity RAD & Dosimetry

#### Measured Scientific Values (MSL Curiosity RAD / Hassler et al., 2014)
Surface radiation measurements performed by the Radiation Assessment Detector (RAD) on the Mars Science Laboratory (Curiosity) rover in Gale Crater established the empirical GCR baseline:
- **Galactic Cosmic Rays (GCR) Dose-Equivalent Rate:** An average surface dose-equivalent rate of **$0.64 \pm 0.12\text{ mSv/day}$** ($\approx 234\text{ mSv/year}$) was reported for the first 300 Sols of operations under solar maximum conditions.
- **Galactic Cosmic Rays (GCR) Absorbed Dose Rate:** The physical absorbed dose rate measured directly in silicon (detector B) was **$0.210 \pm 0.040\text{ mGy/day}$** (corresponding to approximately **$0.24\text{ mGy/day}$** in water/tissue).
- **Distinction Between Absorbed Dose and Dose Equivalent:**
  - **Absorbed Dose ($D$, measured in Grays, Gy; $1\text{ Gy} = 1\text{ J/kg}$):** The physical quantity of energy deposited per unit mass of matter or detector by ionizing radiation.
  - **Dose Equivalent ($H$, measured in Sieverts, Sv; $1\text{ Sv} = 1\text{ J/kg} \times Q$):** The absorbed dose weighted by the radiation quality factor $Q(L)$, which accounts for the differing biological severity of cellular damage caused by different particle species. On the surface of Mars, high-LET heavy ions, primary protons, and secondary neutrons generated within the atmosphere and regolith produce an average quality factor of $\langle Q \rangle \approx 3.05 \pm 0.30$, substantially elevating the biological dose equivalent relative to the absorbed physical dose.

#### Solar Particle Events (SPE) & Environmental Variability
Solar Particle Events (SPEs)—triggered by solar flares and coronal mass ejections (CMEs)—intermittently inject high fluxes of energetic protons and ions into the heliosphere. Rather than following a universal multiplier or producing a fixed lethal dose, radiation levels on Mars during an SPE depend on multiple interacting variables:
1. **Event Intensity & Energy Spectrum:** "Hard" proton spectra with high energies ($>100\text{ MeV}$) penetrate deeper into the atmosphere and materials, whereas "soft" low-energy spectra are more easily stopped.
2. **Atmospheric Column Depth:** The Martian atmosphere provides natural passive shielding of approximately $20\text{ g/cm}^2$ of vertical column mass at mean pressure. This column depth varies seasonally ($4.0\text{ to } 8.7\text{ mbar}$ due to $CO_2$ condensation) and with surface topography, modulating the attenuation of incoming charged particles.
3. **Event Duration & Profile:** SPE enhancements typically persist over hours to several days; integrated dose depends on total particle fluence over time.
4. **Habitat Shielding Geometry:** Bulk passive shielding (such as 3 meters of regolith overburden in a dedicated storm vault) and hydrogenous interior materials provide substantial additional attenuation.

In *Mars Outpost Commander*, solar storms represent operational triage dilemmas where commanders must choose whether to halt surface operations and shelter crew in the regolith vault, rather than a deterministic single lethal dose. The simulation strictly distinguishes remote space-weather observations, numerical model predictions, and fictional gameplay triage:
- **Remote Observations & Models vs. In-Situ Particle Measurements:** NASA DONKI coronagraph observations identify CMEs, and WSA-ENLIL simulations model solar wind shock propagation through the inner heliosphere. **Crucially, DONKI CME observations and WSA-ENLIL modeled shock arrivals do not, by themselves, measure or confirm in-situ Solar Energetic Particle (SEP) flux or radiation dose on the Martian surface.** Actual surface exposure depends heavily on incoming particle energy spectrum, atmospheric column depth, and habitat protection geometry. In-situ particle measurements require dedicated surface or orbital instruments (e.g., MSL Curiosity RAD or MAVEN SEP).
- **Incident Alert Veracity:** Emergency alerts never claim that a Class-X flare has reached Jezero Crater unless confirmed by authentic observational data, reflecting that electromagnetic radiation from flares, energetic protons, and CME plasma travel with distinct propagation speeds and heliospheric trajectories across the 1.52 AU baseline.

#### Magnetic Deflection: Fictional Gameplay Abstraction vs. Established Mars Technology
> [!WARNING]
> **Active Magnetic Deflectors Are a Fictional Gameplay Abstraction:**  
> In *Mars Outpost Commander*, players are presented with options to deploy or overcharge active electromagnetic deflectors to mitigate solar storm radiation.  
> **This mechanism is strictly a fictional gameplay abstraction, not established Mars radiation-protection technology.**  
> - **Established Mars Radiation Mitigation:** NASA mission architecture baselines (including NASA-STD-3001, Artemis deep-space habitat studies, and Langley Research Center shielding analyses) rely almost exclusively on **passive mass shielding**: in-situ Martian regolith overburden (such as 3+ meters of sintered basaltic regolith), subsurface lava tube shelters, water storage walls, and hydrogen-rich polymer materials (e.g., polyethylene).  
> - **Active Magnetic Shielding Status:** Active electromagnetic deflection concepts (such as superconducting magnetic coils or artificial mini-magnetospheres) have been explored theoretically in preliminary conceptual research (e.g., NASA NIAC studies). However, they require immense power infrastructure, cryogenic cooling, and massive structural frameworks, and face severe secondary radiation bremsstrahlung scattering risks. They do **not** represent established or operational Mars surface protection technology.

#### Astronaut Radiation Exposure Standards
Astronaut permissible radiation exposure limits are governed by institutional standards (such as **NASA-STD-3001, Technical Standard for Human Health, Medical, and Performance, Volume 1**, and recommendations from the National Council on Radiation Protection and Measurements / NCRP).
- **Context & Risk-Based Standards:** Historically, NASA applied age- and sex-dependent career limits structured around maintaining lifetime radiation-induced cancer risks below a 3% Risk of Exposure-Induced Death (REID) calculated at a 95% confidence interval.
- **Exploration Recommendations:** Recent advisory assessments (such as the 2021 National Academies of Sciences, Engineering, and Medicine review) have evaluated standardized career limit frameworks for long-duration exploration. However, specific operational limits for deep-space Mars missions depend on applicable agency policies, mission profile, solar cycle phase, and mitigation architectures. There is no single universal limit that applies uniformly without operational context.

#### Why "Radiation Shielding Integrity" is a Simplified Fictional Metric
In *Mars Outpost Commander*, the radiation telemetry bar is presented as **"Radiation Shielding (0–100)"** with a baseline daily drain of $-6\text{ fictional units/Sol}$:

> [!NOTE]
> **Mechanic Justification:**  
> In physical reality, a passive bulk shield (such as 3 meters of Martian regolith) does **not** degrade or evaporate daily. What actually changes is:
> 1. The **cumulative biological tissue damage** absorbed by astronauts over time.
> 2. The **operational readiness of active shielding systems** (electromagnetic deflector alignment, automated dust clearing on sensors, seal maintenance).
> 
> Modeling organ-specific biological doses in Sieverts would require complex medical and biophysical sub-simulations. For the MVP, "Radiation Shielding" is simplified into an **Active Defense & Habitat Sintering Buffer (a normalized fictional score)**:
> - The daily $-6\text{ drain}$ represents background cosmic radiation erosion of deflector alignment, structural dusting, and safety margins.
> - Player actions represent 3D-sintering fresh regolith shielding tiles over vulnerable habitat sections.
> - Reaching $0$ represents total shielding compromise, where acute radiation penetrates the habitat and incapacitates the expedition.

---

### 3.5 Botanical / Hydroponic Gas Exchange Simplification

#### Measured Plant Biology Baseline
In terrestrial plant physiology, autotrophic crops in a hydroponic greenhouse consume carbon dioxide ($CO_2$) and water ($H_2O$) via light reactions to synthesize glucose, releasing molecular oxygen as a net byproduct:
$$6\text{CO}_2 + 6\text{H}_2\text{O} + \text{photons} \rightarrow \text{C}_6\text{H}_{12}\text{O}_6 + 6\text{O}_2$$
While plants respire at night (consuming trace $O_2$), an actively growing crop canopy is a **net oxygen generator**, not an oxygen sink.

#### Game Simplification Rationale
- *In-Game Action:* "Harvest Hydroponics" costs $10\text{ Energy}$ and $8\text{ Oxygen}$ to yield $+12\text{ Food}$.
- *Design Trade-off:* In a closed four-resource survival model, if hydroponics generated oxygen alongside food, energy would become the only true sink, causing severe balance collapse. The oxygen cost in the MVP abstracts **microbial bioreactor digestion, graywater purification aeration, and emergency heating decomposition**.
- *Future Roadmap:* In Phase 3, this will be separated into a distinct "Hydroponics Water & Carbon Loop", properly showing net oxygen production while introducing water recycling constraints.

---

### 3.6 NASA Space-Weather Telemetry & Heliospheric Modeling

#### Measured Scientific Data (NASA CCMC DONKI & M2M Office)
NASA's Community Coordinated Modeling Center (CCMC) Space Weather Database of Notifications, Knowledge, Information (DONKI) catalogs heliospheric solar events:
- **Coronal Mass Ejections (CMEs):** Large expulsions of plasma and magnetic fields from the solar corona, propagating outward into the heliosphere at speeds typically ranging from $200\text{ km/s}$ to over $2,000\text{ km/s}$.
- **WSA-ENLIL 3D Solar Wind Simulations:** The Wang-Sheeley-Arge (WSA) coronal model coupled with the ENLIL 3D magnetohydrodynamic (MHD) numerical code, executed by NASA's Moon to Mars (M2M) Space Weather Analysis Office.
- **Planetary Trajectory Filtering:** WSA-ENLIL simulations model solar wind shocks across the inner solar system, explicitly calculating predicted arrival times and shock parameters for specific coordinates including Mars ($1.524\text{ AU}$ mean orbital radius).

#### Scientific Integrity & Gameplay Representation
1. **Mars Trajectory vs. Heliospheric Noise:** Many CMEs cataloged by NASA DONKI propagate in directions off-axis from Mars. The game parses WSA-ENLIL impact projections (`impactList`) to explicitly verify whether a modeled shock intersects Mars (`"location": "Mars"`) and provides arrival estimates, rather than falsely treating every solar event as a direct Martian crisis.
2. **Earth Geomagnetic Data Exclusion:** Earth geomagnetic storm measurements (such as Kp-index or Earth-orbit magnetospheric perturbations) are never presented as Martian surface radiation, because Mars lacks an intrinsic global dipole magnetic field.
3. **Simulated Triage vs. Scientific Telemetry:** While the incoming CME ID, propagation speed (km/s), and arrival projection are authentic NASA telemetry, the specific outpost emergency damage (-6 Rad Shield, -8 Food, -8 Energy) is a simplified gameplay mechanic representing operational sheltering and emergency deflector load.
4. **Distinction Between Observations, Model Predictions, and In-Situ Particle Measurements:**  
   - *Measured Observations:* Remote coronagraph observations cataloged by NASA DONKI (e.g. CME detection time, speed, source morphology).
   - *Model Predictions:* WSA-ENLIL 3D MHD simulations of solar wind shocks propagating through the heliosphere, calculating estimated shock arrival timestamps at Mars orbit.
   - *Fictional Gameplay Mechanics:* Normalized resource impacts and commander choices represent balanced gameplay abstractions.
   - *Scientific Boundary:* DONKI CME observations and WSA-ENLIL modeled shock arrivals do not measure or confirm in-situ Solar Energetic Particle (SEP) flux or surface radiation dose at Mars. The outpost telemetry accurately describes space weather data as modeled heliospheric propagation and potential environmental risks rather than confirmed in-situ particle measurements.

---

## 4. Summary Table: Scientific Truth vs. Normalized Fictional Gameplay Units

> [!NOTE]
> All figures in the **"In-Game MVP Value"** column represent **normalized fictional gameplay units** engineered for strategic triage balance. They are **not** direct NASA measurements or operational flight requirements.

| Domain | Empirical Physical Value | Scientific Unit | Primary NASA Source | In-Game MVP Value (Fictional Units) | Gameplay Abstraction Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Crew Respiration** | $0.895$ | $\text{kg } O_2 / \text{person-day}$ | NASA BVAD Rev 2 (2022) | $-8\text{ O}_2 / \text{Sol}$ | $1\text{ unit} \approx 0.448\text{ kg } O_2$; $100\text{ units} \approx 44.8\text{ kg}$ outpost reservoir. |
| **Crew Nutrition** | $0.800$ solids; $12.778$ energy | $\text{kg/day}$; $\text{MJ/day}$ ($\approx 3,054\text{ kcal}$) | NASA BVAD Rev 2 (2022) | $-8\text{ Food} / \text{Sol}$ | $1\text{ unit} \approx 0.400\text{ kg dry matter}$; represents emergency meal packs. |
| **MOXIE Output (Test)** | $\approx 12$ peak | $\text{g } O_2 / \text{hour}$ | NASA Perseverance (2021-23) | $+14\text{ O}_2 / \text{action}$ | Technology demonstrator; in-game unit represents scaled outpost life support cell. |
| **MOXIE Output (ISRU)** | $2,000 - 3,000$ | $\text{g } O_2 / \text{hour}$ | NASA MAV Architecture | *Future Phase* | Sized for rocket propellant oxidizer (MAV return), not crew breathing. |
| **Surface Pressure** | $6.1$ mean ($4.0 - 8.7$) | $\text{mbar}$ ($610\text{ Pa}$) | NASA Mars Fact Sheet | Thin atmosphere | Replaced colloquial "vacuum"; low pressure drives rapid decompression. |
| **Solar Insolation** | $586.2$ mean | $\text{W/m}^2$ | NASA Mars Fact Sheet | Consumed for actions | $\approx 43\%$ Earth solar flux; dust mitigation requires EVA maintenance. |
| **Surface Radiation** | $0.64 \pm 0.12$ (dose equiv); $0.210 \pm 0.040$ in Si (absorbed dose) | $\text{mSv/day}$; $\text{mGy/day}$ | Curiosity RAD / Hassler et al. (2014) | $-6\text{ Shield} / \text{Sol}$ | Normalized fictional habitat shielding health; abstracts cumulative biological tissue dose. |
| **Solar Storm (SPE)** | Variable enhancement modulated by spectrum, duration, & atmosphere | Variable flux | Curiosity RAD (2014) | Alert Event ($-24\text{ Shield}$) | Tactical crisis event requiring crew sheltering based on event intensity and shielding. |
| **Magnetic Deflection** | Purely theoretical / unproven for surface ops | N/A | Conceptual studies / NIAC | Fictional Abstraction | Active deflectors are a sci-fi gameplay abstraction; passive regolith is the established technology. |

---

## 5. Assumptions Requiring Future Verification (Phase 3/4)

The following areas are currently estimated with simplified heuristics and will be updated as detailed models are developed:

1. **Graywater Recycling Recovery Fractions:**  
   - Current: Not modeled in MVP (food actions abstract water usage).  
   - Future: NASA BVAD baselines water recovery at $\sim 98\%$ on ISS (using vacuum distillation and catalytic oxidation).
2. **Thermal Dissipation in Low-Density $CO_2$ Atmosphere:**  
   - Current: Habitat heating is abstracted into baseline electrical energy consumption ($-8\text{ Energy/Sol}$).  
   - Future: Radiator convective and radiative heat loss based on Martian diurnal temperature swings ($-140^\circ\text{C}\text{ to }+20^\circ\text{C}$).
3. **Regolith Sintering Mass Requirements:**  
   - Current: Regolith reinforcement costs $10\text{ Energy}$ for $+10\text{ Shielding}$.  
   - Future: Microwave or solar concentrator sintering of basaltic regolith requires $\sim 1.2\text{–}1.8\text{ kWh/kg}$ of sintered tile to achieve radiation attenuation.
4. **Nitrogen Buffer Gas Leakage:**  
   - Current: Only oxygen loss is tracked during seal breaches.  
   - Future: In a human habitat ($101.3\text{ kPa}$ or $56.5\text{ kPa}$ exploration atmosphere), $78\%\text{ to } 66\%$ of the gas inventory is nitrogen ($N_2$). Replacing leaked buffer gas on Mars is extremely challenging due to low atmospheric $N_2$ abundance ($2.59\%$).

---

## 6. NASA Attribution & Non-Endorsement

*Mars Outpost Commander* is an educational software project created for the **NASA Space Apps Challenge 2026**.  
- Scientific parameters are sourced from publicly available NASA research and published planetary science literature.  
- This project is **not officially affiliated with, certified by, or endorsed by NASA or the United States Government**.
