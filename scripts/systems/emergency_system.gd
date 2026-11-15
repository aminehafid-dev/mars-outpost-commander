class_name EmergencySystem
extends RefCounted

## EmergencySystem manages crisis events, emergency decision choices,
## and outcome consequence calculation for Mars Outpost Commander.

const EMERGENCIES: Array[Dictionary] = [
	{
		"id": "oxygen_leak",
		"type": "Oxygen Leak",
		"title": "CRITICAL ALERT: Habitat Oxygen Leak",
		"description": "Atmospheric sensor in Module Bravo detects a micro-fracture seal breach. Outpost oxygen is venting into the Martian thin atmosphere!",
		"warning_color": Color(0.2, 0.8, 1.0),
		"choices": [
			{
				"title": "Emergency EVA Patch",
				"description": "Deploy two crew members in EVA suits to weld the exterior seal.",
				"cost": { "energy": 12.0 },
				"impact": { "oxygen": -5.0 },
				"result_text": "Exterior seal welded successfully. Minimal oxygen loss (-5 O2, -12 Energy)."
			},
			{
				"title": "Bulkhead Quarantine",
				"description": "Isolate and vent Sector B to preserve main habitat pressure.",
				"cost": {},
				"impact": { "oxygen": -20.0 },
				"result_text": "Sector B evacuated and sealed. 20 units of oxygen vented into the Martian thin air."
			},
			{
				"title": "Overdrive MOXIE Scrubbers",
				"description": "Burn heavy power to pump emergency oxygen reserves to compensate.",
				"cost": { "energy": 22.0 },
				"impact": { "oxygen": 0.0 },
				"result_text": "Scrubbers ran at 150% capacity, neutralizing the leak with heavy energy drain (-22 Energy)."
			}
		]
	},
	{
		"id": "solar_storm",
		"type": "Solar Storm",
		"title": "RADIATION ALERT: Coronal Mass Ejection",
		"description": "A Class-X solar flare has reached Jezero Crater. Dangerous ionized radiation is sweeping across the Martian surface.",
		"warning_color": Color(0.9, 0.3, 1.0),
		"choices": [
			{
				"title": "Regolith Bunker Lockdown",
				"description": "Shelter crew in the deep regolith vault; auxiliary heating consumes extra rations and power.",
				"cost": { "food": 8.0, "energy": 8.0 },
				"impact": { "radiation": -6.0 },
				"result_text": "Crew spent 18 hours sheltered in the vault. Minimal radiation exposure (-6 Rad, -8 Food, -8 Energy)."
			},
			{
				"title": "Overcharge Magnetic Deflectors",
				"description": "Route maximum wattage into the outpost's active electromagnetic deflector shields.",
				"cost": { "energy": 24.0 },
				"impact": { "radiation": 0.0 },
				"result_text": "Deflector coils absorbed the coronal burst completely (-24 Energy, 0 Rad loss)."
			},
			{
				"title": "Maintain Surface Operations",
				"description": "Keep crew working on the surface and absorb radiation degradation.",
				"cost": {},
				"impact": { "radiation": -24.0 },
				"result_text": "Outpost shielding took severe punishment from unshielded particle bombardment (-24 Radiation Protection)."
			}
		]
	},
	{
		"id": "power_failure",
		"type": "Power Failure",
		"title": "GRID WARNING: Substation Transformer Blowout",
		"description": "Fine electrostatically charged Martian dust accumulated in the primary transformer, causing an explosive short circuit.",
		"warning_color": Color(1.0, 0.75, 0.1),
		"choices": [
			{
				"title": "Reroute Life Support Fuel Cells",
				"description": "Tap into liquid oxygen chemical fuel cells to jumpstart the power grid.",
				"cost": { "oxygen": 14.0 },
				"impact": { "energy": -4.0 },
				"result_text": "Fuel cells stabilized the substation, consuming liquid oxygen reserves (-14 O2, -4 Energy)."
			},
			{
				"title": "Emergency Reactor Vent",
				"description": "Dump reactor containment heat into radiators to bypass the short.",
				"cost": { "radiation": 12.0 },
				"impact": { "energy": -4.0 },
				"result_text": "Thermal vent cleared the short circuit, slightly degrading radiation containment (-12 Rad, -4 Energy)."
			},
			{
				"title": "Controlled Rolling Blackout",
				"description": "Let non-essential subsystems go dark until dust settles.",
				"cost": {},
				"impact": { "energy": -22.0 },
				"result_text": "Rolling blackout left scientific and heating bays offline for hours (-22 Energy)."
			}
		]
	}
]

static func roll_emergency(sol: int, last_emergency_sol: int = -1, space_weather_data: Dictionary = {}) -> Dictionary:
	var base_emergency: Dictionary = {}
	
	# Guaranteed events for reliable testing & progression pacing
	if sol == 3:
		base_emergency = EMERGENCIES[0] # Oxygen Leak
	elif sol == 6:
		base_emergency = EMERGENCIES[1] # Solar Storm
	elif sol == 8:
		base_emergency = EMERGENCIES[2] # Power Failure
	elif last_emergency_sol > 0 and (sol - last_emergency_sol) < 2:
		# Minimum 1-Sol cooldown between random emergencies to guarantee fairness
		return {}
	elif sol > 1 and sol < 10:
		# Probabilistic emergency on other Sols (25% chance)
		if randf() < 0.25:
			base_emergency = EMERGENCIES[randi() % EMERGENCIES.size()]
	
	if base_emergency.is_empty():
		return {}
	
	# If solar storm and authentic space weather telemetry is available, dynamically enrich narrative
	if base_emergency.get("id") == "solar_storm" and not space_weather_data.is_empty():
		var enriched: Dictionary = base_emergency.duplicate(true)
		var act_id: String = space_weather_data.get("activity_id", "")
		var speed: float = space_weather_data.get("speed", 500.0)
		var cme_type: String = space_weather_data.get("cme_type", "C")
		var has_impact: bool = space_weather_data.get("has_mars_impact", false)
		var arrival: String = space_weather_data.get("mars_arrival_time", "")
		
		if not act_id.is_empty():
			enriched["title"] = "RADIATION ALERT: NASA CCMC Telemetry [%s]" % act_id
			if has_impact:
				var classification: String = space_weather_data.get("trajectory_classification", "Modeled Strike")
				enriched["description"] = "NASA Moon to Mars Space Weather Office preliminary models project a Mars solar wind shock arrival (%s) at %d km/s (Type %s, %s). Modeled energetic particles are interacting with the upper exosphere (simulated triage response; not direct in-situ surface dose)." % [arrival, int(speed), cme_type, classification]
			else:
				enriched["description"] = "NASA CCMC heliospheric sensors detect CME event %s propagating at %d km/s (Type %s; off-axis trajectory). Background solar energetic particles detected (simulated triage response)." % [act_id, int(speed), cme_type]
		return enriched
	
	return base_emergency
