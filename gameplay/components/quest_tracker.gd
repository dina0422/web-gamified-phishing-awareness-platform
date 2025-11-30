extends CanvasLayer

## Minimizable Quest Tracker with Fade Animations
## Shows intro message, then minimizes to icon

@onready var panel = $Panel
@onready var quest_title = $Panel/MarginContainer/VBoxContainer/QuestTitle
@onready var minimize_button = $Panel/MinimizeButton
@onready var minimized_icon = $MinimizedIcon
@onready var tasks_container: VBoxContainer = null
@onready var progress_label: Label = null
@onready var give_up_button: Button = null

# Animation states
var is_minimized := false
var intro_shown := false

# Role requirements
const ROLE_REQUIREMENTS := {
	"beginner": {
		"title": "Welcome, Civilian!",
		"intro_message": "Move around and complete 2 tasks",
		"tasks": {
			"living_room": {
				"id": "living_room_complete",
				"display": "Check your phone in the living room",
				"hint": "Talk to Adam to get started",
				"scene": "living_room.tscn",
				"icon": "[HOME]"
			},
			"home_office": {
				"id": "home_office_complete",
				"display": "Check your computer in the home office",
				"hint": "Navigate upstairs to the office",
				"scene": "home_office.tscn",
				"icon": "[WORK]"
			}
		}
	}
}

var current_role: String = ""
var completed_tasks: Array = []
var total_tasks: int = 0
var task_labels: Dictionary = {}

signal role_completed(role: String, final_score: int)

func _ready():
	detect_current_role()
	
	await get_tree().process_frame
	# Check for fresh start from role selection
	check_fresh_start()
	
	setup_panel_sizing()
	setup_ui_elements()
	load_role_progress()
	build_task_ui()
	update_all_displays()
	
	# Show intro animation
	show_intro_animation()
	
	print("[OK] QuestTracker Ready - Role: %s, Tasks: %d" % [current_role, total_tasks])

func setup_panel_sizing():
	"""Ensure panel is properly sized - compact version"""
	panel.custom_minimum_size = Vector2(340, 200)
	panel.size = Vector2(340, 200)
	panel.offset_right = panel.offset_left + 340
	panel.offset_bottom = panel.offset_top + 200
	
	var margin_container = $Panel/MarginContainer
	margin_container.anchors_preset = Control.PRESET_FULL_RECT
	margin_container.anchor_right = 1.0
	margin_container.anchor_bottom = 1.0
	margin_container.set_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Set compact margins
	margin_container.add_theme_constant_override("margin_left", 15)
	margin_container.add_theme_constant_override("margin_top", 15)
	margin_container.add_theme_constant_override("margin_right", 15)
	margin_container.add_theme_constant_override("margin_bottom", 15)
	
	var vbox = $Panel/MarginContainer/VBoxContainer
	vbox.custom_minimum_size = Vector2(0, 0)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)  # Tighter spacing
	
	if quest_title:
		quest_title.custom_minimum_size = Vector2(310, 0)
		quest_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		quest_title.add_theme_font_size_override("font_size", 16)  # Smaller font

func show_intro_animation():
	"""Show intro message then fade to minimized icon"""
	if intro_shown:
		return
	
	intro_shown = true
	
	# Show intro message
	var role_data = ROLE_REQUIREMENTS.get(current_role, {})
	var intro_msg = role_data.get("intro_message", "Complete your tasks!")
	
	quest_title.text = intro_msg
	panel.modulate = Color(1, 1, 1, 0)
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.5)
	await tween.finished
	
	# Wait 3 seconds
	await get_tree().create_timer(3.0).timeout
	
	# Fade out
	tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween.finished
	
	# Switch to normal view and minimize
	quest_title.text = role_data.get("title", "Quest Tracker")
	minimize()

func minimize():
	"""Minimize panel to icon"""
	is_minimized = true
	
	# Hide panel
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished
	panel.hide()
	
	# Show minimized icon
	minimized_icon.modulate = Color(1, 1, 1, 0)
	minimized_icon.show()
	tween = create_tween()
	tween.tween_property(minimized_icon, "modulate", Color(1, 1, 1, 1), 0.3)

func maximize():
	"""Restore panel from icon"""
	is_minimized = false
	
	# Hide icon
	var tween = create_tween()
	tween.tween_property(minimized_icon, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished
	minimized_icon.hide()
	
	# Show panel
	panel.modulate = Color(1, 1, 1, 0)
	panel.show()
	tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.3)

func detect_current_role() -> void:
	var scene_path := get_tree().current_scene.scene_file_path.to_lower()
	if "beginner" in scene_path or "living_room" in scene_path or "home_office" in scene_path:
		current_role = "beginner"
	elif "intermediate" in scene_path or "office" in scene_path:
		current_role = "intermediate"
	elif "professional" in scene_path or "soc" in scene_path:
		current_role = "professional"
	
	if current_role in ROLE_REQUIREMENTS:
		total_tasks = ROLE_REQUIREMENTS[current_role]["tasks"].size()

func setup_ui_elements():
	var vbox = $Panel/MarginContainer/VBoxContainer
	
	# Create minimize button
	minimize_button = $Panel.get_node_or_null("MinimizeButton")
	if not minimize_button:
		minimize_button = Button.new()
		minimize_button.name = "MinimizeButton"
		minimize_button.text = "−"  # Minus symbol
		minimize_button.custom_minimum_size = Vector2(30, 30)
		minimize_button.position = Vector2(300, 8)  # Top right for compact panel
		minimize_button.add_theme_font_size_override("font_size", 20)
		minimize_button.tooltip_text = "Minimize (Tab)"
		minimize_button.pressed.connect(minimize)
		panel.add_child(minimize_button)
	
	# Create minimized icon button
	minimized_icon = get_node_or_null("MinimizedIcon")
	if not minimized_icon:
		minimized_icon = Button.new()
		minimized_icon.name = "MinimizedIcon"
		minimized_icon.text = "📋"  # Clipboard icon
		minimized_icon.custom_minimum_size = Vector2(50, 50)
		minimized_icon.position = Vector2(20, 20)
		minimized_icon.add_theme_font_size_override("font_size", 24)
		minimized_icon.tooltip_text = "Expand Quest Tracker (Tab)"
		minimized_icon.pressed.connect(maximize)
		minimized_icon.hide()
		add_child(minimized_icon)
		move_child(minimized_icon, 0)  # Behind panel
	
	# Create tasks container
	tasks_container = vbox.get_node_or_null("TasksContainer")
	if not tasks_container:
		tasks_container = VBoxContainer.new()
		tasks_container.name = "TasksContainer"
		vbox.add_child(tasks_container)
		vbox.move_child(tasks_container, 1)
	
	# Create progress label
	progress_label = vbox.get_node_or_null("ProgressLabel")
	if not progress_label:
		progress_label = Label.new()
		progress_label.name = "ProgressLabel"
		progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		progress_label.add_theme_font_size_override("font_size", 16)
		vbox.add_child(progress_label)
	
	# DON'T create give up button here - it's separate now

func build_task_ui() -> void:
	if current_role not in ROLE_REQUIREMENTS:
		return
	
	var role_data = ROLE_REQUIREMENTS[current_role]
	quest_title.text = role_data["title"]
	
	for child in tasks_container.get_children():
		child.queue_free()
	task_labels.clear()
	
	var tasks_dict = role_data["tasks"]
	for task_key in tasks_dict.keys():
		var task_data = tasks_dict[task_key]
		create_task_item(task_data)

func create_task_item(task_data: Dictionary) -> void:
	var task_container = HBoxContainer.new()
	task_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.custom_minimum_size = Vector2(30, 0)
	status_label.text = "[X]" if task_data["id"] in completed_tasks else "[ ]"
	status_label.modulate = Color(0.2, 1.0, 0.2) if task_data["id"] in completed_tasks else Color(0.6, 0.6, 0.6)
	task_container.add_child(status_label)
	
	var details_container = VBoxContainer.new()
	details_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var task_label = Label.new()
	task_label.name = "TaskLabel"
	task_label.text = "%s %s" % [task_data.get("icon", ""), task_data["display"]]
	task_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	task_label.add_theme_font_size_override("font_size", 14)
	
	if task_data["id"] in completed_tasks:
		task_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		task_label.text += " "
	
	details_container.add_child(task_label)
	
	if task_data["id"] not in completed_tasks and task_data.get("hint", "") != "":
		var hint_label = Label.new()
		hint_label.text = " " + task_data["hint"]
		hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint_label.add_theme_font_size_override("font_size", 12)
		hint_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		details_container.add_child(hint_label)
	
	task_container.add_child(details_container)
	tasks_container.add_child(task_container)
	
	task_labels[task_data["id"]] = {
		"container": task_container,
		"status": status_label,
		"label": task_label,
		"data": task_data
	}

func update_all_displays() -> void:
	update_progress_display()
	update_task_displays()

func update_progress_display() -> void:
	if progress_label:
		progress_label.text = " Progress: %d / %d" % [completed_tasks.size(), total_tasks]
		
		if completed_tasks.size() >= total_tasks:
			progress_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
		elif completed_tasks.size() > 0:
			progress_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))

func update_task_displays() -> void:
	for task_id in task_labels.keys():
		var task_ui = task_labels[task_id]
		var is_complete = task_id in completed_tasks
		
		if is_complete:
			task_ui["status"].text = "[OK]"
			task_ui["status"].modulate = Color(0.2, 1.0, 0.2)
			task_ui["label"].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			if not " " in task_ui["label"].text:
				task_ui["label"].text += " "
		else:
			task_ui["status"].text = ""
			task_ui["status"].modulate = Color(0.6, 0.6, 0.6)

func load_role_progress() -> void:
	if current_role == "":
		return
	var save_path := "user://role_progress_%s.json" % current_role
	if FileAccess.file_exists(save_path):
		var file := FileAccess.open(save_path, FileAccess.READ)
		if file:
			var json = JSON.parse_string(file.get_as_text())
			file.close()
			if typeof(json) == TYPE_DICTIONARY:
				completed_tasks = json.get("completed_tasks", [])
				print("[OK] Loaded progress: %d/%d tasks" % [completed_tasks.size(), total_tasks])

func save_role_progress() -> void:
	if current_role == "":
		return
	var save_data := {
		"role": current_role,
		"completed_tasks": completed_tasks,
		"timestamp": Time.get_datetime_string_from_system()
	}
	var save_path := "user://role_progress_%s.json" % current_role
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print(" Progress saved: %d/%d tasks" % [completed_tasks.size(), total_tasks])

func reset_progress() -> void:
	"""Reset all progress for current role - used when restarting level"""
	if current_role == "":
		return
	
	# Clear in-memory progress
	completed_tasks.clear()
	
	# Delete save file
	var save_path := "user://role_progress_%s.json" % current_role
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
		print("Progress file deleted: %s" % save_path)
	
	# Update displays
	update_all_displays()
	
	print("Progress reset for role: %s" % current_role)

static func reset_role_progress_static(role: String) -> void:
	"""Static method to reset progress from outside the quest tracker"""
	var save_path := "user://role_progress_%s.json" % role
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
		print("Progress file deleted (static): %s" % save_path)

func check_fresh_start() -> void:
	"""Check if this is a fresh start from role selection"""
	# Check if Global autoload exists and has fresh_start flag
	if not has_node("/root/Global"):
		print("No Global autoload found - skipping fresh start check")
		return
	
	var global_node = get_node("/root/Global")
	if global_node.has_method("consume_fresh_start_flag"):
		var is_fresh_start = global_node.consume_fresh_start_flag()
		if is_fresh_start:
			print("Fresh start detected - resetting progress for: %s" % current_role)
			reset_progress()


func mark_task_complete(task_id: String) -> void:
	if task_id in completed_tasks:
		print(" Task already completed: %s" % task_id)
		return
	
	completed_tasks.append(task_id)
	save_role_progress()
	update_all_displays()
	
	print("[OK] Task completed: %s (%d/%d)" % [task_id, completed_tasks.size(), total_tasks])
	
	# Flash the updated checkbox
	if task_id in task_labels:
		var status = task_labels[task_id]["status"]
		var tween = create_tween()
		tween.tween_property(status, "scale", Vector2(1.5, 1.5), 0.2)
		tween.tween_property(status, "scale", Vector2(1.0, 1.0), 0.2)
	
	if completed_tasks.size() >= total_tasks:
		on_role_completed()

func complete_scene(scene_name: String) -> void:
	var task_id := scene_name.to_lower().replace(".tscn", "_complete")
	mark_task_complete(task_id)

func on_role_completed() -> void:
	print(" Role Completed: %s" % current_role)
	quest_title.text = " Congratulations!"
	
	# Maximize to show completion
	if is_minimized:
		maximize()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F7:
			var current_scene := get_tree().current_scene.scene_file_path.get_file()
			complete_scene(current_scene)
		elif event.keycode == KEY_TAB:
			# Toggle minimize/maximize
			if is_minimized:
				maximize()
			else:
				minimize()
