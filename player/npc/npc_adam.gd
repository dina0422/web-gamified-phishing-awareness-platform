extends CharacterBody2D

@export var npc_display_name: String = "Adam"
@export var dialogues: Array[String] = [
	"Hey there! I need to talk to you about something important.",
	"I received a suspicious email earlier today...",
	"It claims I've won a prize, but something feels off about it.",
	"Can you help me figure out if it's legitimate or a phishing attempt?"
]

var dialogue_box: CanvasLayer = null
var scenario_controller: Node = null

func _ready():
	# Find DialogueBox in the scene tree
	dialogue_box = get_tree().current_scene.get_node_or_null("DialogueBox")
	
	if dialogue_box == null:
		dialogue_box = get_tree().current_scene.get_node_or_null("UserStatsHUD/DialogueBox")
	
	if dialogue_box == null:
		var nodes = get_tree().get_nodes_in_group("dialogue_box")
		if nodes.size() > 0:
			dialogue_box = nodes[0]
	
	if dialogue_box:
		print("✅ NPC Adam: Found DialogueBox")
	else:
		push_error("❌ NPC Adam: DialogueBox not found!")
	
	# Find ScenarioController
	scenario_controller = get_tree().current_scene.get_node_or_null("ScenarioController")
	
	if scenario_controller:
		print("✅ NPC Adam: Found ScenarioController")
	else:
		push_error("❌ NPC Adam: ScenarioController not found!")
		
	# Connect to dialogue signals
	if dialogue_box and dialogue_box.has_signal("start_phishing_simulation"):
		if not dialogue_box.start_phishing_simulation.is_connected(_on_start_phishing_simulation):
			dialogue_box.start_phishing_simulation.connect(_on_start_phishing_simulation)
			print("✅ NPC Adam: Connected to start_phishing_simulation signal")

# This function is called by the Interactable child node when player presses E
func interact():
	print("🗨️ NPC Adam: Starting interaction")
	
	if dialogue_box:
		dialogue_box.show_dialogue(npc_display_name, dialogues)
	else:
		push_error("❌ NPC Adam: Cannot show dialogue - DialogueBox not found!")

func _on_start_phishing_simulation():
	print("📧 NPC Adam: Triggering phishing simulation...")
	
	# Call start_scenario on ScenarioController
	if scenario_controller and scenario_controller.has_method("start_scenario"):
		print("✅ NPC Adam: Calling start_scenario()")
		scenario_controller.start_scenario()
	else:
		push_error("❌ NPC Adam: Cannot start scenario - ScenarioController not found or missing start_scenario() method!")
