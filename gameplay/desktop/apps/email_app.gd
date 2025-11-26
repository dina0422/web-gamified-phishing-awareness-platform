extends Control

# Email App for Desktop OS - FIRESTORE VERSION (Gmail-inspired design)
# Fetches phishing scenarios from Firestore database dynamically

signal phishing_email_opened(email_data: Dictionary)
signal phishing_reported(email_id: String, correct: bool)

@onready var email_list_container = $HSplitContainer/MainArea/EmailList/MarginContainer/VBoxContainer/ScrollContainer/EmailListContainer
@onready var from_label = $HSplitContainer/MainArea/EmailViewer/EmailContent/VBoxContainer/EmailHeader/MetaContainer/MetaInfo/FromLabel
@onready var subject_label = $HSplitContainer/MainArea/EmailViewer/EmailContent/VBoxContainer/EmailHeader/SubjectLabel
@onready var date_label = $HSplitContainer/MainArea/EmailViewer/EmailContent/VBoxContainer/EmailHeader/MetaContainer/MetaInfo/DateLabel
@onready var email_body = $HSplitContainer/MainArea/EmailViewer/EmailContent/VBoxContainer/ScrollContainer/VBoxContainer/EmailBody
@onready var sender_icon = $HSplitContainer/MainArea/EmailViewer/EmailContent/VBoxContainer/EmailHeader/MetaContainer/SenderIcon

var current_email: Dictionary = {}
var emails := []
var scenario_manager: Node = null
var current_difficulty := "beginner"  # Default difficulty

func _ready():
	print("📧 Email App (Firestore): Initializing...")
	
	# Get or create ScenarioManager
	scenario_manager = get_node_or_null("/root/ScenarioManager")
	
	if not scenario_manager:
		# Create ScenarioManager if it doesn't exist
		print("📊 Email App: Creating ScenarioManager...")
		var manager_script = load("res://scripts/scenario_manager.gd")
		scenario_manager = manager_script.new()
		scenario_manager.name = "ScenarioManager"
		get_tree().root.add_child(scenario_manager)
	
	# Connect to signals
	if not scenario_manager.scenarios_loaded.is_connected(_on_scenarios_loaded):
		scenario_manager.scenarios_loaded.connect(_on_scenarios_loaded)
	
	if not scenario_manager.scenario_load_failed.is_connected(_on_load_failed):
		scenario_manager.scenario_load_failed.connect(_on_load_failed)
	
	# Detect difficulty from scene path or game state
	_detect_difficulty()
	
	# Show loading message
	_show_loading()
	
	# Fetch scenarios from Firestore
	emails = await scenario_manager.fetch_scenarios(current_difficulty)
	
	if emails.size() > 0:
		_populate_email_list()
	else:
		_show_no_scenarios()

func _detect_difficulty():
	"""Detect current difficulty level from game state or scene"""
	var scene_path = get_tree().current_scene.scene_file_path
	
	if "beginner" in scene_path.to_lower():
		current_difficulty = "beginner"
	elif "intermediate" in scene_path.to_lower():
		current_difficulty = "intermediate"
	elif "professional" in scene_path.to_lower():
		current_difficulty = "professional"
	
	print("📧 Email App: Detected difficulty level:", current_difficulty)

func _show_loading():
	"""Show loading message while fetching from Firestore"""
	# Clear existing
	for child in email_list_container.get_children():
		child.queue_free()
	
	var loading_label = Label.new()
	loading_label.text = "Loading emails..."
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	email_list_container.add_child(loading_label)
	
	# Show in viewer too
	email_body.text = "[center][color=#808080]Loading emails from inbox...[/color][/center]"

func _show_no_scenarios():
	"""Show message when no scenarios found"""
	for child in email_list_container.get_children():
		child.queue_free()
	
	var no_data_label = Label.new()
	no_data_label.text = "No emails in inbox"
	no_data_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	no_data_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	no_data_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	email_list_container.add_child(no_data_label)
	
	email_body.text = "[center][color=#D93025][b]No Emails Available[/b][/color]\n\n[color=#5F6368]No %s level scenarios found in database.[/color]\n\n[color=#5F6368]To add scenarios:[/color]\n[color=#5F6368]1. Go to Firebase Console[/color]\n[color=#5F6368]2. Navigate to Firestore Database[/color]\n[color=#5F6368]3. Add documents to 'scenarios' collection[/color][/center]" % current_difficulty

func _on_scenarios_loaded(scenarios: Array):
	"""Called when scenarios are successfully loaded from Firestore"""
	print("✅ Email App: Scenarios loaded successfully (%d scenarios)" % scenarios.size())
	emails = scenarios

func _on_load_failed(error: String):
	"""Called when scenario loading fails"""
	push_error("❌ Email App: Failed to load scenarios: " + error)
	_show_error(error)

func _show_error(error_message: String):
	"""Show error message"""
	email_body.text = "[center][color=#D93025][b]Error Loading Emails[/b][/color]\n\n[color=#5F6368]%s[/color]\n\n[color=#5F6368]Please check:[/color]\n[color=#5F6368]• Firebase authentication[/color]\n[color=#5F6368]• Firestore rules[/color]\n[color=#5F6368]• Internet connection[/color][/center]" % error_message

func _populate_email_list():
	"""Populate email list with sample emails"""
	var email_list = get_node_or_null("HSplitContainer/MainArea/EmailList/MarginContainer/VBoxContainer/ScrollContainer/EmailListContainer")
	if not email_list:
		push_error("❌ Email list container not found!")
		return
	
	# Clear existing items
	for child in email_list.get_children():
		child.queue_free()
	
	# Sample emails
	var emails = [
		{
			"from": "Bank Negara Malaysia",
			"subject": "Your Monthly Statement is Ready",
			"preview": "Dear valued customer, your statement for October 2024...",
			"time": "Yesterday, 3:00 PM",
			"unread": true,
			"is_phishing": true
		},
		{
			"from": "EPF/KWSP",
			"subject": "Account Verification Required",
			"preview": "Please verify your account details to avoid suspension...",
			"time": "2 days ago",
			"unread": true,
			"is_phishing": true
		},
		{
			"from": "Touch 'n Go",
			"subject": "Reload Bonus Available",
			"preview": "You have RM10 bonus waiting for you...",
			"time": "3 days ago",
			"unread": false,
			"is_phishing": false
		}
	]
	
	# Create email items
	for email in emails:
		var email_item = _create_email_list_item(email)
		email_list.add_child(email_item)

func _create_email_list_item(email_data: Dictionary) -> PanelContainer:
	"""Create a single email list item with proper styling"""
	var item = PanelContainer.new()
	item.custom_minimum_size = Vector2(0, 72)
	
	# Style the item
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 1) if not email_data.get("unread", false) else Color(0.95, 0.97, 1, 1)
	style.border_width_bottom = 1
	style.border_color = Color(0.9, 0.9, 0.9, 1)
	item.add_theme_stylebox_override("panel", style)
	
	# Add hover effect
	item.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Create content
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	item.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)
	
	# Top row (From + Time)
	var top_row = HBoxContainer.new()
	vbox.add_child(top_row)
	
	var from_label = Label.new()
	from_label.text = email_data.get("from", "Unknown")
	from_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
	from_label.add_theme_font_size_override("font_size", 14)
	if email_data.get("unread", false):
		from_label.add_theme_font_size_override("font_size", 15)
		# Make bold for unread
	from_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(from_label)
	
	var time_label = Label.new()
	time_label.text = email_data.get("time", "")
	time_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	time_label.add_theme_font_size_override("font_size", 12)
	top_row.add_child(time_label)
	
	# Subject
	var subject_label = Label.new()
	subject_label.text = email_data.get("subject", "No Subject")
	subject_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
	subject_label.add_theme_font_size_override("font_size", 14)
	subject_label.clip_text = true
	vbox.add_child(subject_label)
	
	# Preview
	var preview_label = Label.new()
	preview_label.text = email_data.get("preview", "")
	preview_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	preview_label.add_theme_font_size_override("font_size", 13)
	preview_label.clip_text = true
	vbox.add_child(preview_label)
	
	# Make clickable
	var button = Button.new()
	button.flat = true
	button.custom_minimum_size = item.custom_minimum_size
	button.pressed.connect(func(): _on_email_selected(email_data))
	item.add_child(button)
	
	return item

func _on_email_selected(email_data: Dictionary):
	"""Handle email selection"""
	print("📧 Email selected: ", email_data.get("subject", ""))
	
	# Store current email
	current_email = email_data
	
	# Show email in viewer
	_show_email_viewer(email_data)

func _show_email_viewer(email_data: Dictionary):
	"""Display email in the viewer panel"""
	var viewer = get_node_or_null("HSplitContainer/MainArea/EmailViewer/EmailContent/VBoxContainer")
	if not viewer:
		push_error("❌ Email viewer not found!")
		return
	
	# Update subject
	var subject = viewer.get_node_or_null("EmailHeader/SubjectLabel")
	if subject:
		subject.text = email_data.get("subject", "No Subject")
	
	# Update sender
	var sender_name = viewer.get_node_or_null("EmailHeader/MetaContainer/SenderInfo/SenderName")
	if sender_name:
		sender_name.text = email_data.get("from", "Unknown")
	
	var sender_email = viewer.get_node_or_null("EmailHeader/MetaContainer/SenderInfo/SenderEmail")
	if sender_email:
		sender_email.text = "<noreply@example.com>"  # Would extract from email_data
	
	# Update body in ScrollContainer
	var body_scroll = viewer.get_node_or_null("EmailBody/BodyScroll")
	if body_scroll:
		var body_label = body_scroll.get_node_or_null("BodyText")
		if body_label:
			body_label.text = email_data.get("body", email_data.get("preview", ""))
			
func _display_email(email: Dictionary):
	"""Display email content in Gmail style"""
	# Subject (large, bold)
	subject_label.text = email.subject
	
	# From info
	from_label.text = email.from
	
	# Date info
	date_label.text = email.date
	
	# Update sender icon color based on email
	if email.is_phishing:
		sender_icon.color = Color(0.85, 0.35, 0.13)  # Red for phishing
	else:
		sender_icon.color = Color(0.26, 0.52, 0.96)  # Blue for legitimate
	
	# Body with proper formatting and black text
	email_body.text = "[color=#202124]" + email.body + "[/color]"

func _on_inbox_pressed():
	"""Refresh inbox"""
	print("📥 Email App: Refreshing inbox from Firestore")
	_show_loading()
	emails = await scenario_manager.fetch_scenarios(current_difficulty)
	_populate_email_list()

func _on_report_phishing_pressed():
	"""Handle phishing report"""
	if current_email.is_empty():
		print("⚠️ Email App: No email selected")
		return
	
	var is_correct = current_email.get("is_phishing", false)
	var email_id = current_email.get("id", "unknown")
	
	print("🚨 Email App: Reporting phishing")
	print("   Scenario ID:", email_id)
	print("   Is Phishing:", is_correct)
	print("   User Correct:", is_correct)
	
	# Save to Firestore
	var score = current_email.get("points", 50) if is_correct else 0
	await scenario_manager.save_scenario_completion(
		email_id,
		score,
		1 if is_correct else 0,
		is_correct
	)
	
	emit_signal("phishing_reported", email_id, is_correct)
	
	# Show feedback
	if is_correct:
		var red_flags = current_email.get("red_flags", [])
		_show_feedback("✅ Correct! This is a phishing email.", red_flags, score)
	else:
		var green_flags = current_email.get("green_flags", [])
		_show_feedback("❌ Incorrect. This is a legitimate email.", green_flags, 0)

func _show_feedback(message: String, flags: Array, score: int):
	"""Show Gmail-style feedback dialog"""
	var dialog = AcceptDialog.new()
	dialog.title = "Phishing Detection Result"
	dialog.size = Vector2i(500, 400)
	
	# Build feedback text
	var feedback_text = "[b]%s[/b]\n\n" % message
	feedback_text += "[color=#1A73E8]Score:[/color] [b]%d points[/b]\n\n" % score
	
	if not flags.is_empty():
		feedback_text += "[b]Key Indicators:[/b]\n"
		for flag in flags:
			feedback_text += "• %s\n" % flag
	
	feedback_text += "\n[color=#5F6368][i]Progress saved to database[/i][/color]"
	
	dialog.dialog_text = message + "\n\nScore: " + str(score) + " points"
	
	add_child(dialog)
	dialog.popup_centered()
	
	# Print detailed feedback
	print("\n" + feedback_text)
	print("💾 Result saved to Firestore")
