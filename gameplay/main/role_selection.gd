extends Control



func _on_back_pressed():
	get_tree().change_scene_to_file("res://gameplay/main/name_input.tscn")


func _on_next_pressed():
	pass # Replace with function body.


func _on_civilian_pressed():
	get_tree().change_scene_to_file("res://gameplay/level/beginner/living_room.tscn")


func _on_intermediate_pressed():
	get_tree().change_scene_to_file("res://gameplay/level/intermediate/office.tscn")


func _on_professional_pressed():
	get_tree().change_scene_to_file("res://gameplay/level/professional/soc_office.tscn")
