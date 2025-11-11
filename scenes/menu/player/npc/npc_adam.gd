extends CharacterBody2D

@onready var interactable = $Interactable
@onready var sprite_2d = $Sprite2D

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	if sprite_2d.frame == 0:
		sprite_2d.frame = 1
		interactable.is_interactable = false
		print("talking with Adam")
		
	
