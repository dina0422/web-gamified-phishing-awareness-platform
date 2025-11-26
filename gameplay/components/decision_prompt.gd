extends CanvasLayer

## Shows multiple choice options for scenario decisions

signal option_selected(option_index: int, option_text: String, points_awarded: int)
signal timer_expired
signal hint_requested

@onready var dim_overlay = $DimOverlay
@onready var scroll_container = $ScrollContainer
@onready var panel = $ScrollContainer/Panel
@onready var question_label = $ScrollContainer/Panel/MarginContainer/VBoxContainer/HeaderContainer/QuestionLabel
@onready var options_container = $ScrollContainer/Panel/MarginContainer/VBoxContainer/OptionsContainer
@onready var hint_button = $ScrollContainer/Panel/MarginContainer/VBoxContainer/BottomContainer/HintButton
@onready var timer_label = $ScrollContainer/Panel/MarginContainer/VBoxContainer/BottomContainer/TimerLabel
@onready var timer = $Timer

# Data
var options: Array = []
var correct_indices: Array = []
var points_array: Array = []
var hint_text: String = ""
var time_limit: float = 0.0
var time_remaining: float = 0.0
var show_point_values: bool = false

# State
var is_active: bool = false
var hint_used: bool = false

# Mobile support
var is_mobile: bool = false

func _ready():
	hide_prompt()
	_detect_platform()
	_setup_mobile_scrolling()
	timer.timeout.connect(_on_timer_timeout)
	hint_button.pressed.connect(_on_hint_pressed)
	
	print("🤔 Decision Prompt initialized (Mobile: %s)" % is_mobile)

func _detect_platform():
	"""Detect if running on mobile/touch device"""
	var os_name = OS.get_name()
	is_mobile = os_name in ["Android", "iOS", "Web"]
	
	if OS.has_feature("web"):
		is_mobile = true

func _setup_mobile_scrolling():
	"""Configure ScrollContainer for optimal mobile/touch experience"""
	if scroll_container:
		scroll_container.follow_focus = true
		print("✅ Touch scrolling configured for decision prompt")

func setup_prompt(question: String, option_texts: Array, correct: Array, points: Array, hint: String = "", time: float = 0.0, show_points: bool = false):
	"""
	Setup and display decision prompt
	
	Args:
		question: The question to display
		option_texts: Array of option strings
		correct: Array of correct option indices (can be multiple)
		points: Array of points for each option (negative for wrong answers)
		hint: Optional hint text
		time: Optional time limit in seconds (0 = no limit)
		show_points: Whether to show point values (false for beginner, true for advanced)
	"""
	
	# Store data
	options = option_texts
	correct_indices = correct
	points_array = points
	hint_text = hint
	time_limit = time
	time_remaining = time
	hint_used = false
	show_point_values = show_points
	
	# Set question
	question_label.text = question
	
	# Clear previous options
	for child in options_container.get_children():
		child.queue_free()
	
	# Create option buttons
	for i in range(options.size()):
		var option_button = create_option_button(i, options[i], points[i])
		options_container.add_child(option_button)
	
	# Setup hint button
	hint_button.visible = hint_text != ""
	hint_button.disabled = false
	
	# Setup timer
	if time_limit > 0:
		timer_label.visible = true
		timer.wait_time = 1.0
		timer.start()
		update_timer_display()
	else:
		timer_label.visible = false
	
	# Show prompt
	show_prompt()
	
	# Reset scroll to top
	await get_tree().create_timer(0.1).timeout
	if scroll_container:
		scroll_container.scroll_vertical = 0

func create_option_button(index: int, text: String, points: int) -> Control:
	"""Create a styled option button - MOBILE OPTIMIZED"""
	
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 60)  # Reduced from 70 for mobile
	container.add_theme_constant_override("separation", 10)
	
	# Option letter label
	var letter_label = Label.new()
	letter_label.text = char(65 + index) + ")"  # A, B, C, D...
	letter_label.add_theme_font_size_override("font_size", 16)
	letter_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
	letter_label.custom_minimum_size = Vector2(30, 0)
	container.add_child(letter_label)
	
	# Main button
	var button = Button.new()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 60)  # Touch-friendly height
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Style based on points
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.18, 0.22, 1)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	
	# Color code border if show_point_values is true
	if show_point_values:
		if points > 0:
			style.border_color = Color(0.2, 0.8, 0.3, 1)  # Green
		else:
			style.border_color = Color(0.8, 0.3, 0.2, 1)  # Red
	else:
		style.border_color = Color(0.4, 0.4, 0.5, 1)  # Neutral
	
	button.add_theme_stylebox_override("normal", style)
	
	# Hover/pressed effects
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.25, 0.25, 0.3, 1)
	button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = style.duplicate()
	pressed_style.bg_color = Color(0.3, 0.3, 0.35, 1)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Font size - slightly smaller for mobile
	button.add_theme_font_size_override("font_size", 14)
	
	container.add_child(button)
	
	# Point label (only if show_point_values is true)
	if show_point_values:
		var point_label = Label.new()
		point_label.custom_minimum_size = Vector2(70, 0)
		point_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		point_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		if points > 0:
			point_label.text = "+%d" % points
			point_label.add_theme_color_override("font_color", Color(0.3, 1, 0.4, 1))
		elif points < 0:
			point_label.text = "%d" % points
			point_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
		else:
			point_label.text = "0"
			point_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
		
		point_label.add_theme_font_size_override("font_size", 16)
		container.add_child(point_label)
	
	# Connect signal
	button.pressed.connect(func(): _on_option_pressed(index))
	
	return container

func _on_option_pressed(index: int):
	"""Handle option selection - Mobile friendly"""
	if !is_active:
		return
	
	is_active = false
	timer.stop()
	
	var points_awarded = points_array[index]
	var option_text = options[index]
	
	print("🤔 Option selected: %s (index: %d, points: %d)" % [option_text, index, points_awarded])
	
	# Visual feedback
	play_selection_animation(index)
	
	# Wait for animation
	await get_tree().create_timer(0.3).timeout
	
	# Emit signal
	emit_signal("option_selected", index, option_text, points_awarded)

func play_selection_animation(index: int):
	"""Animate selected option"""
	var selected_container = options_container.get_child(index)
	if selected_container:
		var tween = create_tween()
		tween.tween_property(selected_container, "modulate", Color(1, 1, 0.5, 1), 0.15)
		tween.tween_property(selected_container, "modulate", Color(1, 1, 1, 1), 0.15)

func _on_hint_pressed():
	"""Show hint to player - Mobile friendly"""
	if hint_used or hint_text == "":
		return
	
	hint_used = true
	hint_button.disabled = true
	hint_button.text = "Hint Used ✓"
	
	print("💡 Hint requested: %s" % hint_text)
	
	# Show hint as popup
	show_hint_popup(hint_text)
	
	emit_signal("hint_requested")

func show_hint_popup(hint: String):
	"""Display hint in a popup"""
	var popup = AcceptDialog.new()
	popup.dialog_text = hint
	popup.title = "💡 Hint"
	popup.ok_button_text = "Got it!"
	
	add_child(popup)
	popup.popup_centered()
	
	popup.confirmed.connect(func():
		popup.queue_free()
	)

func update_timer_display():
	"""Update timer label"""
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	timer_label.text = "⏱️ %d:%02d" % [minutes, seconds]
	
	# Change color based on time remaining
	if time_remaining <= 10:
		timer_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))  # Red
	elif time_remaining <= 30:
		timer_label.add_theme_color_override("font_color", Color(1, 0.7, 0.2, 1))  # Orange
	else:
		timer_label.add_theme_color_override("font_color", Color(1, 0.5, 0.5, 1))  # Light red

func _on_timer_timeout():
	"""Handle timer tick"""
	if !is_active:
		return
	
	time_remaining -= 1
	update_timer_display()
	
	if time_remaining <= 0:
		is_active = false
		timer.stop()
		emit_signal("timer_expired")
		
		# Auto-select first option or show timeout message
		print("⏱️ Time expired!")

func show_prompt():
	"""Show prompt with animation"""
	visible = true
	is_active = true
	
	# Start hidden
	dim_overlay.modulate = Color(1, 1, 1, 0)
	panel.modulate = Color(1, 1, 1, 0)
	panel.position.y = -30
	
	# Fade and slide in
	var tween = create_tween().set_parallel(true)
	tween.tween_property(dim_overlay, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.tween_property(panel, "position:y", 0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func hide_prompt():
	"""Hide prompt with animation"""
	if not visible:
		return
	
	is_active = false
	timer.stop()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(dim_overlay, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.tween_property(panel, "position:y", -30, 0.25)
	
	await tween.finished
	visible = false

func _input(event):
	if not visible or not is_active:
		return
	
	if event is InputEventKey and event.pressed:
		var key = event.keycode
	
	# Keys 1-9 for options A-I
		if key >= KEY_1 and key <= KEY_9:  # ✅ key is accessible now!
			var option_index = key - KEY_1
			if option_index < options.size():
				_on_option_pressed(option_index)
				get_viewport().set_input_as_handled()
		
		# ESC to show hint (if available)
		elif event.is_action_pressed("ui_cancel") and hint_text != "" and not hint_used:
			_on_hint_pressed()
			get_viewport().set_input_as_handled()
