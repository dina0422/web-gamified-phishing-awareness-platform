extends CanvasLayer

signal continue_pressed

# Node paths
@onready var background = $Background
@onready var scroll_container = $ScrollContainer
@onready var panel = $ScrollContainer/Panel
@onready var result_label = $ScrollContainer/Panel/MarginContainer/VBoxContainer/HeaderSection/ResultLabel
@onready var points_label = $ScrollContainer/Panel/MarginContainer/VBoxContainer/HeaderSection/PointsLabel
@onready var explanation_text = $ScrollContainer/Panel/MarginContainer/VBoxContainer/ExplanationSection/ExplanationText
@onready var red_flags_list = $ScrollContainer/Panel/MarginContainer/VBoxContainer/RedFlagsSection/RedFlagsList
@onready var learning_text = $ScrollContainer/Panel/MarginContainer/VBoxContainer/LearningSection/LearningText
@onready var current_score_label = $ScrollContainer/Panel/MarginContainer/VBoxContainer/ScoreSection/CurrentScoreLabel
@onready var progress_bar = $ScrollContainer/Panel/MarginContainer/VBoxContainer/ScoreSection/ProgressBar
@onready var continue_button = $ScrollContainer/Panel/MarginContainer/VBoxContainer/ButtonContainer/ContinueButton

var red_flag_style: StyleBoxFlat
var is_mobile: bool = false
var scroll_indicator: Label  # Visual indicator to scroll

func _ready():
	hide_debrief()
	_detect_platform()
	_setup_mobile_scrolling()
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Create red flag style
	red_flag_style = StyleBoxFlat.new()
	red_flag_style.bg_color = Color(0.3, 0.15, 0.15, 0.5)
	red_flag_style.border_width_left = 2
	red_flag_style.border_width_top = 2
	red_flag_style.border_width_right = 2
	red_flag_style.border_width_bottom = 2
	red_flag_style.border_color = Color(0.8, 0.2, 0.2, 1)
	red_flag_style.corner_radius_top_left = 6
	red_flag_style.corner_radius_top_right = 6
	red_flag_style.corner_radius_bottom_right = 6
	red_flag_style.corner_radius_bottom_left = 6
	
	# Create scroll indicator
	_create_scroll_indicator()
	
	print("📚 Educational Debrief initialized")

func _create_scroll_indicator():
	"""Create a visual indicator that shows when user can scroll"""
	scroll_indicator = Label.new()
	scroll_indicator.text = "▼ Scroll Down for More ▼"
	scroll_indicator.add_theme_font_size_override("font_size", 14)
	scroll_indicator.add_theme_color_override("font_color", Color(1, 1, 0.3, 1))
	scroll_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scroll_indicator.visible = false
	
	# Position at bottom of screen
	scroll_indicator.anchors_preset = Control.PRESET_BOTTOM_WIDE
	scroll_indicator.offset_top = -30
	scroll_indicator.offset_bottom = -10
	
	add_child(scroll_indicator)

func _detect_platform():
	var os_name = OS.get_name()
	is_mobile = os_name in ["Android", "iOS", "Web"]
	if OS.has_feature("web"):
		is_mobile = true

func _setup_mobile_scrolling():
	if scroll_container:
		scroll_container.follow_focus = true
		# Connect to scroll changes to hide indicator when at bottom
		scroll_container.get_v_scroll_bar().value_changed.connect(_on_scroll_changed)

func _on_scroll_changed(value):
	"""Hide scroll indicator when user scrolls to bottom"""
	var v_scroll = scroll_container.get_v_scroll_bar()
	var at_bottom = value >= (v_scroll.max_value - v_scroll.page)
	if at_bottom:
		scroll_indicator.visible = false

func show_debrief(data: Dictionary):
	var is_correct = data.get("correct", false)
	var points = data.get("points", 0)
	var explanation = data.get("explanation", "")
	var red_flags = data.get("red_flags", [])
	var learning = data.get("learning_points", "")
	var current_score = data.get("current_score", 0)
	var max_score = data.get("max_score", 100)
	
	# Set result header
	if is_correct:
		result_label.text = "✅ CORRECT!"
		result_label.add_theme_color_override("font_color", Color(0.3, 1, 0.4, 1))
		var panel_style = panel.get_theme_stylebox("panel")
		if panel_style is StyleBoxFlat:
			panel_style.border_color = Color(0.3, 0.9, 0.3, 1)
	else:
		result_label.text = "❌ INCORRECT"
		result_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
		var panel_style = panel.get_theme_stylebox("panel")
		if panel_style is StyleBoxFlat:
			panel_style.border_color = Color(0.9, 0.3, 0.3, 1)
	
	# Set points
	if points > 0:
		points_label.text = "+" + str(points) + " points"
		points_label.add_theme_color_override("font_color", Color(0.3, 1, 0.4, 1))
	elif points < 0:
		points_label.text = str(points) + " points"
		points_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	else:
		points_label.text = "0 points"
		points_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	
	explanation_text.text = explanation
	
	# Clear red flags
	for child in red_flags_list.get_children():
		child.queue_free()
	
	# Add red flags
	for flag in red_flags:
		var flag_item = create_red_flag_item(flag)
		red_flags_list.add_child(flag_item)
	
	learning_text.text = learning
	
	# Update score
	current_score_label.text = "Current Score: %d / %d" % [current_score, max_score]
	progress_bar.max_value = max_score
	progress_bar.value = current_score
	
	var percentage = float(current_score) / float(max_score) * 100
	if percentage >= 80:
		progress_bar.modulate = Color(0.3, 1, 0.4, 1)
	elif percentage >= 60:
		progress_bar.modulate = Color(1, 1, 0.3, 1)
	else:
		progress_bar.modulate = Color(1, 0.3, 0.3, 1)
	
	show_debrief_animated()
	
	# Check if content is scrollable and show indicator
	await get_tree().create_timer(0.2).timeout
	_check_scroll_needed()
	
	if scroll_container:
		scroll_container.scroll_vertical = 0

func _check_scroll_needed():
	"""Check if content needs scrolling and show indicator"""
	var v_scroll = scroll_container.get_v_scroll_bar()
	var needs_scroll = v_scroll.max_value > v_scroll.page
	
	if needs_scroll:
		scroll_indicator.visible = true
		# Animate the indicator
		_animate_scroll_indicator()

func _animate_scroll_indicator():
	"""Animate the scroll indicator to attract attention"""
	var tween = create_tween().set_loops()
	tween.tween_property(scroll_indicator, "modulate:a", 0.5, 0.8)
	tween.tween_property(scroll_indicator, "modulate:a", 1.0, 0.8)

func create_red_flag_item(text: String) -> Control:
	"""Create red flag with proper sizing"""
	
	var wrapper = Control.new()
	wrapper.custom_minimum_size = Vector2(0, 45)
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.size_flags_vertical = Control.SIZE_FILL
	
	var panel_item = Panel.new()
	panel_item.add_theme_stylebox_override("panel", red_flag_style)
	panel_item.set_anchors_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(panel_item)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_item.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	margin.add_child(hbox)
	
	var icon = Label.new()
	icon.text = "❌"
	icon.add_theme_font_size_override("font_size", 14)
	hbox.add_child(icon)
	
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1, 0.8, 0.8, 1))
	hbox.add_child(label)
	
	return wrapper

func show_debrief_animated():
	visible = true
	background.modulate = Color(1, 1, 1, 0)
	panel.modulate = Color(1, 1, 1, 0)
	panel.position.y = -50
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(background, "modulate", Color(1, 1, 1, 1), 0.4)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.4)
	tween.tween_property(panel, "position:y", 0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hide_debrief():
	visible = false
	if scroll_indicator:
		scroll_indicator.visible = false

func _on_continue_pressed():
	print("📚 Continue button pressed")
	var tween = create_tween().set_parallel(true)
	tween.tween_property(background, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.3)
	if scroll_indicator:
		tween.tween_property(scroll_indicator, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished
	visible = false
	emit_signal("continue_pressed")

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		_on_continue_pressed()
		get_viewport().set_input_as_handled()
