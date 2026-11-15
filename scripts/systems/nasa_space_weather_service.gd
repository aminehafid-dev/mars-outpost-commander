class_name NasaSpaceWeatherService
extends Node

## NasaSpaceWeatherService manages retrieval, caching, validation,
## and fallback for authentic NASA CCMC space weather telemetry.
## Specifically monitors Coronal Mass Ejections (CME) and WSA-ENLIL
## solar wind simulations for Mars-directed space weather.

signal data_updated(weather_data: Dictionary)
signal status_changed(new_status: String)

enum ConnectionStatus {
	OFFLINE,
	CACHED,
	LIVE
}

# Official NASA CCMC API endpoints (Post-September 2026 migration)
const CCMC_DONKI_URL: String = "https://ccmc.gsfc.nasa.gov/DONKI-API/get/CME"
const NASA_PORTAL_URL: String = "https://api.nasa.gov/DONKI/CME"

# File paths
const FALLBACK_PATH: String = "res://data/space_weather_fallback.json"
const CACHE_PATH: String = "user://space_weather_cache.json"

const HTTP_TIMEOUT_SECONDS: float = 8.0

var http_request: HTTPRequest
var status: ConnectionStatus = ConnectionStatus.OFFLINE
var latest_data: Dictionary = {}
var is_requesting: bool = false
var retrieval_timestamp: String = ""

func _ready() -> void:
	# Create internal HTTPRequest child node
	http_request = HTTPRequest.new()
	http_request.timeout = HTTP_TIMEOUT_SECONDS
	http_request.use_threads = true
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Start with bundled offline fallback or cache immediately so UI is never blank
	_load_cached_or_fallback()
	
	# Initiate non-blocking background fetch
	fetch_latest_data()

## Fetches the latest space weather data asynchronously from NASA CCMC
func fetch_latest_data() -> void:
	if is_requesting:
		return
	
	is_requesting = true
	emit_signal("status_changed", "FETCHING")
	
	# Compute query date window: past 14 days to today (UTC)
	var now_unix: int = int(Time.get_unix_time_from_system())
	var past_unix: int = now_unix - (14 * 86400)
	var end_date: String = Time.get_date_string_from_unix_time(now_unix)
	var start_date: String = Time.get_date_string_from_unix_time(past_unix)
	
	var api_key := _get_api_key()
	var auth_mode := "DEMO_KEY"
	if not api_key.is_empty():
		auth_mode = "CUSTOM_KEY (NASA_API_KEY env)"
	else:
		api_key = "DEMO_KEY"
	
	var url := "%s?startDate=%s&endDate=%s&api_key=%s" % [NASA_PORTAL_URL, start_date, end_date, api_key]
	print("[NasaSpaceWeatherService] Querying NASA Open API DONKI service (window: %s to %s, auth: %s)" % [start_date, end_date, auth_mode])
	
	var headers: PackedStringArray = [
		"User-Agent: MarsOutpostCommander/1.0 (NASA Space Apps Challenge 2026; Godot Engine)",
		"Accept: application/json"
	]
	
	var err := http_request.request(url, headers)
	if err != OK:
		is_requesting = false
		_on_fetch_failure("HTTPRequest dispatch error code: %d" % err)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	is_requesting = false
	print("[NasaSpaceWeatherService] Response received: result=%d code=%d body_len=%d" % [result, response_code, body.size()])
	
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_on_fetch_failure("HTTP Response failed: result=%d code=%d" % [result, response_code])
		return
	
	var raw_text := body.get_string_from_utf8()
	if raw_text.is_empty():
		_on_fetch_failure("Empty payload received from server")
		return
	
	var json := JSON.new()
	var parse_err := json.parse(raw_text)
	if parse_err != OK:
		_on_fetch_failure("JSON parse error: %s" % json.get_error_message())
		return
	
	var parsed_data = json.data
	if not (parsed_data is Array):
		_on_fetch_failure("Unexpected response schema: expected JSON array")
		return
	
	var events: Array = parsed_data as Array
	if events.is_empty():
		_on_fetch_failure("Zero CME events returned in window")
		return
	
	# Parse events into structured game telemetry
	var processed := _process_cme_events(events, "LIVE")
	if processed.is_empty():
		_on_fetch_failure("Failed to extract valid event parameters")
		return
	
	latest_data = processed
	status = ConnectionStatus.LIVE
	retrieval_timestamp = Time.get_datetime_string_from_system(true) + " UTC"
	latest_data["retrieval_timestamp"] = retrieval_timestamp
	
	print("[NasaSpaceWeatherService] Telemetry successfully parsed and updated to LIVE!")
	
	# Cache successful response locally
	_save_to_cache(raw_text)
	
	emit_signal("status_changed", "LIVE")
	emit_signal("data_updated", latest_data)

func _on_fetch_failure(err_msg: String) -> void:
	print("[NasaSpaceWeatherService] Fetch failure: %s. Using cached/fallback telemetry." % err_msg)
	# Fall back smoothly to local cache, then bundled offline data
	_load_cached_or_fallback()

## Processes raw DONKI CME event array, prioritizing Mars trajectory simulations
func _process_cme_events(events: Array, connection_mode: String) -> Dictionary:
	var mars_event: Dictionary = {}
	var most_recent_event: Dictionary = {}
	
	# Scan events for Mars-specific WSA-ENLIL impact projections
	for event in events:
		if not (event is Dictionary):
			continue
		var edict: Dictionary = event as Dictionary
		if most_recent_event.is_empty():
			most_recent_event = edict
		
		# Check cmeAnalyses -> enlilList -> impactList
		var analyses = edict.get("cmeAnalyses", [])
		if analyses is Array:
			for analysis in analyses:
				if not (analysis is Dictionary):
					continue
				var enlil_list = analysis.get("enlilList", [])
				if enlil_list is Array:
					for enlil in enlil_list:
						if not (enlil is Dictionary):
							continue
						var impact_list = enlil.get("impactList", [])
						if impact_list is Array:
							for impact in impact_list:
								if impact is Dictionary and impact.get("location", "") == "Mars":
									var arr_time = impact.get("arrivalTime", "")
									# Strictly ensure Mars entry contains a valid, non-empty arrivalTime
									if arr_time != null and not str(arr_time).strip_edges().is_empty():
										mars_event = {
											"cme": edict,
											"analysis": analysis,
											"impact": impact
										}
										break
						if not mars_event.is_empty():
							break
				if not mars_event.is_empty():
					break
		if not mars_event.is_empty():
			break
	
	var target_dict := Dictionary()
	
	if not mars_event.is_empty():
		# Found a CME specifically modeled for Mars arrival with validated arrival time
		var cme: Dictionary = mars_event["cme"]
		var analysis: Dictionary = mars_event["analysis"]
		var impact: Dictionary = mars_event["impact"]
		
		target_dict["has_mars_impact"] = true
		target_dict["activity_id"] = str(cme.get("activityID", "UNKNOWN-CME"))
		target_dict["event_time"] = str(cme.get("startTime", "Unknown"))
		target_dict["mars_arrival_time"] = str(impact.get("arrivalTime", "Pending"))
		
		var is_glancing: bool = impact.get("isGlancingBlow", false)
		var is_minor: bool = impact.get("isMinorImpact", false)
		target_dict["is_glancing_blow"] = is_glancing
		target_dict["is_minor_impact"] = is_minor
		
		var classification := "Direct Impact"
		if is_glancing:
			classification = "Glancing Blow"
		elif is_minor:
			classification = "Minor Impact"
		target_dict["trajectory_classification"] = classification
		
		target_dict["speed"] = float(analysis.get("speed", 500.0))
		target_dict["cme_type"] = str(analysis.get("type", "C"))
		target_dict["half_angle"] = float(analysis.get("halfAngle", 0.0))
		target_dict["note"] = str(cme.get("note", ""))
		target_dict["target_label"] = "Modeled Mars Trajectory (%s)" % classification
	elif not most_recent_event.is_empty():
		# General heliospheric solar observation (no direct Mars impact)
		var cme: Dictionary = most_recent_event
		var analyses = cme.get("cmeAnalyses", [])
		var first_analysis := {}
		if analyses is Array and not analyses.is_empty() and analyses[0] is Dictionary:
			first_analysis = analyses[0]
		
		target_dict["has_mars_impact"] = false
		target_dict["activity_id"] = str(cme.get("activityID", "UNKNOWN-CME"))
		target_dict["event_time"] = str(cme.get("startTime", "Unknown"))
		target_dict["mars_arrival_time"] = "None (Off-axis trajectory)"
		target_dict["is_glancing_blow"] = false
		target_dict["is_minor_impact"] = false
		target_dict["trajectory_classification"] = "Off-Axis / No Mars Shock"
		target_dict["speed"] = float(first_analysis.get("speed", 450.0))
		target_dict["cme_type"] = str(first_analysis.get("type", "S"))
		target_dict["half_angle"] = float(first_analysis.get("halfAngle", 0.0))
		target_dict["note"] = str(cme.get("note", ""))
		target_dict["target_label"] = "Heliospheric Observation (No Mars Shock)"
	else:
		return {}
	
	target_dict["connection_status"] = connection_mode
	target_dict["source_attribution"] = "NASA CCMC DONKI / Moon to Mars Space Weather Office"
	target_dict["scientific_disclaimer"] = "DONKI model products are preliminary research data; not direct Mars surface radiation measurements."
	
	return target_dict

func _load_cached_or_fallback() -> void:
	# 1. Try local user cache
	if FileAccess.file_exists(CACHE_PATH):
		var file := FileAccess.open(CACHE_PATH, FileAccess.READ)
		if file:
			var content := file.get_as_text()
			file.close()
			var json := JSON.new()
			if json.parse(content) == OK and json.data is Array:
				var processed := _process_cme_events(json.data as Array, "CACHED")
				if not processed.is_empty():
					latest_data = processed
					status = ConnectionStatus.CACHED
					latest_data["retrieval_timestamp"] = "Cached Local Storage"
					emit_signal("status_changed", "CACHED")
					emit_signal("data_updated", latest_data)
					return
	
	# 2. Try bundled offline fallback
	if FileAccess.file_exists(FALLBACK_PATH):
		var file := FileAccess.open(FALLBACK_PATH, FileAccess.READ)
		if file:
			var content := file.get_as_text()
			file.close()
			var json := JSON.new()
			if json.parse(content) == OK and json.data is Array:
				var processed := _process_cme_events(json.data as Array, "OFFLINE")
				if not processed.is_empty():
					latest_data = processed
					status = ConnectionStatus.OFFLINE
					latest_data["retrieval_timestamp"] = "Bundled Offline Dataset (Nov 2026 Snapshot)"
					emit_signal("status_changed", "OFFLINE")
					emit_signal("data_updated", latest_data)
					return

func _save_to_cache(json_text: String) -> void:
	var file := FileAccess.open(CACHE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_text)
		file.close()

## Safely checks environment for user-supplied NASA API key.
## Excludes res:// and .env files to prevent credential leakage in exported builds.
func _get_api_key() -> String:
	var env_key := OS.get_environment("NASA_API_KEY")
	if not env_key.is_empty():
		return env_key.strip_edges()
	return ""
