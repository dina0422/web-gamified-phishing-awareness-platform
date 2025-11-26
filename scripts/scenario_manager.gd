extends Node

# ScenarioManager - Fetches phishing scenarios from Firestore
# This replaces hardcoded scenarios with database-driven content

const FS_BASE := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents"
const PROJECT_ID := "phishproof-c6037"
const API_KEY := "AIzaSyBSt6YW37WjQQY_Hg8oF4zCM5HE9jXYCRc"

signal scenarios_loaded(scenarios: Array)
signal scenario_load_failed(error: String)
signal user_progress_loaded(progress: Dictionary)

var cached_scenarios := {}  # Cache scenarios by difficulty
var current_difficulty := "beginner"

func _ready():
	print("📊 ScenarioManager: Initialized")

# ========== FETCH SCENARIOS FROM FIRESTORE ==========

func fetch_scenarios(difficulty: String = "beginner") -> Array:
	"""
	Fetch all scenarios for a specific difficulty level from Firestore
	Returns: Array of scenario dictionaries
	"""
	print("🔍 ScenarioManager: Fetching scenarios for difficulty:", difficulty)
	
	# Check cache first
	if cached_scenarios.has(difficulty):
		print("✅ ScenarioManager: Using cached scenarios (%d cached)" % cached_scenarios[difficulty].size())
		return cached_scenarios[difficulty]
	
	# Get Firebase authentication token
	var Firebase = get_node_or_null("/root/Firebase")
	if not Firebase:
		push_error("❌ ScenarioManager: Firebase singleton not found")
		emit_signal("scenario_load_failed", "Firebase not initialized")
		return []
	
	if Firebase.id_token == "":
		push_error("❌ ScenarioManager: Not authenticated with Firebase")
		push_error("   UID: %s" % Firebase.uid)
		emit_signal("scenario_load_failed", "Not authenticated - no ID token")
		return []
	
	print("✅ ScenarioManager: Firebase authenticated")
	print("   UID: %s" % Firebase.uid)
	print("   Token length: %d chars" % Firebase.id_token.length())
	
	# Build Firestore query URL - fetch all documents in scenarios collection
	var query_url = (FS_BASE % PROJECT_ID) + "/scenarios?pageSize=100&key=" + API_KEY
	var headers := []
	
	print("🌐 ScenarioManager: Requesting:", query_url)
	
	var http := HTTPRequest.new()
	add_child(http)
	
	var err := http.request(query_url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		push_error("❌ ScenarioManager: HTTP request failed with error code: %d" % err)
		http.queue_free()
		emit_signal("scenario_load_failed", "HTTP request failed: " + str(err))
		return []
	
	var result = await http.request_completed
	var response_code: int = result[1]
	var body_bytes: PackedByteArray = result[3]
	var response_text := body_bytes.get_string_from_utf8()
	
	http.queue_free()
	
	print("📡 ScenarioManager: Response code:", response_code)
	print("📄 ScenarioManager: Response length:", response_text.length(), "bytes")
	
	if response_code != 200:
		push_error("❌ ScenarioManager: Failed to fetch scenarios (HTTP %d)" % response_code)
		push_error("   Response: %s" % response_text.substr(0, 500))
		emit_signal("scenario_load_failed", "HTTP error %d: %s" % [response_code, response_text.substr(0, 100)])
		return []
	
	# Parse Firestore response
	print("🔄 ScenarioManager: Parsing response...")
	var scenarios = _parse_firestore_scenarios(response_text, difficulty)
	
	if scenarios.size() == 0:
		print("⚠️ ScenarioManager: No scenarios matched difficulty filter: %s" % difficulty)
		print("   Check if your documents have 'difficulty' field set to '%s'" % difficulty)
	
	# Cache the results
	cached_scenarios[difficulty] = scenarios
	
	print("✅ ScenarioManager: Loaded %d scenarios for '%s'" % [scenarios.size(), difficulty])
	emit_signal("scenarios_loaded", scenarios)
	
	return scenarios
	
func _parse_firestore_scenarios(response_text: String, filter_difficulty: String) -> Array:
	"""Parse Firestore response and convert to scenario array"""
	var json = JSON.parse_string(response_text)
	
	if not json:
		push_error("❌ ScenarioManager: Failed to parse JSON response")
		return []
	
	if not json.has("documents"):
		print("⚠️ ScenarioManager: No 'documents' field in response")
		print("   Response keys:", json.keys())
		return []
	
	var all_documents = json["documents"]
	print("📊 ScenarioManager: Found %d total documents in database" % all_documents.size())
	
	var scenarios := []
	var skipped_count := 0
	
	for doc in all_documents:
		var fields = doc.get("fields", {})
		var doc_id = doc["name"].split("/")[-1]
		
		# Extract scenario data from Firestore format
		var difficulty = _get_firestore_value(fields, "difficulty", "")
		var active = _get_firestore_value(fields, "active", false)
		
		print("   Document '%s': difficulty='%s', active=%s" % [doc_id, difficulty, active])
		
		# Filter by difficulty and active status
		if difficulty != filter_difficulty:
			print("      ❌ Skipped (difficulty mismatch: want '%s', got '%s')" % [filter_difficulty, difficulty])
			skipped_count += 1
			continue
		
		if not active:
			print("      ❌ Skipped (not active)")
			skipped_count += 1
			continue
		
		var scenario := {
			"id": doc_id,
			"type": _get_firestore_value(fields, "type", "email"),
			"difficulty": difficulty,
			"scenario_name": _get_firestore_value(fields, "scenario_name", "Unknown"),
			"from": _get_firestore_value(fields, "from", ""),
			"subject": _get_firestore_value(fields, "subject", ""),
			"date": _get_firestore_value(fields, "date", ""),
			"body": _get_firestore_value(fields, "body", ""),
			"is_phishing": _get_firestore_value(fields, "is_phishing", false),
			"red_flags": _get_firestore_array(fields, "red_flags"),
			"green_flags": _get_firestore_array(fields, "green_flags"),
			"correct_answer": _get_firestore_value(fields, "correct_answer", 0),
			"points": _get_firestore_value(fields, "points", 50),
			"active": active,
			"order": _get_firestore_value(fields, "order", 0)
		}
		
		scenarios.append(scenario)
		print("      ✅ Added scenario: %s" % scenario.scenario_name)
	
	print("📊 ScenarioManager: Matched %d scenarios, skipped %d" % [scenarios.size(), skipped_count])
	
	# Sort by order field
	scenarios.sort_custom(func(a, b): return a.order < b.order)
	
	return scenarios
	
func _get_firestore_value(fields: Dictionary, key: String, default = null):
	"""Extract value from Firestore field format"""
	if not fields.has(key):
		return default
	
	var field = fields[key]
	
	# Handle different Firestore types
	if field.has("stringValue"):
		return field["stringValue"]
	elif field.has("integerValue"):
		return int(field["integerValue"])
	elif field.has("booleanValue"):
		return field["booleanValue"]
	elif field.has("doubleValue"):
		return float(field["doubleValue"])
	
	return default

func _get_firestore_array(fields: Dictionary, key: String) -> Array:
	"""Extract array from Firestore arrayValue format"""
	if not fields.has(key):
		return []
	
	var field = fields[key]
	if not field.has("arrayValue") or not field["arrayValue"].has("values"):
		return []
	
	var result := []
	for value in field["arrayValue"]["values"]:
		if value.has("stringValue"):
			result.append(value["stringValue"])
	
	return result

# ========== SAVE USER PROGRESS ==========

func save_scenario_completion(scenario_id: String, score: int, answer_selected: int, is_correct: bool) -> bool:
	"""Save user's completion of a scenario to Firestore"""
	print("💾 ScenarioManager: Saving scenario completion:", scenario_id)
	
	var Firebase = get_node_or_null("/root/Firebase")
	if not Firebase or Firebase.uid == "" or Firebase.id_token == "":
		push_error("❌ ScenarioManager: Not authenticated")
		return false
	
	# Prepare document data
	var completion_data := {
		"fields": {
			"completed": {"booleanValue": true},
			"score": {"integerValue": score},
			"answer_selected": {"integerValue": answer_selected},
			"is_correct": {"booleanValue": is_correct},
			"completed_at": {"timestampValue": Time.get_datetime_string_from_system() + "Z"}
		}
	}
	
	# Save to user_progress/{uid}/scenarios/{scenarioId}
	var doc_path = "/user_progress/%s/scenarios?documentId=%s" % [Firebase.uid, scenario_id]
	var url = (FS_BASE % PROJECT_ID) + doc_path
	var headers := [
		"Authorization: Bearer %s" % Firebase.id_token,
		"Content-Type: application/json"
	]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	var body_text = JSON.stringify(completion_data)
	var err := http.request(url, headers, HTTPClient.METHOD_POST, body_text)
	
	if err != OK:
		push_error("❌ ScenarioManager: Failed to save progress")
		http.queue_free()
		return false
	
	var result = await http.request_completed
	var response_code: int = result[1]
	http.queue_free()
	
	if response_code in [200, 201]:
		print("✅ ScenarioManager: Progress saved successfully")
		await _update_total_score(score)
		return true
	elif response_code == 409:
		# Document already exists, update it
		print("ℹ️ ScenarioManager: Updating existing progress")
		return await _update_scenario_completion(scenario_id, score, answer_selected, is_correct)
	
	push_error("❌ ScenarioManager: Failed to save progress (HTTP %d)" % response_code)
	return false

func _update_scenario_completion(scenario_id: String, score: int, answer_selected: int, is_correct: bool) -> bool:
	"""Update existing scenario completion"""
	var Firebase = get_node_or_null("/root/Firebase")
	if not Firebase:
		return false
	
	var completion_data := {
		"fields": {
			"completed": {"booleanValue": true},
			"score": {"integerValue": score},
			"answer_selected": {"integerValue": answer_selected},
			"is_correct": {"booleanValue": is_correct},
			"completed_at": {"timestampValue": Time.get_datetime_string_from_system() + "Z"}
		}
	}
	
	var doc_path = "/user_progress/%s/scenarios/%s" % [Firebase.uid, scenario_id]
	var url = (FS_BASE % PROJECT_ID) + doc_path
	var headers := [
		"Authorization: Bearer %s" % Firebase.id_token,
		"Content-Type: application/json"
	]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	var body_text = JSON.stringify(completion_data)
	var err := http.request(url, headers, HTTPClient.METHOD_PATCH, body_text)
	
	if err != OK:
		http.queue_free()
		return false
	
	var result = await http.request_completed
	var response_code: int = result[1]
	http.queue_free()
	
	return response_code == 200

func _update_total_score(points_earned: int) -> void:
	"""Update user's total score in leaderboard"""
	var Firebase = get_node_or_null("/root/Firebase")
	if not Firebase:
		return
	
	# Fetch current score first (simplified - should be cached in production)
	# For now, just increment
	
	var leaderboard_data := {
		"fields": {
			"displayName": {"stringValue": Firebase.display_name},
			"total_score": {"integerValue": points_earned},  # Should be += current score
			"last_updated": {"timestampValue": Time.get_datetime_string_from_system() + "Z"}
		}
	}
	
	var url = (FS_BASE % PROJECT_ID) + ("/leaderboard/%s" % Firebase.uid)
	var headers := [
		"Authorization: Bearer %s" % Firebase.id_token,
		"Content-Type: application/json"
	]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	var body_text = JSON.stringify(leaderboard_data)
	await http.request(url, headers, HTTPClient.METHOD_PATCH, body_text)
	http.queue_free()

# ========== GET USER PROGRESS ==========

func get_completed_scenarios() -> Dictionary:
	"""Get all scenarios completed by current user"""
	print("📖 ScenarioManager: Fetching user progress")
	
	var Firebase = get_node_or_null("/root/Firebase")
	if not Firebase or Firebase.uid == "" or Firebase.id_token == "":
		push_error("❌ ScenarioManager: Not authenticated")
		return {}
	
	var url = (FS_BASE % PROJECT_ID) + ("/user_progress/%s/scenarios" % Firebase.uid)
	var headers := ["Authorization: Bearer %s" % Firebase.id_token]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	var err := http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		return {}
	
	var result = await http.request_completed
	var response_code: int = result[1]
	var body_bytes: PackedByteArray = result[3]
	var response_text := body_bytes.get_string_from_utf8()
	
	http.queue_free()
	
	if response_code != 200:
		return {}
	
	# Parse and return completed scenarios
	var json = JSON.parse_string(response_text)
	if not json or not json.has("documents"):
		return {}
	
	var completed := {}
	for doc in json["documents"]:
		var scenario_id = doc["name"].split("/")[-1]
		var fields = doc.get("fields", {})
		completed[scenario_id] = {
			"completed": _get_firestore_value(fields, "completed", false),
			"score": _get_firestore_value(fields, "score", 0),
			"is_correct": _get_firestore_value(fields, "is_correct", false)
		}
	
	print("✅ ScenarioManager: Loaded progress for %d scenarios" % completed.size())
	emit_signal("user_progress_loaded", completed)
	
	return completed

# ========== UTILITY FUNCTIONS ==========

func get_random_scenarios(difficulty: String, count: int) -> Array:
	"""Get random scenarios for variety"""
	var all_scenarios = await fetch_scenarios(difficulty)
	
	if all_scenarios.size() <= count:
		return all_scenarios
	
	all_scenarios.shuffle()
	return all_scenarios.slice(0, count)

func clear_cache():
	"""Clear cached scenarios (useful for testing)"""
	cached_scenarios.clear()
	print("🗑️ ScenarioManager: Cache cleared")
