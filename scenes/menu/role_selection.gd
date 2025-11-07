extends Control



func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/name_input.tscn")


func _on_next_pressed():
	pass # Replace with function body.


func _on_civilian_pressed():
	get_tree().change_scene_to_file("res://level/beginner/beginner.tscn")


func _on_intermediate_pressed():
	get_tree().change_scene_to_file("res://level/intermediate/intermediate.tscn")


func _on_professional_pressed():
	get_tree().change_scene_to_file("res://level/professional/professional.tscn")
