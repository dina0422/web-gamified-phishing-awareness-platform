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
var exit_button

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
	
	# Assign buttons (assuming order: Start, Language, Exit)
	if buttons.size() >= 3:
		start_button = buttons[0]
		language_button = buttons[1]
		exit_button = buttons[2]
	
	# Try to find the welcome label if not found yet
	if not welcome_label:
		welcome_label = find_child("Label", true, false)
	
	# Connect button signals
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if language_button:
		language_button.pressed.connect(_on_language_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	
	# Initial UI update
	update_ui_text()

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
				
const NAME_INPUT_SCENE := "res://scenes/menu/name_input.tscn"

func _on_start_pressed() -> void:
	print("Start pressed")
	var err := get_tree().change_scene_to_file(NAME_INPUT_SCENE)
	if err != OK:
		push_error("Failed to change scene (%s): %s" % [NAME_INPUT_SCENE, err])
		
func _on_language_pressed() -> void:
	print("Language button pressed!")
	
	# Cycle to next language
	var current_index = available_languages.find(current_language)
	var next_index = (current_index + 1) % available_languages.size()
	current_language = available_languages[next_index]
	
	print("Changed to language: ", current_language)
	
	# Update all UI text
	update_ui_text()

func _on_exit_pressed() -> void:
	print("Exit pressed")
	get_tree().quit()
