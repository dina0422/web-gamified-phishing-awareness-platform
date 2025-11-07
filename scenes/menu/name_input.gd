extends Control

func _ready() -> void:
	$HBoxContainer/enter.pressed.connect(on_button_pressed)
	
const ROLE_SELECTION_SCENE := "res://scenes/menu/role_selection.tscn"

func on_button_pressed() -> void:
	print("Enter pressed")
	var err := get_tree().change_scene_to_file(ROLE_SELECTION_SCENE)
	if err != OK:
		push_error("Failed to change scene (%s): %s" % [ROLE_SELECTION_SCENE, err])


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://main-menu.tscn") # Replace with function body.


func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/role_selection.tscn")
