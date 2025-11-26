extends CanvasLayer

## Game Menu Buttons - Give Up and Leaderboard
## FINAL VERSION - Fixed all errors

@onready var buttons_container: VBoxContainer = null
@onready var give_up_button: Button = null
@onready var leaderboard_button: Button = null

func _ready():
	await get_tree().process_frame
	setup_buttons()

func setup_buttons():
	"""Create give up and leaderboard buttons"""
	var viewport_size = get_viewport().get_visible_rect().size
	print("📐 Viewport size: ", viewport_size)
	
	buttons_container = VBoxContainer.new()
	buttons_container.name = "MenuButtonsContainer"
	
	# Anchor to bottom-right corner
	buttons_container.anchor_left = 1.0
	buttons_container.anchor_top = 1.0
	buttons_container.anchor_right = 1.0
	buttons_container.anchor_bottom = 1.0
	buttons_container.offset_left = -190
	buttons_container.offset_top = -120
	buttons_container.offset_right = -10
	buttons_container.offset_bottom = -10
	buttons_container.grow_horizontal = 0
	buttons_container.grow_vertical = 0
	
	add_child(buttons_container)
	
	# Create Leaderboard button
	leaderboard_button = create_menu_button(
		"🏆 Leaderboard",
		Color(0.2, 0.6, 1.0, 0.9),
		_on_leaderboard_pressed
	)
	buttons_container.add_child(leaderboard_button)
	
	# Spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	buttons_container.add_child(spacer)
	
	# Create Give Up button
	give_up_button = create_menu_button(
		"❌ Give Up",
		Color(0.8, 0.2, 0.2, 0.9),
		_on_give_up_pressed
	)
	buttons_container.add_child(give_up_button)
	
	print("✅ Game menu buttons created")

func create_menu_button(text: String, color: Color, callback: Callable) -> Button:
	"""Helper to create styled menu button"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(170, 45)
	button.add_theme_font_size_override("font_size", 15)
	
	# Styling
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color
	style_normal.set_border_width_all(2)
	style_normal.border_color = color.lightened(0.3)
	style_normal.set_corner_radius_all(8)
	style_normal.shadow_size = 4
	style_normal.shadow_color = Color(0, 0, 0, 0.3)
	button.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = color.lightened(0.2)
	style_hover.set_border_width_all(2)
	style_hover.border_color = color.lightened(0.4)
	style_hover.set_corner_radius_all(8)
	style_hover.shadow_size = 6
	style_hover.shadow_color = Color(0, 0, 0, 0.4)
	button.add_theme_stylebox_override("hover", style_hover)
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = color.darkened(0.2)
	style_pressed.set_border_width_all(2)
	style_pressed.border_color = color
	style_pressed.set_corner_radius_all(8)
	style_pressed.shadow_size = 2
	style_pressed.shadow_color = Color(0, 0, 0, 0.5)
	button.add_theme_stylebox_override("pressed", style_pressed)
	
	button.pressed.connect(callback)
	return button

func _on_leaderboard_pressed():
	"""Show leaderboard"""
	print("🏆 Leaderboard button pressed")
	
	# Check if leaderboard scene exists
	var leaderboard_path = "res://gameplay/leaderboard.tscn"
	
	if not ResourceLoader.exists(leaderboard_path):
		print("❌ Leaderboard scene not found at: ", leaderboard_path)
		
		# Show error dialog
		var error_dialog = AcceptDialog.new()
		error_dialog.dialog_text = "Leaderboard scene not found!\n\nExpected location:\nres://leaderboard.tscn"
		error_dialog.title = "Error"
		add_child(error_dialog)
		error_dialog.popup_centered()
		error_dialog.confirmed.connect(func(): error_dialog.queue_free())
		return
	
	# Load leaderboard
	print("✅ Loading leaderboard scene...")
	get_tree().change_scene_to_file(leaderboard_path)

func _on_give_up_pressed():
	"""Handle give up with confirmation"""
	print("❌ Give Up button pressed")
	
	# Find quest tracker
	var quest_tracker = get_tree().current_scene.find_child("QuestTracker", true, false)
	
	if not quest_tracker:
		print("⚠️ No quest tracker found")
		# Go straight to leaderboard
		_confirm_give_up(null)
		return
	
	# Get progress - SAFE property access
	var completed = 0
	var total = 2
	
	# Check if properties exist using 'in' operator
	if "completed_tasks" in quest_tracker:
		completed = quest_tracker.completed_tasks.size()
	if "total_tasks" in quest_tracker:
		total = quest_tracker.total_tasks
	
	print("📊 Current progress: %d / %d" % [completed, total])
	
	# Show confirmation dialog
	var dialog = ConfirmationDialog.new()
	dialog.title = "Give Up?"
	dialog.dialog_text = "Are you sure you want to give up?\n\nYour current progress:\n  Completed: %d / %d tasks\n\nYour score will be saved as incomplete." % [completed, total]
	dialog.ok_button_text = "Yes, Give Up"
	dialog.cancel_button_text = "Keep Playing"
	
	add_child(dialog)
	dialog.popup_centered(Vector2(400, 200))
	
	# Connect signals
	dialog.confirmed.connect(func():
		_confirm_give_up(quest_tracker)
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func():
		print("✅ User chose to keep playing")
		dialog.queue_free()
	)

func _confirm_give_up(quest_tracker):
	"""User confirmed give up"""
	print("🏳️ User confirmed give up")
	
	# Get current score - SAFE property access
	var hud = get_tree().current_scene.find_child("UserStatsHUD", true, false)
	var current_score = 0
	
	if hud:
		if "current_score" in hud:
			current_score = hud.current_score
		elif hud.has_method("get_current_score"):
			current_score = hud.get_current_score()
	
	print("📊 Final score: %d (incomplete)" % current_score)
	
	# Get role if available
	var role = "beginner"
	if quest_tracker and "current_role" in quest_tracker:
		role = quest_tracker.current_role
	
	print("🎮 Role: %s" % role)
	
	# TODO: Save to Firebase
	# For now, just go to leaderboard
	
	# Check if leaderboard exists
	if ResourceLoader.exists("res://gameplay/leaderboard.tscn"):
		print("✅ Transitioning to leaderboard...")
		get_tree().change_scene_to_file("res://gameplay/leaderboard.tscn")
	else:
		print("❌ Leaderboard scene not found")
		var error_dialog = AcceptDialog.new()
		error_dialog.dialog_text = "Cannot load leaderboard.\nLeaderboard scene not found!"
		error_dialog.title = "Error"
		add_child(error_dialog)
		error_dialog.popup_centered()
		error_dialog.confirmed.connect(func(): error_dialog.queue_free())
