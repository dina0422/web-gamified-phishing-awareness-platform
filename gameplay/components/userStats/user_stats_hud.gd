extends CanvasLayer

## User Stats HUD - Displays player name, score, and current level
## This is a reusable component that can be added to any game level

# Node references
@onready var player_name_label: Label = $Panel/VBoxContainer/PlayerInfo/PlayerName
@onready var score_label: Label = $Panel/VBoxContainer/ScoreInfo/Score
@onready var role_label: Label = $Panel/VBoxContainer/RoleInfo/Role
@onready var settings_button: Button = $SettingsButton

# Current score tracking
var current_score: int = 0

# Role display names (matching your role_selection system)
const ROLE_NAMES := {
	"beginner": "Civilian 👨‍💼",
	"intermediate": "Office Staff 💼",
	"professional": "Cybersecurity Pro 🛡️"
}

func _ready() -> void:
	# Connect to Firebase signals
	Firebase.authentication_completed.connect(_on_authentication_completed)
	Firebase.display_name_updated.connect(_on_display_name_updated)
	Firebase.display_name_loaded.connect(_on_display_name_loaded)
	
	# Connect settings button with error checking
	print("\n=== Settings Button Debug ===")
	if settings_button:
		print("✅ Settings button found: ", settings_button)
		print("Settings button path: ", settings_button.get_path())
		settings_button.pressed.connect(_on_settings_pressed)
		print("✅ Settings button signal connected")
		
		# Make sure button is visible and enabled
		settings_button.visible = true
		settings_button.disabled = false
		print("Settings button visible: ", settings_button.visible)
		print("Settings button disabled: ", settings_button.disabled)
	else:
		push_error("❌ Settings button not found!")
	print("============================\n")
	
	# Wait for Firebase to be ready
	if Firebase.uid == "":
		# Not authenticated yet, wait for signal
		player_name_label.text = "Loading..."
		print("⏳ Waiting for Firebase authentication...")
	else:
		# Already authenticated, load immediately
		print("✅ Firebase already authenticated, loading player info...")
		load_player_info()
	
	# Try to load saved progress for this level
	load_level_progress()

func _on_authentication_completed(success: bool) -> void:
	"""Called when Firebase authentication completes"""
	print("🔔 Authentication completed signal received: ", success)
	if success:
		load_player_info()
	else:
		player_name_label.text = "Error"

func _on_display_name_updated(name: String) -> void:
	"""Called when display name is updated"""
	print("🔔 Display name updated signal received: ", name)
	player_name_label.text = name

func _on_display_name_loaded(name: String) -> void:
	"""Called when display name is loaded from Firestore"""
	print("🔔 Display name loaded signal received: ", name)
	player_name_label.text = name

func load_player_info() -> void:
	"""Load player name from Firebase"""
	print("\n=== Loading Player Info ===")
	print("Firebase UID: ", Firebase.uid)
	print("Firebase Display Name: ", Firebase.display_name)
	
	if Firebase.display_name != "":
		player_name_label.text = Firebase.display_name
		print("✅ Display name set to: ", Firebase.display_name)
	else:
		player_name_label.text = "Anonymous"
		print("⚠️ No display name found, using 'Anonymous'")
		
		# Try to load from Firestore if we have a session but no name
		if Firebase.uid != "":
			print("🔄 Attempting to load display name from Firestore...")
			await Firebase.load_display_name_from_firestore()
	
	# Detect current level from scene path
	var scene_path := get_tree().current_scene.scene_file_path
	var level_type := detect_level_type(scene_path)
	
	if level_type in ROLE_NAMES:
		role_label.text = ROLE_NAMES[level_type]
	else:
		role_label.text = "Unknown"
	
	print("===========================\n")

func detect_level_type(scene_path: String) -> String:
	"""Detect which level we're in based on scene path"""
	if "beginner" in scene_path.to_lower():
		return "beginner"
	elif "intermediate" in scene_path.to_lower():
		return "intermediate"
	elif "professional" in scene_path.to_lower():
		return "professional"
	return ""

func load_level_progress() -> void:
	"""Load saved progress for current level from Firebase (optional)"""
	# This would connect to your Firebase progress tracking
	# For now, just reset to 0
	update_score(0)

func update_score(new_score: int) -> void:
	"""Update the displayed score"""
	current_score = new_score
	score_label.text = str(current_score)

func add_score(points: int) -> void:
	"""Add points to the current score"""
	current_score += points
	score_label.text = str(current_score)
	
	# Optional: Add a brief animation effect
	animate_score_change()
	
	# Auto-save progress to Firebase
	save_progress()

func subtract_score(points: int) -> void:
	"""Subtract points from score (for incorrect answers)"""
	current_score = max(0, current_score - points)  # Don't go below 0
	score_label.text = str(current_score)
	animate_score_change()
	save_progress()

func animate_score_change() -> void:
	"""Brief scale animation when score changes"""
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	
	# Scale up then back to normal
	tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.3)

func save_progress() -> void:
	"""Save current progress to Firebase"""
	if Firebase.uid == "":
		return  # Not signed in yet
	
	var level_type := detect_level_type(get_tree().current_scene.scene_file_path)
	
	# Save to Firebase Firestore
	var progress_data := {
		"fields": {
			"level": {"stringValue": level_type},
			"score": {"integerValue": str(current_score)},
			"lastPlayed": {"timestampValue": Time.get_datetime_string_from_system()},
			"displayName": {"stringValue": Firebase.display_name}
		}
	}
	
	# You can extend Firebase manager to handle this, or do it here:
	# Firebase.save_progress(level_type, current_score)
	
	print("💾 Progress saved: %s - Score: %d" % [level_type, current_score])

func get_current_score() -> int:
	"""Public method to get current score"""
	return current_score

func reset_score() -> void:
	"""Reset score to 0"""
	update_score(0)

# ============================================
# SETTINGS MENU FUNCTIONS
# ============================================

func _on_settings_pressed() -> void:
	"""Show settings/pause menu"""
	print("\n🎮 Settings button pressed!")
	show_settings_menu()

func show_settings_menu() -> void:
	"""Display a popup with game options"""
	print("📋 Creating settings menu...")
	
	var popup := PopupMenu.new()
	popup.name = "SettingsPopup"
	
	# Add menu items
	popup.add_item("💾 Save Game", 0)
	popup.add_item("🔊 Sound Settings", 1)
	popup.add_separator()
	popup.add_item("🏠 Return to Main Menu", 2)
	popup.add_item("🚪 Exit Game", 3)
	
	# Connect the selection signal
	popup.id_pressed.connect(_on_settings_menu_item_selected)
	
	# Position popup near the button
	popup.position = settings_button.global_position + Vector2(0, settings_button.size.y + 5)
	
	print("Popup position: ", popup.position)
	print("Button position: ", settings_button.global_position)
	
	# Add to scene
	add_child(popup)
	
	# Show the popup
	popup.popup()
	print("✅ Popup should now be visible")
	
	# Pause the game while menu is open
	get_tree().paused = true
	print("⏸️  Game paused")

func _on_settings_menu_item_selected(id: int) -> void:
	"""Handle settings menu selection"""
	print("Menu item selected: ", id)
	
	# Unpause the game
	get_tree().paused = false
	
	match id:
		0:  # Save Game
			save_progress()
			show_notification("Game Saved!", Color.GREEN)
		1:  # Sound Settings
			show_notification("Sound settings coming soon!", Color.YELLOW)
		2:  # Return to Main Menu
			confirm_exit_to_menu()
		3:  # Exit Game
			confirm_quit_game()

func confirm_exit_to_menu() -> void:
	"""Show confirmation dialog before returning to main menu"""
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Save progress and return to main menu?"
	dialog.ok_button_text = "Yes, Save & Exit"
	dialog.cancel_button_text = "Cancel"
	
	dialog.confirmed.connect(func():
		save_progress()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main-menu.tscn")
	)
	
	dialog.canceled.connect(func():
		get_tree().paused = false
	)
	
	add_child(dialog)
	dialog.popup_centered()

func confirm_quit_game() -> void:
	"""Show confirmation dialog before quitting"""
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Save progress and quit the game?"
	dialog.ok_button_text = "Yes, Save & Quit"
	dialog.cancel_button_text = "Cancel"
	
	dialog.confirmed.connect(func():
		save_progress()
		get_tree().quit()
	)
	
	dialog.canceled.connect(func():
		get_tree().paused = false
	)
	
	add_child(dialog)
	dialog.popup_centered()

func show_notification(message: String, color: Color = Color.WHITE) -> void:
	"""Display a temporary notification"""
	var notification := Label.new()
	notification.text = message
	notification.add_theme_color_override("font_color", color)
	notification.add_theme_font_size_override("font_size", 20)
	
	# Position at top center
	notification.position = Vector2(
		get_viewport().get_visible_rect().size.x / 2 - 100,
		50
	)
	
	add_child(notification)
	
	# Fade out animation
	var tween := create_tween()
	tween.tween_property(notification, "modulate:a", 0.0, 2.0).set_delay(1.0)
	tween.tween_callback(notification.queue_free)

# ============================================
# MULTILINGUAL SUPPORT (Optional Enhancement)
# ============================================

func set_language(lang_code: String) -> void:
	"""Update HUD text based on selected language"""
	match lang_code:
		"en":
			$Panel/VBoxContainer/PlayerInfo/PlayerNameLabel.text = "Player:"
			$Panel/VBoxContainer/ScoreInfo/ScoreLabel.text = "Score:"
			$Panel/VBoxContainer/RoleInfo/RoleLabel.text = "Level:"
		"ms":  # Malay
			$Panel/VBoxContainer/PlayerInfo/PlayerNameLabel.text = "Pemain:"
			$Panel/VBoxContainer/ScoreInfo/ScoreLabel.text = "Skor:"
			$Panel/VBoxContainer/RoleInfo/RoleLabel.text = "Tahap:"
		"zh":  # Chinese
			$Panel/VBoxContainer/PlayerInfo/PlayerNameLabel.text = "玩家:"
			$Panel/VBoxContainer/ScoreInfo/ScoreLabel.text = "分数:"
			$Panel/VBoxContainer/RoleInfo/RoleLabel.text = "级别:"

# ============================================
# DEBUG FUNCTIONS
# ============================================

func _input(event: InputEvent) -> void:
	"""Debug shortcuts and alternative input handling"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			print_debug_info()
		elif event.keycode == KEY_ESCAPE:
			# Quick access to settings with ESC key
			print("ESC key pressed - opening settings")
			_on_settings_pressed()

# Alternative: Handle button press in _unhandled_input as backup
func _unhandled_input(event: InputEvent) -> void:
	"""Backup input handler for settings button"""
	if event is InputEventMouseButton and event.pressed:
		if settings_button and settings_button.get_global_rect().has_point(event.position):
			print("🖱️ Mouse clicked on settings button area")
			_on_settings_pressed()

func print_debug_info() -> void:
	"""Print HUD debug information"""
	print("\n=== HUD DEBUG INFO ===")
	print("Firebase UID: ", Firebase.uid)
	print("Firebase Display Name: ", Firebase.display_name)
	print("HUD Display Name: ", player_name_label.text)
	print("Current Score: ", current_score)
	print("Current Scene: ", get_tree().current_scene.scene_file_path)
	print("Detected Level: ", detect_level_type(get_tree().current_scene.scene_file_path))
	print("\nSettings Button Info:")
	if settings_button:
		print("  - Exists: Yes")
		print("  - Visible: ", settings_button.visible)
		print("  - Disabled: ", settings_button.disabled)
		print("  - Position: ", settings_button.position)
		print("  - Global Position: ", settings_button.global_position)
		print("  - Size: ", settings_button.size)
		print("  - Text: ", settings_button.text)
	else:
		print("  - Exists: No")
	print("=====================\n")
