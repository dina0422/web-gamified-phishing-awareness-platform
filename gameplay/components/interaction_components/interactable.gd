extends Area2D
class_name InteractableNPC

## This script goes on the "Interactable" Area2D child node
## It provides the interface for the InteractingComponent system

# Properties that InteractingComponent expects
@export var interact_name: String = "Talk to Adam"
@export var is_interactable: bool = true

# Reference to parent NPC
var parent_npc: Node = null

func _ready():
	# Get reference to parent NPC
	parent_npc = get_parent()
	print("✅ Interactable: Connected to parent -", parent_npc.name)

# This function is called by InteractingComponent when player presses E
func interact():
	print("🔔 Interactable: interact() called")
	# Call the parent NPC's interact function
	if parent_npc and parent_npc.has_method("interact"):
		await parent_npc.interact()
	else:
		push_error("Parent NPC doesn't have interact() method!")
