class_name GameState
extends RefCounted

## GameState holds the core simulation data and resource calculations
## for Mars Outpost Commander.

# Target / Initial Values
const INITIAL_OXYGEN: float = 80.0
const INITIAL_ENERGY: float = 75.0
const INITIAL_FOOD: float = 70.0
const INITIAL_RADIATION: float = 65.0
const INITIAL_CREW: int = 4
const INITIAL_SOL: int = 1
const MAX_SOL: int = 10
const MAX_RESOURCE: float = 100.0

# Base Daily Consumption per Sol (Sustaining 4 Crew & Habitat Systems)
const CONSUMPTION_OXYGEN: float = 8.0
const CONSUMPTION_ENERGY: float = 8.0
const CONSUMPTION_FOOD: float = 8.0
const CONSUMPTION_RADIATION: float = 6.0

# Current State
var oxygen: float = INITIAL_OXYGEN
var energy: float = INITIAL_ENERGY
var food: float = INITIAL_FOOD
var radiation: float = INITIAL_RADIATION
var crew: int = INITIAL_CREW
var sol: int = INITIAL_SOL

var is_game_over: bool = false
var is_victory: bool = false
var game_over_reason: String = ""

func reset() -> void:
	oxygen = INITIAL_OXYGEN
	energy = INITIAL_ENERGY
	food = INITIAL_FOOD
	radiation = INITIAL_RADIATION
	crew = INITIAL_CREW
	sol = INITIAL_SOL
	is_game_over = false
	is_victory = false
	game_over_reason = ""

func can_afford(cost: Dictionary) -> bool:
	if cost.has("oxygen") and oxygen < float(cost["oxygen"]):
		return false
	if cost.has("energy") and energy < float(cost["energy"]):
		return false
	if cost.has("food") and food < float(cost["food"]):
		return false
	if cost.has("radiation") and radiation < float(cost["radiation"]):
		return false
	return true

func apply_costs_and_gains(cost: Dictionary, gain: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	
	# Deduct costs safely
	if cost.has("oxygen"):
		oxygen = maxf(0.0, oxygen - float(cost["oxygen"]))
	if cost.has("energy"):
		energy = maxf(0.0, energy - float(cost["energy"]))
	if cost.has("food"):
		food = maxf(0.0, food - float(cost["food"]))
	if cost.has("radiation"):
		radiation = maxf(0.0, radiation - float(cost["radiation"]))
	
	# Apply gains clamped to MAX_RESOURCE
	if gain.has("oxygen"):
		oxygen = clampf(oxygen + float(gain["oxygen"]), 0.0, MAX_RESOURCE)
	if gain.has("energy"):
		energy = clampf(energy + float(gain["energy"]), 0.0, MAX_RESOURCE)
	if gain.has("food"):
		food = clampf(food + float(gain["food"]), 0.0, MAX_RESOURCE)
	if gain.has("radiation"):
		radiation = clampf(radiation + float(gain["radiation"]), 0.0, MAX_RESOURCE)
	
	check_conditions()
	return true

func advance_sol_consumption() -> Dictionary:
	var delta := {
		"oxygen": -CONSUMPTION_OXYGEN,
		"energy": -CONSUMPTION_ENERGY,
		"food": -CONSUMPTION_FOOD,
		"radiation": -CONSUMPTION_RADIATION
	}
	
	oxygen = maxf(0.0, oxygen - CONSUMPTION_OXYGEN)
	energy = maxf(0.0, energy - CONSUMPTION_ENERGY)
	food = maxf(0.0, food - CONSUMPTION_FOOD)
	radiation = maxf(0.0, radiation - CONSUMPTION_RADIATION)
	
	check_conditions()
	return delta

func apply_emergency_impact(impact: Dictionary) -> void:
	if impact.has("oxygen"):
		oxygen = clampf(oxygen + float(impact["oxygen"]), 0.0, MAX_RESOURCE)
	if impact.has("energy"):
		energy = clampf(energy + float(impact["energy"]), 0.0, MAX_RESOURCE)
	if impact.has("food"):
		food = clampf(food + float(impact["food"]), 0.0, MAX_RESOURCE)
	if impact.has("radiation"):
		radiation = clampf(radiation + float(impact["radiation"]), 0.0, MAX_RESOURCE)
	
	check_conditions()

func check_conditions() -> void:
	if is_game_over:
		return
	
	# Check for defeat (any resource reaching zero)
	if oxygen <= 0.0:
		is_game_over = true
		is_victory = false
		game_over_reason = "Outpost Asphyxiation: Oxygen reserves completely depleted."
	elif energy <= 0.0:
		is_game_over = true
		is_victory = false
		game_over_reason = "Total Blackout: Power failure caused life support to freeze."
	elif food <= 0.0:
		is_game_over = true
		is_victory = false
		game_over_reason = "Famine: Outpost food rations have been exhausted."
	elif radiation <= 0.0:
		is_game_over = true
		is_victory = false
		game_over_reason = "Lethal Radiation: Shielding destroyed; surface radiation overwhelmed the habitat."
	elif sol > MAX_SOL:
		# Player survived 10 Sols
		is_game_over = true
		is_victory = true
		game_over_reason = "Mission Success! The outpost successfully survived 10 Sols on Mars!"
