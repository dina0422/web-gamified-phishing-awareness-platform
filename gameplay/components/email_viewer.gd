extends CanvasLayer

## Displays email content for phishing scenarios

signal continue_pressed
signal closed

@onready var dim_background = $DimBackground
@onready var scroll_container = $ScrollContainer
@onready var email_panel = $ScrollContainer/EmailPanel
@onready var subject_label = $ScrollContainer/EmailPanel/VBoxContainer/EmailContent/VBoxContainer/SubjectLabel
@onready var from_name = $ScrollContainer/EmailPanel/VBoxContainer/EmailContent/VBoxContainer/SenderSection/FromContainer/SenderInfo/FromName
@onready var from_email = $ScrollContainer/EmailPanel/VBoxContainer/EmailContent/VBoxContainer/SenderSection/FromContainer/SenderInfo/FromEmail
@onready var to_value = $ScrollContainer/EmailPanel/VBoxContainer/EmailContent/VBoxContainer/SenderSection/ToContainer/ToValue
@onready var time_label = $ScrollContainer/EmailPanel/VBoxContainer/EmailContent/VBoxContainer/SenderSection/FromContainer/TimeLabel
@onready var avatar_label = $ScrollContainer/EmailPanel/VBoxContainer/EmailContent/VBoxContainer/SenderSection/FromContainer/Avatar/AvatarLabel
@onready var avatar_panel = $ScrollContainer/EmailPanel/VBoxContainer/EmailContent/VBoxContainer/SenderSection/FromContainer/Avatar
@onready var body_text = $ScrollContainer/EmailPanel/VBoxContainer/EmailContent/VBoxContainer/BodyText
@onready var back_button = $ScrollContainer/EmailPanel/VBoxContainer/Header/MarginContainer/HBoxContainer/BackButton
@onready var close_button = $ScrollContainer/EmailPanel/VBoxContainer/Header/MarginContainer/HBoxContainer/CloseButton
@onready var continue_button = $ScrollContainer/EmailPanel/VBoxContainer/EmailContent/VBoxContainer/ActionButtons/ContinueButton

# Email data
var email_data: Dictionary = {}

# Mobile support
var is_mobile: bool = false

func _ready():
	hide_email()
	_detect_platform()
	_setup_mobile_scrolling()
	
	# Connect buttons
	back_button.pressed.connect(_on_close_pressed)
	close_button.pressed.connect(_on_close_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Style avatar
	_setup_avatar_style()
	
	print("📧 Gmail-style Email Viewer initialized (Mobile: %s)" % is_mobile)

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
		print("✅ Touch scrolling configured for email viewer")

func _setup_avatar_style():
	"""Setup Gmail-style circular avatar"""
	if avatar_panel:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.26, 0.52, 0.96, 1)  # Gmail blue
		style.corner_radius_top_left = 20
		style.corner_radius_top_right = 20
		style.corner_radius_bottom_left = 20
		style.corner_radius_bottom_right = 20
		avatar_panel.add_theme_stylebox_override("panel", style)

func display_email(data: Dictionary):
	"""
	Display an email in Gmail style
	
	Args:
		data: Dictionary containing:
			- from: String - Sender email (e.g., "John Doe <john@example.com>")
			- to: String - Recipient email
			- subject: String - Email subject
			- body: String - Email body (supports BBCode)
			- time: String - Time sent (optional, default "12:34 PM")
			- show_red_flags: bool - Whether to highlight suspicious elements (optional)
	"""
	
	email_data = data
	
	# Parse sender email
	var sender_full = data.get("from", "Unknown <unknown@email.com>")
	var parsed_sender = _parse_email_address(sender_full)
	
	# Set subject
	subject_label.text = data.get("subject", "No Subject")
	
	# Set sender info
	from_name.text = parsed_sender["name"]
	from_email.text = "<" + parsed_sender["email"] + ">"
	
	# Set avatar (first letter of sender name)
	avatar_label.text = parsed_sender["name"][0].to_upper() if parsed_sender["name"].length() > 0 else "?"
	
	# Set recipient
	var recipient = data.get("to", "me")
	to_value.text = recipient if recipient != "" else "me"
	
	# Set time
	time_label.text = data.get("time", _get_current_time())
	
	# Set body
	body_text.text = data.get("body", "")
	
	# Highlight red flags if enabled
	if data.get("show_red_flags", false):
		highlight_red_flags()
	
	# Show email
	show_email()
	
	# Reset scroll to top
	await get_tree().create_timer(0.1).timeout
	if scroll_container:
		scroll_container.scroll_vertical = 0

func _parse_email_address(full_email: String) -> Dictionary:
	"""Parse 'Name <email@domain.com>' format"""
	var result = {"name": "", "email": ""}
	
	# Check if format is "Name <email>"
	if "<" in full_email and ">" in full_email:
		var parts = full_email.split("<")
		result["name"] = parts[0].strip_edges()
		result["email"] = parts[1].replace(">", "").strip_edges()
	else:
		# Just email address
		result["email"] = full_email.strip_edges()
		# Extract name from email (part before @)
		if "@" in full_email:
			result["name"] = full_email.split("@")[0]
		else:
			result["name"] = full_email
	
	return result

func _get_current_time() -> String:
	"""Get current time in 12-hour format"""
	var time_dict = Time.get_time_dict_from_system()
	var hour = time_dict["hour"]
	var minute = time_dict["minute"]
	var period = "AM" if hour < 12 else "PM"
	
	# Convert to 12-hour format
	if hour == 0:
		hour = 12
	elif hour > 12:
		hour -= 12
	
	return "%d:%02d %s" % [hour, minute, period]

func highlight_red_flags():
	"""Subtly highlight suspicious elements (optional feature)"""
	# Could add visual indicators for:
	# - Suspicious domains (mismatched sender)
	# - Urgency words (URGENT, ACT NOW, etc.)
	# - Misspellings
	# For now, keep it clean so players learn to identify themselves
	pass

func show_email():
	"""Show email with Gmail-style animation"""
	visible = true
	
	# Start hidden
	dim_background.modulate = Color(1, 1, 1, 0)
	email_panel.modulate = Color(1, 1, 1, 0)
	email_panel.position.y = 50
	
	# Slide up and fade in
	var tween = create_tween().set_parallel(true)
	tween.tween_property(dim_background, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.tween_property(email_panel, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.tween_property(email_panel, "position:y", 0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func hide_email():
	"""Hide email with animation"""
	if not visible:
		return
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(dim_background, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.tween_property(email_panel, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.tween_property(email_panel, "position:y", 50, 0.25)
	
	await tween.finished
	visible = false

func _on_continue_pressed():
	"""Handle continue button - Mobile friendly"""
	print("📧 Email continue button pressed")
	emit_signal("continue_pressed")

func _on_close_pressed():
	"""Handle close/back button - Mobile friendly"""
	print("📧 Email closed")
	await hide_email()
	emit_signal("closed")

func _input(event):
	"""Allow ESC to close (desktop) - Mobile users use close button"""
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
