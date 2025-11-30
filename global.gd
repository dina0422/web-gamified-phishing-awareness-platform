extends Node

## Global game state manager
## Add this as autoload: Project > Project Settings > Autoload > Name: Global, Path: res://global.gd

# 🔄 Fresh start flag - set to true when starting from role selection
# This tells quest_tracker to clear previous progress
var fresh_start_requested: bool = false

# Currently selected role
var selected_role: String = ""

# Player data
var player_name: String = ""
var player_uid: String = ""

# Current session data
var current_session_score: int = 0
var current_session_start_time: int = 0

# Debug flag
var debug_mode: bool = false

func _ready():
	print("🌍 Global state manager initialized")

func start_fresh_session(role: String):
	"""Call this when starting a new game session"""
	fresh_start_requested = true
	selected_role = role
	current_session_score = 0
	current_session_start_time = Time.get_unix_time_from_system()
	print("🆕 Fresh session started for role: %s" % role)

func consume_fresh_start_flag() -> bool:
	"""Check and reset the fresh start flag"""
	var was_fresh = fresh_start_requested
	fresh_start_requested = false  # Reset after reading
	return was_fresh

func reset_session():
	"""Reset current session data"""
	current_session_score = 0
	current_session_start_time = 0
	print("🔄 Session data reset")
