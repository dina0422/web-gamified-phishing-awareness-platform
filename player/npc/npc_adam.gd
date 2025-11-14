extends CharacterBody2D

@export var npc_display_name: String = "Adam"
@export var dialogues: Array[String] = [
	"Hey there! I need to talk to you about something important.",
	"I received a suspicious email earlier today...",
	"It claims I've won a prize, but something feels off about it.",
	"Can you help me figure out if it's legitimate or a phishing attempt?"
]

var dialogue_box: CanvasLayer = null
var player_in_range: bool = false

func _ready():
	# Try to find DialogueBox in the scene tree
	# First check if it's in the current scene
	dialogue_box = get_tree().current_scene.get_node_or_null("DialogueBox")
	
	# If not found, check if it's a child of a CanvasLayer
	if dialogue_box == null:
		dialogue_box = get_tree().current_scene.get_node_or_null("UserStatsHUD/DialogueBox")
	
	# Last resort: search the entire tree
	if dialogue_box == null:
		var nodes = get_tree().get_nodes_in_group("dialogue_box")
		if nodes.size() > 0:
			dialogue_box = nodes[0]
	
	# Debug: Print whether we found the DialogueBox
	if dialogue_box:
		print("✅ NPC Adam: Found DialogueBox")
	else:
		push_error("❌ NPC Adam: DialogueBox not found!")
		
	# Connect to signals if DialogueBox exists
	if dialogue_box and dialogue_box.has_signal("start_phishing_simulation"):
		if not dialogue_box.start_phishing_simulation.is_connected(_on_start_phishing_simulation):
			dialogue_box.start_phishing_simulation.connect(_on_start_phishing_simulation)
			print("✅ NPC Adam: Connected to start_phishing_simulation signal")

# This function is called by the Interactable child node when player presses E
func interact():
	print("🗨️ NPC Adam: Starting interaction")
	
	if dialogue_box:
		# Show the dialogue
		dialogue_box.show_dialogue(npc_display_name, dialogues)
	else:
		push_error("Cannot show dialogue - DialogueBox not found!")

func _on_dialogue_finished():
	print("✅ NPC Adam: Dialogue finished")
	# Add any cleanup or post-dialogue logic here

func _on_start_phishing_simulation():
	print("📧 NPC Adam: Starting phishing simulation")
	# This is where you'd trigger the phone/email simulation
	# For example:
	# var phone_scene = preload("res://iphone.tscn").instantiate()
	# get_tree().current_scene.add_child(phone_scene)
