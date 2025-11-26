extends CanvasLayer

signal dialogue_finished
signal start_phishing_simulation

@onready var panel = $Panel
@onready var npc_name_label = $Panel/MarginContainer/VBoxContainer/NPCName
@onready var dialogue_text = $Panel/MarginContainer/VBoxContainer/DialogueText
@onready var continue_button = $Panel/MarginContainer/VBoxContainer/ContinueButton

var dialogue_queue: Array = []
var current_dialogue_index: int = 0
var is_active: bool = false

# ✅ NEW: Reference to menu buttons
var menu_buttons: CanvasLayer = null

func _ready():
	hide_dialogue()
	continue_button.pressed.connect(_on_continue_pressed)
	# Update button text to show the correct key
	continue_button.text = "Continue (Enter)"
	
	# ✅ NEW: Find menu buttons reference
	menu_buttons = get_tree().current_scene.find_child("GameMenuButtons", true, false)
	if menu_buttons:
		print("✅ DialogueBox: Found menu buttons reference")

func _input(event):
	# Changed from "interact" to "ui_accept" (Enter/Space)
	if event.is_action_pressed("ui_accept") and is_active and panel.visible:
		_on_continue_pressed()

func show_dialogue(npc_name: String, dialogues: Array):
	dialogue_queue = dialogues
	current_dialogue_index = 0
	npc_name_label.text = npc_name
	is_active = true
	
	# ✅ NEW: Hide menu buttons during dialogue
	if menu_buttons:
		menu_buttons.visible = false
		print("🔒 DialogueBox: Menu buttons hidden")
	
	panel.show()
	_display_current_dialogue()

func _display_current_dialogue():
	if current_dialogue_index < dialogue_queue.size():
		var current = dialogue_queue[current_dialogue_index]
		dialogue_text.text = current
		continue_button.show()
	else:
		finish_dialogue()

func _on_continue_pressed():
	current_dialogue_index += 1
	
	if current_dialogue_index < dialogue_queue.size():
		_display_current_dialogue()
	else:
		finish_dialogue()

func finish_dialogue():
	hide_dialogue()
	
	# ✅ NEW: Show menu buttons after dialogue
	if menu_buttons:
		menu_buttons.visible = true
		print("🔓 DialogueBox: Menu buttons restored")
	
	dialogue_finished.emit()
	
	# After dialogue, trigger the phishing simulation
	await get_tree().create_timer(0.5).timeout
	start_phishing_simulation.emit()

func hide_dialogue():
	is_active = false
	panel.hide()
	continue_button.hide()
