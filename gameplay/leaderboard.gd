extends Control

## Enhanced Leaderboard System
## Features:
## - Role-based completion tracking (Beginner/Intermediate/Professional)
## - Real-time Firebase integration for scores
## - Filtering by role
## - Sorting options (score, name, date)
## - Achievement badges
## - Main menu navigation

# ============================================
# NODE REFERENCES
# ============================================

@onready var title_label: Label = $Label
@onready var leaderboard_container: GridContainer = $VBoxContainer/GridContainer
@onready var back_button: Button = $BackButton
@onready var restart_button: Button = $RestartButton
@onready var role_filter_options: OptionButton = $ControlsContainer/RoleFilterOptions
@onready var sort_options: OptionButton = $ControlsContainer/SortOptions
@onready var player_rank_panel: Panel = $PlayerRankPanel
@onready var rank_label: Label = $PlayerRankPanel/HBoxContainer/RankLabel
@onready var player_name_label: Label = $PlayerRankPanel/HBoxContainer/PlayerNameLabel
@onready var player_score_label: Label = $PlayerRankPanel/HBoxContainer/PlayerScoreLabel
@onready var badge_icon: TextureRect = $PlayerRankPanel/HBoxContainer/BadgeIcon
@onready var completion_popup: Panel = $CompletionPopup
@onready var refresh_button: Button = $ControlsContainer/RefreshButton

# ============================================
# CONSTANTS
# ============================================

const ROLE_NAMES := {
	"all": "All Roles",
	"beginner": "Civilian",
	"intermediate": "Office Staff",
	"professional": "Cybersecurity Pro"
}

# Badge thresholds for each role
const BADGE_THRESHOLDS := {
	"beginner": {
		"gold": 250,    # Perfect score
		"silver": 200,   # 80%+
		"bronze": 150    # 60%+
	},
	"intermediate": {
		"gold": 500,
		"silver": 400,
		"bronze": 300
	},
	"professional": {
		"gold": 1000,
		"silver": 800,
		"bronze": 600
	}
}

# Badge emojis
const BADGE_ICONS := {
	"gold": "[GOLD]",
	"silver": "[SILVER]",
	"bronze": "[BRONZE]",
	"none": "[BADGE]"
}

# ============================================
# STATE VARIABLES
# ============================================

var current_role_filter: String = "all"
var current_sort_mode: String = "score_desc"  # score_desc, score_asc, name, date
var leaderboard_data: Array = []
var player_data: Dictionary = {}
var is_showing_completion: bool = false

# ============================================
# INITIALIZATION
# ============================================

func _ready() -> void:
	print("\n=== Leaderboard Initializing ===")
	
	# Verify critical nodes exist
	if not leaderboard_container:
		push_error("âš ï¸ CRITICAL: leaderboard_container (GridContainer) not found!")
		push_error("Expected path: $Label/VBoxContainer/GridContainer")
		return
	
	# Setup UI components
	setup_filters()
	setup_buttons()
	
	# Check if we're showing completion screen
	var completion_role = get_completion_role_from_meta()
	if completion_role != "":
		is_showing_completion = true
		show_role_completion(completion_role)
	else:
		# Normal leaderboard view
		load_leaderboard_data()
	
	print("=================================\n")

func setup_filters() -> void:
	"""Setup filter dropdown options"""
	if not role_filter_options:
		push_error("âš ï¸ RoleFilterOptions not found!")
		return
	
	role_filter_options.clear()
	role_filter_options.add_item(ROLE_NAMES["all"], 0)
	role_filter_options.add_item(ROLE_NAMES["beginner"], 1)
	role_filter_options.add_item(ROLE_NAMES["intermediate"], 2)
	role_filter_options.add_item(ROLE_NAMES["professional"], 3)
	role_filter_options.item_selected.connect(_on_role_filter_changed)
	
	# Setup sort options
	if sort_options:
		sort_options.clear()
		sort_options.add_item("Top Score (High to Low)", 0)
		sort_options.add_item("Score (Low to High)", 1)
		sort_options.add_item("Name (A-Z)", 2)
		sort_options.add_item("Recent First", 3)
		sort_options.item_selected.connect(_on_sort_changed)

func setup_buttons() -> void:
	"""Connect button signals"""
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	
	if refresh_button:
		refresh_button.pressed.connect(_on_refresh_pressed)

# ============================================
# FIREBASE DATA LOADING
# ============================================

func load_leaderboard_data() -> void:
	"""Load leaderboard data from Firebase"""
	print("ðŸ“¥ Firebase: Loading leaderboard data from Firebase...")	
	if Firebase.id_token == "":
		push_error("âš ï¸ Cannot load leaderboard - not authenticated")
		display_empty_leaderboard()
		return
	
	# Build Firestore query URL
	var query_url := build_leaderboard_query_url()
	var headers := ["Authorization: Bearer %s" % Firebase.id_token]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	var err := http.request(query_url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		push_error("âš ï¸ Failed to start leaderboard request")
		http.queue_free()
		display_empty_leaderboard()
		return
	
	var result = await http.request_completed
	var response_code: int = result[1]
	var body_bytes: PackedByteArray = result[3]
	var response_text: String = body_bytes.get_string_from_utf8()
	
	http.queue_free()
	
	if response_code == 200:
		parse_leaderboard_response(response_text)
	else:
		push_error("âš ï¸ Leaderboard load failed (HTTP %d): %s" % [response_code, response_text])
		display_empty_leaderboard()

func build_leaderboard_query_url() -> String:
	"""Build Firebase Firestore query URL with filters"""
	var base_url := Firebase.FS_BASE % Firebase.PROJECT_ID
	var collection := base_url + "/progress"
	
	# Add role filter if not "all"
	if current_role_filter != "all":
		# Use Firestore structured query for filtering
		collection += "?structuredQuery.where.fieldFilter.field.fieldPath=role"
		collection += "&structuredQuery.where.fieldFilter.op=EQUAL"
		collection += "&structuredQuery.where.fieldFilter.value.stringValue=%s" % current_role_filter
	
	return collection

func parse_leaderboard_response(response_text: String) -> void:
	"""Parse Firebase response and populate leaderboard"""
	var json_result = JSON.parse_string(response_text)
	
	if not json_result or not json_result.has("documents"):
		print("â„¹ï¸ No leaderboard data found")
		display_empty_leaderboard()
		return
	
	leaderboard_data.clear()
	
	# Parse each document
	for doc in json_result["documents"]:
		if not doc.has("fields"):
			continue
		
		var fields = doc["fields"]
		var entry := {
			"uid": doc["name"].split("/")[-1],  # Extract UID from document path
			"displayName": fields.get("displayName", {}).get("stringValue", "Anonymous"),
			"role": fields.get("role", {}).get("stringValue", "beginner"),
			"score": int(fields.get("score", {}).get("integerValue", "0")),
			"lastPlayed": fields.get("lastPlayed", {}).get("timestampValue", ""),
			"completed": fields.get("completed", {}).get("booleanValue", false)
		}
		
		# Only include completed entries
		if entry["completed"]:
			leaderboard_data.append(entry)
	
	# Check if current player is in the data
	find_player_rank()
	
	# Sort and display
	sort_leaderboard_data()
	display_leaderboard()
	
	print("âœ… Loaded %d leaderboard entries" % leaderboard_data.size())

# ============================================
# DATA SORTING
# ============================================

func sort_leaderboard_data() -> void:
	"""Sort leaderboard based on current sort mode"""
	match current_sort_mode:
		"score_desc":
			leaderboard_data.sort_custom(func(a, b): return a["score"] > b["score"])
		"score_asc":
			leaderboard_data.sort_custom(func(a, b): return a["score"] < b["score"])
		"name":
			leaderboard_data.sort_custom(func(a, b): return a["displayName"].to_lower() < b["displayName"].to_lower())
		"date":
			leaderboard_data.sort_custom(func(a, b): return a["lastPlayed"] > b["lastPlayed"])

# ============================================
# UI DISPLAY
# ============================================

func display_leaderboard() -> void:
	"""Display leaderboard entries in the grid"""
	# Verify container exists
	if not leaderboard_container:
		push_error("âš ï¸ Cannot display leaderboard - container is null!")
		return
	
	# Clear existing entries (except header)
	clear_leaderboard_grid()
	
	# Display top 10 (or all if less than 10)
	var display_count: int = min(10, leaderboard_data.size())
	
	for i in range(display_count):
		var entry = leaderboard_data[i]
		var rank: int = i + 1
		
		# Rank label
		var rank_label_node := create_leaderboard_label("#%d" % rank)
		highlight_label(rank_label_node) if entry["uid"] == Firebase.uid else null
		leaderboard_container.add_child(rank_label_node)
		
		# Player name label with badge
		var badge = get_badge_for_score(entry["score"], entry["role"])
		var badge_emoji = BADGE_ICONS[badge]
		var name_text = "%s %s" % [badge_emoji, entry["displayName"]]
		var name_label := create_leaderboard_label(name_text)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		highlight_label(name_label) if entry["uid"] == Firebase.uid else null
		leaderboard_container.add_child(name_label)
		
		# Score label
		var score_label := create_leaderboard_label(str(entry["score"]))
		highlight_label(score_label) if entry["uid"] == Firebase.uid else null
		leaderboard_container.add_child(score_label)

func create_leaderboard_label(text: String, centered: bool = true) -> Label:
	"""Helper to create consistently styled labels"""
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	
	if centered:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	return label

func highlight_label(label: Label) -> void:
	"""Highlight a label for current player"""
	label.add_theme_color_override("font_color", Color.YELLOW)

func clear_leaderboard_grid() -> void:
	"""Delete all entries except header row"""
	if not leaderboard_container:
		push_error("âš ï¸ Cannot clear grid - leaderboard_container is null!")
		return
	
	var children = leaderboard_container.get_children()
	# Keep first 3 children (header: Rank, Player, Score)
	for i in range(3, children.size()):
		children[i].queue_free()

func display_empty_leaderboard() -> void:
	"""Show message when no data available"""
	if not leaderboard_container:
		return
	
	clear_leaderboard_grid()
	
	var message := create_leaderboard_label("No data available", true)
	message.add_theme_color_override("font_color", Color.GRAY)
	leaderboard_container.add_child(message)

# ============================================
# PLAYER RANK TRACKING
# ============================================

func find_player_rank() -> void:
	"""Find current player's rank in the leaderboard"""
	if not player_rank_panel:
		return
	
	for i in range(leaderboard_data.size()):
		if leaderboard_data[i]["uid"] == Firebase.uid:
			player_data = leaderboard_data[i]
			display_player_rank(i + 1)
			return
	
	# Player not in leaderboard yet
	player_rank_panel.hide()

func display_player_rank(rank: int) -> void:
	"""Display player's rank in the dedicated panel"""
	if not player_rank_panel:
		return
	
	player_rank_panel.show()
	rank_label.text = "#%d" % rank
	player_name_label.text = player_data["displayName"]
	player_score_label.text = str(player_data["score"])
	
	# Show badge
	var badge = get_badge_for_score(player_data["score"], player_data["role"])
	if badge_icon:
		# You can replace this with actual texture if you have badge images
		badge_icon.visible = false  # Hide for now, or set texture

# ============================================
# BADGE SYSTEM
# ============================================

func get_badge_for_score(score: int, role: String) -> String:
	"""Determine badge level based on score and role"""
	if not BADGE_THRESHOLDS.has(role):
		return "none"
	
	var thresholds = BADGE_THRESHOLDS[role]
	
	if score >= thresholds["gold"]:
		return "gold"
	elif score >= thresholds["silver"]:
		return "silver"
	elif score >= thresholds["bronze"]:
		return "bronze"
	else:
		return "none"

# ============================================
# ROLE COMPLETION FLOW
# ============================================

func show_role_completion(role: String) -> void:
	"""Show completion screen after finishing a role"""
	print("ðŸŽ‰ Showing completion for role: ", role)
	
	# Load player's completion data
	await load_completion_data(role)
	
	# Show completion popup
	if completion_popup:
		show_completion_popup(role)

func load_completion_data(role: String) -> void:
	"""Load player's completion data for the specified role"""
	if Firebase.id_token == "":
		return
	
	var doc_path := (Firebase.FS_BASE % Firebase.PROJECT_ID) + "/progress/%s_%s" % [Firebase.uid, role]
	var headers := ["Authorization: Bearer %s" % Firebase.id_token]
	
	var http := HTTPRequest.new()
	add_child(http)
	
	var err := http.request(doc_path, headers, HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		return
	
	var result = await http.request_completed
	var response_code: int = result[1]
	var body_bytes: PackedByteArray = result[3]
	var response_text: String = body_bytes.get_string_from_utf8()
	
	http.queue_free()
	
	if response_code == 200:
		var json = JSON.parse_string(response_text)
		if json and json.has("fields"):
			var fields = json["fields"]
			player_data = {
				"displayName": Firebase.display_name,
				"role": role,
				"score": int(fields.get("score", {}).get("integerValue", "0")),
				"completed": true
			}

func show_completion_popup(role: String) -> void:
	"""Display completion popup with stats and badge"""
	if not completion_popup:
		return
	
	completion_popup.show()
	
	# You can customize the popup content here
	var badge = get_badge_for_score(player_data.get("score", 0), role)
	var badge_emoji = BADGE_ICONS[badge]
	
	# This assumes you have labels in the completion popup
	# Adjust node paths as needed
	var title_label_node = completion_popup.get_node_or_null("VBoxContainer/TitleLabel")
	var score_label_node = completion_popup.get_node_or_null("VBoxContainer/ScoreLabel")
	var badge_label_node = completion_popup.get_node_or_null("VBoxContainer/BadgeLabel")
	
	if title_label_node:
		title_label_node.text = "ðŸŽ‰ %s Completed!" % ROLE_NAMES.get(role, role)
	if score_label_node:
		score_label_node.text = "Final Score: %d" % player_data.get("score", 0)
	if badge_label_node:
		badge_label_node.text = "Badge Earned: %s %s" % [badge_emoji, badge.capitalize()]
	
	# Load full leaderboard to show rank
	load_leaderboard_data()

func get_completion_role_from_meta() -> String:
	"""Check if we're showing completion for a specific role"""
	# This would be set when transitioning from gameplay
	# For example: get_tree().current_scene.set_meta("completion_role", "beginner")
	if get_tree().current_scene.has_meta("completion_role"):
		return get_tree().current_scene.get_meta("completion_role")
	return ""

# ============================================
# SIGNAL HANDLERS
# ============================================

func _on_role_filter_changed(index: int) -> void:
	"""Handle role filter dropdown change"""
	var roles = ["all", "beginner", "intermediate", "professional"]
	current_role_filter = roles[index]
	print("ðŸ”„ Filter changed to: ", current_role_filter)
	load_leaderboard_data()

func _on_sort_changed(index: int) -> void:
	"""Handle sort option change"""
	var sort_modes = ["score_desc", "score_asc", "name", "date"]
	current_sort_mode = sort_modes[index]
	print("ðŸ”„ Sort changed to: ", current_sort_mode)
	sort_leaderboard_data()
	display_leaderboard()

func _on_back_pressed() -> void:
	"""Return to main menu"""
	print("â¬…ï¸ Returning to main menu")
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_restart_pressed() -> void:
	"""Restart current role"""
	if is_showing_completion and player_data.has("role"):
		var role = player_data["role"]
		print("Restarting role: %s" % role)
		
		# CRITICAL: Reset quest progress before restarting
		# Load quest_tracker script and call static reset method
		var quest_tracker_script = load("res://quest_tracker.gd")
		if quest_tracker_script:
			quest_tracker_script.reset_role_progress_static(role)
			print("Quest progress cleared for: %s" % role)
		
		# Determine which scene to load based on role
		match role:
			"beginner":
				get_tree().change_scene_to_file("res://living_room.tscn")
			"intermediate":
				get_tree().change_scene_to_file("res://office.tscn")
			"professional":
				get_tree().change_scene_to_file("res://soc_office.tscn")
	else:
		print("No active role to restart")

func _on_refresh_pressed() -> void:
	"""Manually refresh leaderboard data"""
	print("ðŸ”„ Refreshing leaderboard...")
	load_leaderboard_data()

# ============================================
# PUBLIC API FOR QUEST SYSTEM
# ============================================

static func show_leaderboard_after_completion(role: String, score: int) -> void:
	"""Called by quest system when player completes a role"""
	print("ðŸŽ¯ Marking role completion: %s with score %d" % [role, score])
	
	# Save completion to Firebase
	await save_completion_to_firebase(role, score)
	
	# Change to leaderboard scene with completion meta
	var leaderboard_scene = load("res://leaderboard.tscn")
	var tree = Engine.get_main_loop() as SceneTree
	tree.change_scene_to_packed(leaderboard_scene)
	tree.current_scene.set_meta("completion_role", role)

static func save_completion_to_firebase(role: String, score: int) -> bool:
	"""Save role completion to Firebase"""
	if Firebase.id_token == "":
		return false
	
	var doc_id = "%s_%s" % [Firebase.uid, role]
	var doc_data := {
		"fields": {
			"displayName": {"stringValue": Firebase.display_name},
			"role": {"stringValue": role},
			"score": {"integerValue": str(score)},
			"completed": {"booleanValue": true},
			"lastPlayed": {"timestampValue": Time.get_datetime_string_from_system()}
		}
	}
	
	var headers := ["Authorization: Bearer %s" % Firebase.id_token]
	var url := (Firebase.FS_BASE % Firebase.PROJECT_ID) + "/progress?documentId=%s" % doc_id
	
	var http := HTTPRequest.new()
	Engine.get_main_loop().current_scene.add_child(http)
	
	var err := http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(doc_data))
	if err != OK:
		http.queue_free()
		return false
	
	var result = await http.request_completed
	http.queue_free()
	
	var response_code: int = result[1]
	return response_code in [200, 201, 409]  # 409 = already exists, that's fine

# ============================================
# DEBUG
# ============================================

func _input(event: InputEvent) -> void:
	"""Debug shortcuts"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F5:
			print("\n=== LEADERBOARD DEBUG ===")
			print("Current Filter: ", current_role_filter)
			print("Current Sort: ", current_sort_mode)
			print("Entries Loaded: ", leaderboard_data.size())
			print("Player UID: ", Firebase.uid)
			print("Player in Data: ", player_data)
			print("========================\n")
