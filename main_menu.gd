extends Control

# Simple built-in language manager (no autoload needed)
var current_language: String = "en"
var available_languages: Array = ["en", "ms", "zh"]

var translations: Dictionary = {
	"en": {
		"welcome": "Welcome to PhishProof let's see if you'd get scammed 🎃",
		"start": "Get Started",
		"exit": "EXIT"
	},
	"ms": {
		"welcome": "Selamat Datang ke PhishProof mari lihat jika anda tertipu 🎃",
		"start": "Mula",
		"exit": "KELUAR"
	},
	"zh": {
		"welcome": "欢迎来到 PhishProof 让我们看看你会不会上当 🎃",
		"start": "开始",
		"exit": "退出"
	}
}

# Node references
var welcome_label
var start_button
var language_button
var restart_button
var exit_button

# Firebase initialization state
var firebase_initializing: bool = false
var firebase_ready: bool = false

func _ready() -> void:
	# Find the VBoxContainer
	var vbox = $VBoxContainer
	
	# Get buttons from VBoxContainer
	var buttons = []
	for child in vbox.get_children():
		if child is Button:
			buttons.append(child)
		elif child is Label:
			welcome_label = child
	
	# Assign buttons (assuming order: Start, Language, Restart, Exit)
	if buttons.size() >= 4:
		start_button = buttons[0]
		language_button = buttons[1]
		restart_button = buttons[2]
		exit_button = buttons[3]
	
	# Try to find the welcome label if not found yet
	if not welcome_label:
		welcome_label = find_child("Label", true, false)
	
	# Connect button signals
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if language_button:
		language_button.pressed.connect(_on_language_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	
	# Initial UI update
	update_ui_text()
	
	# Initialize Firebase in background - DON'T BLOCK UI!
	_initialize_firebase_background()

func _initialize_firebase_background() -> void:
	"""Initialize Firebase without blocking the UI"""
	if firebase_initializing or firebase_ready:
		return
	
	firebase_initializing = true
	print("🔥 Main Menu: Initializing Firebase in background...")
	
	var success = await Firebase.sign_in_anonymous()
	
	firebase_initializing = false
	firebase_ready = success
	
	if success:
		print("✅ Main Menu: Firebase ready")
		# Update button text if display name is available
		if start_button and Firebase.display_name != "":
			print("👤 Main Menu: Welcome back, ", Firebase.display_name)
	else:
		print("⚠️ Main Menu: Firebase initialization failed (game will still work)")

func get_text(key: String) -> String:
	if current_language in translations and key in translations[current_language]:
		return translations[current_language][key]
	return key

func update_ui_text():
	print("Updating UI to language: ", current_language)
	
	# Load the appropriate theme based on language
	if current_language == "zh":
		var chinese_theme = load("res://assets/fonts/chinese_theme.tres")
		print("Loaded Chinese theme: ", chinese_theme)
		self.theme = chinese_theme
		
		# Set Chinese font directly on the label
		if welcome_label:
			var chinese_font = load("res://assets/fonts/NotoSansSC-VariableFont_wght.ttf")
			welcome_label.add_theme_font_override("font", chinese_font)
	else:
		self.theme = null
		
		# Set Minecraft font for English/Malay
		if welcome_label:
			var minecraft_font = load("res://assets/fonts/Minecraft.ttf")
			welcome_label.add_theme_font_override("font", minecraft_font)
	
	print("Current theme: ", self.theme)
	
	if welcome_label:
		var welcome_text = get_text("welcome")
		print("Setting welcome label to: ", welcome_text)
		welcome_label.text = welcome_text
		print("Welcome label text is now: ", welcome_label.text)
		print("Welcome label theme: ", welcome_label.theme)
	
	if start_button:
		start_button.text = get_text("start")
	
	if exit_button:
		exit_button.text = get_text("exit")
	
	if language_button:
		match current_language:
			"en":
				language_button.text = "Language: English"
			"ms":
				language_button.text = "Bahasa: Melayu"
			"zh":
				language_button.text = "语言：中文"
				
const NAME_INPUT_SCENE := "res://gameplay/main/name_input.tscn"
const ROLE_SELECTION_SCENE := "res://gameplay/main/role_selection.tscn" 

func _on_start_pressed() -> void:
	print("🎮 Main Menu: Get Started button pressed!")
	
	# Disable button to prevent double-clicks
	if start_button:
		start_button.disabled = true
	
	# Check if Firebase is ready
	if not firebase_ready and not firebase_initializing:
		print("⏳ Main Menu: Firebase not initialized yet, initializing now...")
		await _initialize_firebase_background()
	elif firebase_initializing:
		print("⏳ Main Menu: Waiting for Firebase initialization...")
		# Wait for initialization to complete
		while firebase_initializing:
			await get_tree().process_frame
	
	# If Firebase failed to initialize, try one more time
	if not firebase_ready:
		print("🔄 Main Menu: Retrying Firebase sign-in...")
		var success = await Firebase.sign_in_anonymous()
		if not success:
			# Show error dialog
			_show_error_dialog(
				"Connection Error",
				"Failed to connect to Firebase. Please check your internet connection."
			)
			if start_button:
				start_button.disabled = false
			return
	
	# Now check if user has a display name
	var has_display_name = false
	
	# Check Firebase display_name first
	if Firebase.display_name != "":
		has_display_name = true
		print("✅ Main Menu: User has display name: ", Firebase.display_name)
	else:
		# Check local profile file using public method
		var profile_data = _check_local_profile()
		if profile_data.has("displayName") and str(profile_data["displayName"]).strip_edges() != "":
			Firebase.display_name = str(profile_data["displayName"])
			has_display_name = true
			print("✅ Main Menu: Loaded display name from local cache: ", Firebase.display_name)
	
	# Navigate to appropriate scene
	if has_display_name:
		print("➡️ Main Menu: Navigating to role selection...")
		var err = get_tree().change_scene_to_file(ROLE_SELECTION_SCENE)
		if err != OK:
			push_error("❌ Failed to change to role selection scene! Error: %d" % err)
			_show_error_dialog("Scene Error", "Failed to load role selection scene. Error code: %d" % err)
			if start_button:
				start_button.disabled = false
	else:
		print("➡️ Main Menu: Navigating to name input...")
		print("Scene path: %s" % NAME_INPUT_SCENE)
		var err = get_tree().change_scene_to_file(NAME_INPUT_SCENE)
		print("Scene change result: %d (0 = OK)" % err)
		if err != OK:
			push_error("❌ Failed to change to name input scene! Error: %d" % err)
			_show_error_dialog("Scene Error", "Failed to load name input scene. Error code: %d" % err)
			if start_button:
				start_button.disabled = false

func _check_local_profile() -> Dictionary:
	"""Safe wrapper to check local profile without accessing private method"""
	const PROFILE_FILE := "user://profile.json"
	
	if not FileAccess.file_exists(PROFILE_FILE):
		return {}
	
	var f := FileAccess.open(PROFILE_FILE, FileAccess.READ)
	if not f:
		return {}
	
	var j = JSON.parse_string(f.get_as_text())
	f.close()
	
	return j if typeof(j) == TYPE_DICTIONARY else {}

func _show_error_dialog(title: String, message: String) -> void:
	"""Show an error dialog to the user"""
	var dialog := AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = title
	dialog.ok_button_text = "OK"
	
	add_child(dialog)
	dialog.popup_centered()
	
	# Clean up after dialog is closed
	dialog.confirmed.connect(func():
		dialog.queue_free()
	)
		
func _on_language_pressed() -> void:
	print("Language button pressed!")
	
	# Cycle to next language
	var current_index = available_languages.find(current_language)
	var next_index = (current_index + 1) % available_languages.size()
	current_language = available_languages[next_index]
	
	print("Changed to language: ", current_language)
	
	# Update all UI text
	update_ui_text()

func _on_restart_pressed()-> void:
	var dialog = ConfirmationDialog.new()
	
	dialog.dialog_text = "Clear all data and start fresh?"
	dialog.confirmed.connect(
		func():
		DirAccess.remove_absolute("user://fbase_session.json")
		DirAccess.remove_absolute("user://profile.json")
		Firebase.uid = ""	
		Firebase.display_name = ""
		firebase_ready = false
		firebase_initializing = false
		print("✅ Reset complete!")
		# Reinitialize Firebase
		_initialize_firebase_background()
		)
	add_child(dialog)
	dialog.popup_centered()
	
func _on_exit_pressed() -> void:
	print("Exit pressed")
	get_tree().quit()
