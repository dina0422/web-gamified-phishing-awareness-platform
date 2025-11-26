extends Control

# Desktop OS Manager
# Handles window management, app launching, and desktop interactions

signal app_opened(app_name: String)
signal app_closed(app_name: String)
signal phishing_scenario_triggered(scenario_type: String)

@onready var window_container = $WindowContainer
@onready var desktop_icons = $DesktopIcons
@onready var taskbar_apps = $Taskbar/HBoxContainer/TaskbarApps
@onready var notification_popup = $NotificationPopup
@onready var time_label = $Taskbar/HBoxContainer/SystemTray/TimeLabel

# Preload window scenes
const WINDOW_TEMPLATE = preload("res://gameplay/desktop/window.tscn")
const EMAIL_APP = preload("res://gameplay/desktop/apps/email_app.tscn")
const BROWSER_APP = preload("res://gameplay/desktop/apps/browser_app.tscn")
const MESSENGER_APP = preload("res://gameplay/desktop/apps/messenger_app.tscn")

var active_windows := []
var desktop_apps := {
	"Email": {
		"icon": "📧",
		"scene": EMAIL_APP,
		"title": "Email Client"
	},
	"Browser": {
		"icon": "🌐",
		"scene": BROWSER_APP,
		"title": "Web Browser"
	},
	"Messages": {
		"icon": "💬",
		"scene": MESSENGER_APP,
		"title": "Messages"
	}
}

func _ready():
	print("🖥️ Desktop OS: Initializing...")
	_setup_desktop_icons()
	_update_time()
	
	# Update time every second
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_update_time)
	add_child(timer)
	timer.start()
	
	# Show welcome notification after a delay
	await get_tree().create_timer(2.0).timeout
	show_notification("Welcome!", "Check your emails for important messages.")

func _setup_desktop_icons():
	# Clear existing icons
	for child in desktop_icons.get_children():
		child.queue_free()
	
	# Create desktop icons for each app
	for app_name in desktop_apps:
		var app_data = desktop_apps[app_name]
		var icon_button = Button.new()
		icon_button.custom_minimum_size = Vector2(120, 100)
		icon_button.text = app_data.icon + "\n" + app_name
		icon_button.pressed.connect(_on_desktop_icon_pressed.bind(app_name))
		desktop_icons.add_child(icon_button)

func _on_desktop_icon_pressed(app_name: String):
	print("🖱️ Desktop OS: Opening app -", app_name)
	open_app(app_name)

func open_app(app_name: String):
	if not desktop_apps.has(app_name):
		push_error("App not found: " + app_name)
		return
	
	var app_data = desktop_apps[app_name]
	
	# Check if app is already open
	for window in active_windows:
		if window.window_title == app_data.title:
			window.bring_to_front()
			return
	
	# Create new window
	var window = WINDOW_TEMPLATE.instantiate()
	window.window_title = app_data.title
	window.position = Vector2(100 + active_windows.size() * 50, 80 + active_windows.size() * 50)
	
	# Connect signals
	window.close_requested.connect(_on_window_closed.bind(window))
	
	# Add window to tree FIRST
	window_container.add_child(window)
	active_windows.append(window)
	
	# NOW set content (after @onready vars are initialized)
	var app_content = app_data.scene.instantiate()
	window.set_content(app_content)
	
	# Connect app-specific signals
	if app_content.has_signal("phishing_email_opened"):
		app_content.phishing_email_opened.connect(_on_phishing_scenario_triggered)
	
	# Add to taskbar
	_add_taskbar_button(app_name, window)
	
	emit_signal("app_opened", app_name)
	
func _add_taskbar_button(app_name: String, window: Control):
	var taskbar_button = Button.new()
	taskbar_button.text = desktop_apps[app_name].icon + " " + app_name
	taskbar_button.toggle_mode = true
	taskbar_button.button_pressed = true
	taskbar_button.pressed.connect(func(): window.toggle_minimize())
	
	# Store reference to button in window
	window.set_meta("taskbar_button", taskbar_button)
	taskbar_apps.add_child(taskbar_button)

func _on_window_closed(window: Control):
	print("🪟 Desktop OS: Closing window -", window.window_title)
	
	# Remove taskbar button
	if window.has_meta("taskbar_button"):
		var button = window.get_meta("taskbar_button")
		button.queue_free()
	
	# Remove from active windows
	active_windows.erase(window)
	window.queue_free()
	
	emit_signal("app_closed", window.window_title)

func show_notification(title: String, message: String, duration: float = 5.0):
	print("🔔 Desktop OS: Showing notification -", title)
	
	notification_popup.get_node("MarginContainer/VBoxContainer/Title").text = title
	notification_popup.get_node("MarginContainer/VBoxContainer/Message").text = message
	notification_popup.visible = true
	
	# Auto-hide after duration
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		if notification_popup.visible:
			notification_popup.visible = false

func _on_notification_button_pressed():
	notification_popup.visible = not notification_popup.visible

func _on_notification_close_pressed():
	notification_popup.visible = false

func _on_start_button_pressed():
	print("🏠 Desktop OS: Start menu pressed")
	# TODO: Implement start menu
	show_notification("Start Menu", "Start menu coming soon!")

func _update_time():
	var time_dict = Time.get_time_dict_from_system()
	var hour = time_dict.hour
	var minute = time_dict.minute
	var period = "AM" if hour < 12 else "PM"
	
	# Convert to 12-hour format
	if hour == 0:
		hour = 12
	elif hour > 12:
		hour -= 12
	
	time_label.text = "%02d:%02d %s" % [hour, minute, period]

func _on_phishing_scenario_triggered(scenario_data: Dictionary):
	print("🎯 Desktop OS: Phishing scenario triggered -", scenario_data)
	emit_signal("phishing_scenario_triggered", scenario_data.get("type", "unknown"))

# Public API for scenarios to trigger notifications
func trigger_phishing_notification(title: String, message: String):
	show_notification(title, message, 0.0)  # Don't auto-hide

# Public API to open specific app (called from chair interaction)
func launch_email_app():
	open_app("Email")

func launch_browser():
	open_app("Browser")

func launch_messenger():
	open_app("Messages")
