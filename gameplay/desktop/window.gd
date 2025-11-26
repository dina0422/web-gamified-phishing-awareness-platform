extends Panel

# Window component for Desktop OS
# Handles dragging, minimizing, maximizing, and closing

signal close_requested

@export var window_title: String = "Window":
	set(value):
		window_title = value
		if is_node_ready():
			$VBoxContainer/TitleBar/HBoxContainer/Title.text = value

@onready var title_bar = $VBoxContainer/TitleBar
@onready var title_label = $VBoxContainer/TitleBar/HBoxContainer/Title
@onready var content_container = $VBoxContainer/Content

var dragging := false
var drag_offset := Vector2.ZERO
var is_minimized := false
var is_maximized := false
var original_position := Vector2.ZERO
var original_size := Vector2.ZERO

func _ready():
	title_label.text = window_title
	original_position = position
	original_size = size

func set_content(content: Control):
	# Ensure content_container is initialized
	if content_container == null:
		push_error("content_container is null! Window not ready.")
		return
	
	# Clear existing content
	for child in content_container.get_children():
		child.queue_free()
	
	# Add new content
	content_container.add_child(content)
	
func _on_title_bar_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
				bring_to_front()
			else:
				dragging = false
	
	elif event is InputEventMouseMotion:
		if dragging and not is_maximized:
			global_position = get_global_mouse_position() - drag_offset

func bring_to_front():
	# Move to end of parent's children (rendered last = on top)
	get_parent().move_child(self, -1)

func _on_minimize_button_pressed():
	toggle_minimize()

func toggle_minimize():
	is_minimized = not is_minimized
	visible = not is_minimized
	
	# Update taskbar button state if it exists
	if has_meta("taskbar_button"):
		var button = get_meta("taskbar_button")
		button.button_pressed = not is_minimized

func _on_maximize_button_pressed():
	is_maximized = not is_maximized
	
	if is_maximized:
		# Store original state
		original_position = global_position
		original_size = size
		
		# Maximize to viewport size (with taskbar offset)
		var viewport_size = get_viewport_rect().size
		global_position = Vector2(0, 0)
		size = Vector2(viewport_size.x, viewport_size.y - 50)  # -50 for taskbar
	else:
		# Restore original state
		global_position = original_position
		size = original_size
		
func _on_close_button_pressed():
	emit_signal("close_requested")
