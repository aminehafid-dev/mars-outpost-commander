class_name Main
extends Control

## Main controller for Mars Outpost Commander MVP.
## Manages game loop, UI updates, player actions, emergencies, and win/loss conditions.

const NasaSpaceWeatherServiceScript = preload("res://scripts/systems/nasa_space_weather_service.gd")

var state: GameState
var current_emergency: Dictionary = {}
var last_emergency_sol: int = -1

# UI Node References
var sol_label: Label
var crew_label: Label
var status_label: Label

# Resource UI
var oxygen_bar: ProgressBar
var oxygen_label: Label
var energy_bar: ProgressBar
var energy_label: Label
var food_bar: ProgressBar
var food_label: Label
var radiation_bar: ProgressBar
var radiation_label: Label

# Action Buttons
var btn_moxie: Button
var btn_solar: Button
var btn_hydro: Button
var btn_shield: Button
var btn_next_sol: Button

# Log
var log_label: RichTextLabel
var log_scroll: ScrollContainer

# Modals
var emergency_modal: Control
var emergency_title: Label
var emergency_desc: Label
var emergency_choice_container: VBoxContainer

var end_game_modal: Control
var end_game_title: Label
var end_game_reason: Label
var btn_restart: Button

# NASA Space Weather Telemetry UI
var nasa_service: Node
var weather_status_badge: Label
var weather_event_label: Label
var weather_speed_label: Label
var weather_target_label: Label
var weather_time_label: Label
var btn_refresh_weather: Button

func _ready() -> void:
	# Configure viewport anchors
	set_anchors_preset(Control.PRESET_FULL_RECT)
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	state = GameState.new()
	_build_ui()
	
	# Initialize NASA Space Weather Service
	nasa_service = NasaSpaceWeatherServiceScript.new()
	nasa_service.data_updated.connect(_on_space_weather_updated)
	nasa_service.status_changed.connect(_on_space_weather_status_changed)
	add_child(nasa_service)
	
	_update_ui()
	_update_space_weather_ui(nasa_service.latest_data)
	
	_log("[color=#38bdf8][b]SYSTEM INITIALIZED:[/b] Welcome Outpost Commander. Jezero Base is operational.[/color]")
	_log("[color=#94a3b8]Goal: Sustain the outpost and survive for 10 Martian Sols.[/color]")
	_log("[color=#64748b][i]Mars Outpost Commander MVP (Educational simulation for NASA Space Apps Challenge). Not endorsed by NASA.[/i][/color]")

func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.06, 0.1) # Dark space blue
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Root Margin Container for padding
	var root_margin := MarginContainer.new()
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 16)
	root_margin.add_theme_constant_override("margin_top", 12)
	root_margin.add_theme_constant_override("margin_right", 16)
	root_margin.add_theme_constant_override("margin_bottom", 12)
	add_child(root_margin)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	root_margin.add_child(main_vbox)
	
	# Top Header Bar
	var header_panel := _create_panel(Color(0.08, 0.11, 0.18, 0.95), Color(0.2, 0.35, 0.6, 0.8), 2)
	main_vbox.add_child(header_panel)
	
	var header_margin := MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 16)
	header_margin.add_theme_constant_override("margin_top", 10)
	header_margin.add_theme_constant_override("margin_right", 16)
	header_margin.add_theme_constant_override("margin_bottom", 10)
	header_panel.add_child(header_margin)
	
	var header_hbox := HBoxContainer.new()
	header_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	header_hbox.add_theme_constant_override("separation", 24)
	header_margin.add_child(header_hbox)
	
	var title_lbl := Label.new()
	title_lbl.text = "MARS OUTPOST COMMANDER // JEZERO BASE"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	header_hbox.add_child(title_lbl)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)
	
	sol_label = Label.new()
	sol_label.text = "SOL: 1 / 10"
	sol_label.add_theme_font_size_override("font_size", 16)
	sol_label.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
	header_hbox.add_child(sol_label)
	
	crew_label = Label.new()
	crew_label.text = "CREW: 4 ACTIVE"
	crew_label.add_theme_font_size_override("font_size", 16)
	crew_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.5))
	header_hbox.add_child(crew_label)
	
	status_label = Label.new()
	status_label.text = "STATUS: NOMINAL"
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
	header_hbox.add_child(status_label)
	
	# Main Content Area: 3 Columns (Left: Resources, Center: Actions, Right: Log)
	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 12)
	main_vbox.add_child(content_hbox)
	
	# Left Column: Resource Telemetry
	var res_panel := _create_panel(Color(0.07, 0.09, 0.15, 0.9), Color(0.18, 0.25, 0.4), 1)
	res_panel.custom_minimum_size = Vector2(360, 0)
	content_hbox.add_child(res_panel)
	
	var res_margin := MarginContainer.new()
	res_margin.add_theme_constant_override("margin_left", 14)
	res_margin.add_theme_constant_override("margin_top", 12)
	res_margin.add_theme_constant_override("margin_right", 14)
	res_margin.add_theme_constant_override("margin_bottom", 12)
	res_panel.add_child(res_margin)
	
	var res_vbox := VBoxContainer.new()
	res_vbox.add_theme_constant_override("separation", 14)
	res_margin.add_child(res_vbox)
	
	var res_title := Label.new()
	res_title.text = "RESOURCE TELEMETRY (-8/-8/-8/-6 Sol Drain)"
	res_title.add_theme_font_size_override("font_size", 14)
	res_title.add_theme_color_override("font_color", Color(0.7, 0.8, 0.95))
	res_vbox.add_child(res_title)
	
	# 4 Resource Displays
	var o2_widgets := _create_resource_widget("Oxygen (O2)", Color(0.0, 0.85, 1.0), "Life Support & Pressure")
	res_vbox.add_child(o2_widgets["container"])
	oxygen_bar = o2_widgets["bar"]
	oxygen_label = o2_widgets["label"]
	
	var pwr_widgets := _create_resource_widget("Energy (Power)", Color(1.0, 0.75, 0.0), "Grid & Heat Capacity")
	res_vbox.add_child(pwr_widgets["container"])
	energy_bar = pwr_widgets["bar"]
	energy_label = pwr_widgets["label"]
	
	var food_widgets := _create_resource_widget("Food (Rations)", Color(0.25, 0.95, 0.4), "Hydroponics & Calories")
	res_vbox.add_child(food_widgets["container"])
	food_bar = food_widgets["bar"]
	food_label = food_widgets["label"]
	
	var rad_widgets := _create_resource_widget("Radiation Shielding", Color(0.85, 0.35, 1.0), "Regolith & Deflectors (Sci-Fi)")
	res_vbox.add_child(rad_widgets["container"])
	radiation_bar = rad_widgets["bar"]
	radiation_label = rad_widgets["label"]
	
	# NASA Space Weather Telemetry Panel
	_build_weather_panel(res_vbox)
	
	# Center Column: Commander Actions
	var action_panel := _create_panel(Color(0.07, 0.09, 0.15, 0.9), Color(0.18, 0.25, 0.4), 1)
	action_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(action_panel)
	
	var action_margin := MarginContainer.new()
	action_margin.add_theme_constant_override("margin_left", 14)
	action_margin.add_theme_constant_override("margin_top", 12)
	action_margin.add_theme_constant_override("margin_right", 14)
	action_margin.add_theme_constant_override("margin_bottom", 12)
	action_panel.add_child(action_margin)
	
	var action_vbox := VBoxContainer.new()
	action_vbox.add_theme_constant_override("separation", 10)
	action_margin.add_child(action_vbox)
	
	var action_title := Label.new()
	action_title.text = "OUTPOST OPERATIONS CONSOLE"
	action_title.add_theme_font_size_override("font_size", 14)
	action_title.add_theme_color_override("font_color", Color(0.7, 0.8, 0.95))
	action_vbox.add_child(action_title)
	
	# Action Buttons
	btn_moxie = _create_action_button(
		"Generate Oxygen (Run MOXIE)",
		"Electrolyze atmospheric CO2 into breathable O2.",
		"Cost: 12 Energy  |  Gain: +14 Oxygen",
		Color(0.0, 0.85, 1.0)
	)
	btn_moxie.pressed.connect(_on_action_moxie_pressed)
	action_vbox.add_child(btn_moxie)
	
	btn_solar = _create_action_button(
		"Clean Solar Arrays",
		"Crew EVA clears abrasive dust from photovoltaic fields.",
		"Cost: 8 Food, 6 Rad Shield  |  Gain: +14 Energy",
		Color(1.0, 0.75, 0.0)
	)
	btn_solar.pressed.connect(_on_action_solar_pressed)
	action_vbox.add_child(btn_solar)
	
	btn_hydro = _create_action_button(
		"Harvest Hydroponics",
		"Cycle nutrient baths and LED grow lamps for crops.",
		"Cost: 10 Energy, 8 Oxygen  |  Gain: +12 Food",
		Color(0.25, 0.95, 0.4)
	)
	btn_hydro.pressed.connect(_on_action_hydro_pressed)
	action_vbox.add_child(btn_hydro)
	
	btn_shield = _create_action_button(
		"Reinforce Radiation Shielding",
		"Automated rovers 3D-sinter regolith shielding.",
		"Cost: 10 Energy  |  Gain: +10 Radiation Shield",
		Color(0.85, 0.35, 1.0)
	)
	btn_shield.pressed.connect(_on_action_shield_pressed)
	action_vbox.add_child(btn_shield)
	
	var action_spacer := Control.new()
	action_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_vbox.add_child(action_spacer)
	
	# Advance Sol Button (Prominent)
	btn_next_sol = Button.new()
	btn_next_sol.text = "ADVANCE TO NEXT SOL >>"
	btn_next_sol.custom_minimum_size = Vector2(0, 48)
	btn_next_sol.add_theme_font_size_override("font_size", 16)
	
	var next_sol_style := StyleBoxFlat.new()
	next_sol_style.bg_color = Color(0.12, 0.45, 0.75)
	next_sol_style.border_color = Color(0.35, 0.75, 1.0)
	next_sol_style.set_border_width_all(2)
	next_sol_style.set_corner_radius_all(6)
	btn_next_sol.add_theme_stylebox_override("normal", next_sol_style)
	
	var next_sol_hover := next_sol_style.duplicate() as StyleBoxFlat
	next_sol_hover.bg_color = Color(0.18, 0.58, 0.95)
	btn_next_sol.add_theme_stylebox_override("hover", next_sol_hover)
	
	btn_next_sol.pressed.connect(_on_next_sol_pressed)
	action_vbox.add_child(btn_next_sol)
	
	# Right Column: Mission Log
	var log_panel := _create_panel(Color(0.07, 0.09, 0.15, 0.9), Color(0.18, 0.25, 0.4), 1)
	log_panel.custom_minimum_size = Vector2(380, 0)
	content_hbox.add_child(log_panel)
	
	var log_margin := MarginContainer.new()
	log_margin.add_theme_constant_override("margin_left", 14)
	log_margin.add_theme_constant_override("margin_top", 12)
	log_margin.add_theme_constant_override("margin_right", 14)
	log_margin.add_theme_constant_override("margin_bottom", 12)
	log_panel.add_child(log_margin)
	
	var log_vbox := VBoxContainer.new()
	log_vbox.add_theme_constant_override("separation", 8)
	log_margin.add_child(log_vbox)
	
	var log_title := Label.new()
	log_title.text = "OUTPOST TELEMETRY & EVENT LOG"
	log_title.add_theme_font_size_override("font_size", 14)
	log_title.add_theme_color_override("font_color", Color(0.7, 0.8, 0.95))
	log_vbox.add_child(log_title)
	
	log_scroll = ScrollContainer.new()
	log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_vbox.add_child(log_scroll)
	
	log_label = RichTextLabel.new()
	log_label.bbcode_enabled = true
	log_label.scroll_following = true
	log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_label.add_theme_font_size_override("normal_font_size", 13)
	log_scroll.add_child(log_label)
	
	# Modals Overlay
	_build_emergency_modal()
	_build_endgame_modal()

func _create_panel(bg_col: Color, border_col: Color, border_width: int) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = bg_col
	style.border_color = border_col
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _create_resource_widget(res_name: String, fill_color: Color, subtitle: String) -> Dictionary:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	
	var header_hbox := HBoxContainer.new()
	vbox.add_child(header_hbox)
	
	var name_lbl := Label.new()
	name_lbl.text = res_name
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", fill_color)
	header_hbox.add_child(name_lbl)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)
	
	var val_lbl := Label.new()
	val_lbl.text = "0 / 100"
	val_lbl.add_theme_font_size_override("font_size", 14)
	header_hbox.add_child(val_lbl)
	
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 50.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 14)
	
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.1, 0.12, 0.18)
	bar_bg.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bar_bg)
	
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = fill_color
	bar_fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", bar_fill)
	
	vbox.add_child(bar)
	
	var desc_lbl := Label.new()
	desc_lbl.text = subtitle
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
	vbox.add_child(desc_lbl)
	
	return { "container": vbox, "bar": bar, "label": val_lbl }

func _create_action_button(title: String, desc: String, cost_text: String, accent_color: Color) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 68)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.13, 0.22)
	style.border_color = Color(0.2, 0.28, 0.45)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("normal", style)
	
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.14, 0.19, 0.3)
	hover.border_color = accent_color
	btn.add_theme_stylebox_override("hover", hover)
	
	var disabled := style.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.06, 0.08, 0.12)
	disabled.border_color = Color(0.15, 0.18, 0.24)
	btn.add_theme_stylebox_override("disabled", disabled)
	
	# Layout content inside button
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 6)
	btn.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)
	
	var title_lbl := Label.new()
	title_lbl.text = title
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	vbox.add_child(title_lbl)
	
	var desc_lbl := Label.new()
	desc_lbl.text = desc
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	vbox.add_child(desc_lbl)
	
	var cost_lbl := Label.new()
	cost_lbl.text = cost_text
	cost_lbl.add_theme_font_size_override("font_size", 11)
	cost_lbl.add_theme_color_override("font_color", accent_color)
	vbox.add_child(cost_lbl)
	
	return btn

func _build_emergency_modal() -> void:
	emergency_modal = Control.new()
	emergency_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	emergency_modal.visible = false
	add_child(emergency_modal)
	
	# Semi-transparent dark overlay
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.8)
	emergency_modal.add_child(backdrop)
	
	# Center card
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	emergency_modal.add_child(center)
	
	var card := _create_panel(Color(0.1, 0.07, 0.1), Color(1.0, 0.25, 0.25), 2)
	card.custom_minimum_size = Vector2(620, 360)
	center.add_child(card)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)
	
	emergency_title = Label.new()
	emergency_title.text = "CRITICAL ALERT: EMERGENCY"
	emergency_title.add_theme_font_size_override("font_size", 18)
	emergency_title.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	vbox.add_child(emergency_title)
	
	emergency_desc = Label.new()
	emergency_desc.text = "Emergency description..."
	emergency_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	emergency_desc.add_theme_font_size_override("font_size", 13)
	emergency_desc.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	vbox.add_child(emergency_desc)
	
	emergency_choice_container = VBoxContainer.new()
	emergency_choice_container.add_theme_constant_override("separation", 10)
	vbox.add_child(emergency_choice_container)

func _build_endgame_modal() -> void:
	end_game_modal = Control.new()
	end_game_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_game_modal.visible = false
	add_child(end_game_modal)
	
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.85)
	end_game_modal.add_child(backdrop)
	
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_game_modal.add_child(center)
	
	var card := _create_panel(Color(0.08, 0.1, 0.16), Color(0.3, 0.6, 0.9), 2)
	card.custom_minimum_size = Vector2(500, 260)
	center.add_child(card)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)
	
	end_game_title = Label.new()
	end_game_title.text = "MISSION COMPLETE"
	end_game_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_game_title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(end_game_title)
	
	end_game_reason = Label.new()
	end_game_reason.text = "Mission outcome details..."
	end_game_reason.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_game_reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_game_reason.add_theme_font_size_override("font_size", 14)
	vbox.add_child(end_game_reason)
	
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	btn_restart = Button.new()
	btn_restart.text = "RESTART MISSION"
	btn_restart.custom_minimum_size = Vector2(0, 42)
	btn_restart.add_theme_font_size_override("font_size", 15)
	btn_restart.pressed.connect(_on_restart_pressed)
	vbox.add_child(btn_restart)

# -------------------------------------------------------------
# UI Updates & Simulation State
# -------------------------------------------------------------

func _update_ui() -> void:
	# Update Resource Values & Bars
	oxygen_bar.value = state.oxygen
	oxygen_label.text = "%d / 100" % int(round(state.oxygen))
	_set_label_warning_color(oxygen_label, state.oxygen)
	
	energy_bar.value = state.energy
	energy_label.text = "%d / 100" % int(round(state.energy))
	_set_label_warning_color(energy_label, state.energy)
	
	food_bar.value = state.food
	food_label.text = "%d / 100" % int(round(state.food))
	_set_label_warning_color(food_label, state.food)
	
	radiation_bar.value = state.radiation
	radiation_label.text = "%d / 100" % int(round(state.radiation))
	_set_label_warning_color(radiation_label, state.radiation)
	
	# Update Header
	sol_label.text = "SOL: %d / %d" % [mini(state.sol, state.MAX_SOL), state.MAX_SOL]
	crew_label.text = "CREW: %d ACTIVE" % state.crew
	
	# Status message
	if state.is_game_over:
		if state.is_victory:
			status_label.text = "STATUS: MISSION SUCCESS"
			status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		else:
			status_label.text = "STATUS: OUTPOST COMPROMISED"
			status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	elif state.oxygen < 25.0 or state.energy < 25.0 or state.food < 25.0 or state.radiation < 25.0:
		status_label.text = "STATUS: CRITICAL WARNING"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.2))
	else:
		status_label.text = "STATUS: NOMINAL"
		status_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
	
	# Update Button States based on Affordability and Game Over
	_update_button_states()

func _set_label_warning_color(label: Label, value: float) -> void:
	if value <= 20.0:
		label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
	elif value <= 40.0:
		label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	else:
		label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))

func _update_button_states() -> void:
	if state.is_game_over or emergency_modal.visible:
		btn_moxie.disabled = true
		btn_solar.disabled = true
		btn_hydro.disabled = true
		btn_shield.disabled = true
		btn_next_sol.disabled = true
		return
	
	btn_moxie.disabled = not state.can_afford({ "energy": 12.0 })
	btn_solar.disabled = not state.can_afford({ "food": 8.0, "radiation": 6.0 })
	btn_hydro.disabled = not state.can_afford({ "energy": 10.0, "oxygen": 8.0 })
	btn_shield.disabled = not state.can_afford({ "energy": 10.0 })
	btn_next_sol.disabled = false

func _log(bbcode: String) -> void:
	print("[GAME] " + bbcode)
	if log_label:
		log_label.append_text(bbcode + "\n")

# -------------------------------------------------------------
# Player Actions
# -------------------------------------------------------------

func _on_action_moxie_pressed() -> void:
	var cost := { "energy": 12.0 }
	var gain := { "oxygen": 14.0 }
	if state.apply_costs_and_gains(cost, gain):
		_log("[color=#38bdf8]Sol %d: MOXIE generator operated (-12 Energy, +14 Oxygen).[/color]" % state.sol)
		_update_ui()
		_check_game_over()

func _on_action_solar_pressed() -> void:
	var cost := { "food": 8.0, "radiation": 6.0 }
	var gain := { "energy": 14.0 }
	if state.apply_costs_and_gains(cost, gain):
		_log("[color=#facc15]Sol %d: Solar array dust cleared (-8 Food, -6 Rad Shield, +14 Energy).[/color]" % state.sol)
		_update_ui()
		_check_game_over()

func _on_action_hydro_pressed() -> void:
	var cost := { "energy": 10.0, "oxygen": 8.0 }
	var gain := { "food": 12.0 }
	if state.apply_costs_and_gains(cost, gain):
		_log("[color=#4ade80]Sol %d: Hydroponics crops harvested (-10 Energy, -8 Oxygen, +12 Food).[/color]" % state.sol)
		_update_ui()
		_check_game_over()

func _on_action_shield_pressed() -> void:
	var cost := { "energy": 10.0 }
	var gain := { "radiation": 10.0 }
	if state.apply_costs_and_gains(cost, gain):
		_log("[color=#c084fc]Sol %d: Regolith sintering reinforced shields (-10 Energy, +10 Rad Shield).[/color]" % state.sol)
		_update_ui()
		_check_game_over()

# -------------------------------------------------------------
# Next Sol & Emergency Flow
# -------------------------------------------------------------

func _on_next_sol_pressed() -> void:
	if state.is_game_over or emergency_modal.visible:
		return
	
	# Apply daily consumption for the finished Sol
	state.advance_sol_consumption()
	_log("[color=#94a3b8]--- End of Sol %d --- Base consumption: -8 O2, -8 Energy, -8 Food, -6 Rad Shield.[/color]" % state.sol)
	
	# Check if daily consumption caused game over
	if _check_game_over():
		_update_ui()
		return
	
	# Check victory: player survived 10 Sols
	if state.sol >= state.MAX_SOL:
		state.is_game_over = true
		state.is_victory = true
		state.game_over_reason = "Mission Success! The outpost successfully survived 10 Sols on Mars!"
		_show_endgame_modal()
		_update_ui()
		return
	
	# Advance to next Sol
	state.sol += 1
	_log("[color=#f8fafc][b]=== SOL %d BEGINS ===[/b][/color]" % state.sol)
	
	# Roll for emergencies
	var emergency := EmergencySystem.roll_emergency(state.sol, last_emergency_sol, nasa_service.latest_data if nasa_service else {})
	if not emergency.is_empty():
		_trigger_emergency(emergency)
	
	_update_ui()

func _trigger_emergency(emergency: Dictionary) -> void:
	current_emergency = emergency
	last_emergency_sol = state.sol
	emergency_title.text = emergency["title"]
	emergency_title.add_theme_color_override("font_color", emergency.get("warning_color", Color(1.0, 0.3, 0.3)))
	emergency_desc.text = emergency["description"]
	
	# Clear previous choice buttons
	for child in emergency_choice_container.get_children():
		child.queue_free()
	
	# Build choice buttons with proper styling and word wrapping
	var choices: Array = emergency["choices"]
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 56)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		var bstyle := StyleBoxFlat.new()
		bstyle.bg_color = Color(0.12, 0.14, 0.22)
		bstyle.border_color = Color(0.28, 0.35, 0.5)
		bstyle.set_border_width_all(1)
		bstyle.set_corner_radius_all(5)
		bstyle.content_margin_left = 12
		bstyle.content_margin_right = 12
		bstyle.content_margin_top = 8
		bstyle.content_margin_bottom = 8
		btn.add_theme_stylebox_override("normal", bstyle)
		
		var bhover := bstyle.duplicate() as StyleBoxFlat
		bhover.bg_color = Color(0.18, 0.22, 0.34)
		bhover.border_color = Color(0.4, 0.7, 1.0)
		btn.add_theme_stylebox_override("hover", bhover)
		
		var bdisabled := bstyle.duplicate() as StyleBoxFlat
		bdisabled.bg_color = Color(0.08, 0.09, 0.14)
		bdisabled.border_color = Color(0.18, 0.2, 0.26)
		btn.add_theme_stylebox_override("disabled", bdisabled)
		
		# Button text with description and cost
		var cost_str := ""
		var cost: Dictionary = choice.get("cost", {})
		if cost.is_empty():
			cost_str = "No Resource Cost"
		else:
			var parts := []
			for k in cost.keys():
				parts.append("-%d %s" % [int(cost[k]), k.capitalize()])
			cost_str = "Cost: " + ", ".join(parts)
		
		btn.text = "%s\n%s  [%s]" % [choice["title"], choice["description"], cost_str]
		
		# Check affordability
		if not state.can_afford(cost):
			btn.disabled = true
			btn.text += " (INSUFFICIENT RESOURCES)"
		
		var choice_idx := i
		btn.pressed.connect(func(): _on_emergency_choice_selected(choice_idx))
		emergency_choice_container.add_child(btn)
	
	emergency_modal.visible = true
	_log("[color=#ef4444][b]CRISIS ALERT:[/b] %s[/color]" % emergency["title"])
	_update_button_states()

func _on_emergency_choice_selected(choice_idx: int) -> void:
	if current_emergency.is_empty():
		return
	
	var choices: Array = current_emergency["choices"]
	if choice_idx < 0 or choice_idx >= choices.size():
		return
	
	var choice: Dictionary = choices[choice_idx]
	var cost: Dictionary = choice.get("cost", {})
	var impact: Dictionary = choice.get("impact", {})
	var result_text: String = choice.get("result_text", "Emergency resolved.")
	
	# Apply costs and consequences
	if state.can_afford(cost):
		state.apply_costs_and_gains(cost, {})
		state.apply_emergency_impact(impact)
		_log("[color=#fbbf24]Commander Action: %s[/color]" % result_text)
	else:
		_log("[color=#ef4444]Emergency decision failed: insufficient resources.[/color]")
	
	emergency_modal.visible = false
	current_emergency = {}
	
	_update_ui()
	_check_game_over()

# -------------------------------------------------------------
# End Game & Restart
# -------------------------------------------------------------

func _check_game_over() -> bool:
	state.check_conditions()
	if state.is_game_over:
		_show_endgame_modal()
		_update_ui()
		return true
	return false

func _show_endgame_modal() -> void:
	if state.is_victory:
		end_game_title.text = "MISSION ACCOMPLISHED!"
		end_game_title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		end_game_reason.text = state.game_over_reason + "\n\nAll 10 Sols survived with life support intact. Outpost Command authorizes Phase 2 base expansion.\n\n[Project Mars Outpost Commander — Student project for NASA Space Apps Challenge hackathon. Not officially affiliated with or endorsed by NASA.]"
		_log("[color=#4ade80][b]%s[/b][/color]" % state.game_over_reason)
	else:
		end_game_title.text = "MISSION FAILED"
		end_game_title.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
		end_game_reason.text = state.game_over_reason + "\n\nOutpost life support failed. The Martian frontier claims another expedition.\n\n[Project Mars Outpost Commander — Student project for NASA Space Apps Challenge hackathon. Not officially affiliated with or endorsed by NASA.]"
		_log("[color=#ef4444][b]%s[/b][/color]" % state.game_over_reason)
	
	end_game_modal.visible = true
	_update_button_states()

func _on_restart_pressed() -> void:
	state.reset()
	last_emergency_sol = -1
	end_game_modal.visible = false
	emergency_modal.visible = false
	current_emergency = {}
	for child in emergency_choice_container.get_children():
		child.queue_free()
	if log_label:
		log_label.clear()
	_log("[color=#38bdf8][b]MISSION RESTARTED:[/b] Jezero Base reinitialized to Sol 1.[/color]")
	_log("[color=#64748b][i]Mars Outpost Commander MVP (Educational simulation for NASA Space Apps Challenge). Not endorsed by NASA.[/i][/color]")
	_update_ui()

# -------------------------------------------------------------
# NASA Space Weather Telemetry Panel & Handlers
# -------------------------------------------------------------

func _build_weather_panel(parent: VBoxContainer) -> void:
	var separator := HSeparator.new()
	var sep_style := StyleBoxLine.new()
	sep_style.color = Color(0.2, 0.3, 0.45, 0.5)
	sep_style.thickness = 1
	separator.add_theme_stylebox_override("separator", sep_style)
	parent.add_child(separator)
	
	var panel := _create_panel(Color(0.05, 0.07, 0.12, 0.95), Color(0.2, 0.32, 0.5, 0.8), 1)
	parent.add_child(panel)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)
	
	# Header Row: Title & Status Badge
	var header_hbox := HBoxContainer.new()
	vbox.add_child(header_hbox)
	
	var title_lbl := Label.new()
	title_lbl.text = "NASA SPACE WEATHER"
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	header_hbox.add_child(title_lbl)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)
	
	weather_status_badge = Label.new()
	weather_status_badge.text = "[ INITIALIZING ]"
	weather_status_badge.add_theme_font_size_override("font_size", 11)
	weather_status_badge.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	header_hbox.add_child(weather_status_badge)
	
	# Telemetry info fields
	weather_event_label = Label.new()
	weather_event_label.text = "Event: Loading telemetry..."
	weather_event_label.add_theme_font_size_override("font_size", 11)
	weather_event_label.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	vbox.add_child(weather_event_label)
	
	weather_speed_label = Label.new()
	weather_speed_label.text = "Solar Wind: -- km/s"
	weather_speed_label.add_theme_font_size_override("font_size", 11)
	weather_speed_label.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	vbox.add_child(weather_speed_label)
	
	weather_target_label = Label.new()
	weather_target_label.text = "Mars Trajectory: Checking..."
	weather_target_label.add_theme_font_size_override("font_size", 11)
	weather_target_label.add_theme_color_override("font_color", Color(0.3, 0.85, 0.95))
	weather_target_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(weather_target_label)
	
	weather_time_label = Label.new()
	weather_time_label.text = "Telemetry: Pending..."
	weather_time_label.add_theme_font_size_override("font_size", 10)
	weather_time_label.add_theme_color_override("font_color", Color(0.55, 0.65, 0.75))
	vbox.add_child(weather_time_label)
	
	var attr_label := Label.new()
	attr_label.text = "Source: NASA CCMC DONKI / M2M Office\nDisclaimer: DONKI CME observations and WSA-ENLIL simulations model solar wind propagation; they do not measure in-situ SEP flux or surface radiation dose at Mars."
	attr_label.add_theme_font_size_override("font_size", 9)
	attr_label.add_theme_color_override("font_color", Color(0.45, 0.55, 0.65))
	attr_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(attr_label)
	
	# Refresh button
	btn_refresh_weather = Button.new()
	btn_refresh_weather.text = "REFRESH TELEMETRY"
	btn_refresh_weather.custom_minimum_size = Vector2(0, 28)
	btn_refresh_weather.add_theme_font_size_override("font_size", 11)
	
	var bstyle := StyleBoxFlat.new()
	bstyle.bg_color = Color(0.1, 0.16, 0.26)
	bstyle.border_color = Color(0.25, 0.45, 0.7)
	bstyle.set_border_width_all(1)
	bstyle.set_corner_radius_all(4)
	btn_refresh_weather.add_theme_stylebox_override("normal", bstyle)
	
	var bhover := bstyle.duplicate() as StyleBoxFlat
	bhover.bg_color = Color(0.15, 0.24, 0.38)
	bhover.border_color = Color(0.4, 0.7, 1.0)
	btn_refresh_weather.add_theme_stylebox_override("hover", bhover)
	
	btn_refresh_weather.pressed.connect(_on_refresh_weather_pressed)
	vbox.add_child(btn_refresh_weather)

func _update_space_weather_ui(data: Dictionary) -> void:
	if not weather_event_label or data.is_empty():
		return
	
	var act_id: String = data.get("activity_id", "None")
	var cme_type: String = data.get("cme_type", "C")
	weather_event_label.text = "Event: %s (Type %s)" % [act_id, cme_type]
	
	var speed: float = data.get("speed", 0.0)
	weather_speed_label.text = "Velocity: %d km/s (CME Front)" % int(speed)
	
	var has_impact: bool = data.get("has_mars_impact", false)
	var arrival: String = data.get("mars_arrival_time", "None")
	var classification: String = data.get("trajectory_classification", "Modeled Strike")
	if has_impact:
		weather_target_label.text = "Modeled Shock: %s (WSA-ENLIL)\nEst. Mars Arrival: %s" % [classification.to_upper(), arrival]
		weather_target_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	else:
		weather_target_label.text = "Modeled Trajectory: Off-Axis (No Mars Shock)"
		weather_target_label.add_theme_color_override("font_color", Color(0.3, 0.85, 0.95))
	
	var timestamp: String = data.get("retrieval_timestamp", "Unknown")
	var conn_status: String = data.get("connection_status", "OFFLINE")
	weather_time_label.text = "Telemetry: %s (%s)" % [conn_status, timestamp]
	
	_update_space_weather_status_badge(conn_status)

func _update_space_weather_status_badge(status_text: String) -> void:
	if not weather_status_badge:
		return
	match status_text:
		"LIVE":
			weather_status_badge.text = "[ ● LIVE ]"
			weather_status_badge.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		"CACHED":
			weather_status_badge.text = "[ ⟳ CACHED ]"
			weather_status_badge.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		"OFFLINE":
			weather_status_badge.text = "[ ○ OFFLINE ]"
			weather_status_badge.add_theme_color_override("font_color", Color(1.0, 0.5, 0.2))
		"FETCHING":
			weather_status_badge.text = "[ ⟳ FETCHING ]"
			weather_status_badge.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0))
		_:
			weather_status_badge.text = "[ %s ]" % status_text
			weather_status_badge.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

func _on_space_weather_updated(weather_data: Dictionary) -> void:
	_update_space_weather_ui(weather_data)
	if btn_refresh_weather:
		btn_refresh_weather.disabled = false
		btn_refresh_weather.text = "REFRESH TELEMETRY"
	_log("[color=#38bdf8]NASA Space Weather telemetry updated [%s]: CME %s (%d km/s).[/color]" % [
		weather_data.get("connection_status", "OFFLINE"),
		weather_data.get("activity_id", "Unknown"),
		int(weather_data.get("speed", 0.0))
	])

func _on_space_weather_status_changed(new_status: String) -> void:
	_update_space_weather_status_badge(new_status)
	if new_status == "FETCHING":
		if btn_refresh_weather:
			btn_refresh_weather.disabled = true
			btn_refresh_weather.text = "FETCHING TELEMETRY..."
	else:
		if btn_refresh_weather:
			btn_refresh_weather.disabled = false
			btn_refresh_weather.text = "REFRESH TELEMETRY"

func _on_refresh_weather_pressed() -> void:
	if not nasa_service:
		return
	_log("[color=#38bdf8]Commander requested NASA CCMC DONKI space weather telemetry refresh...[/color]")
	nasa_service.fetch_latest_data()
