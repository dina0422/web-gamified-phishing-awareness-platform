extends Control



func _on_back_pressed():
	get_tree().change_scene_to_file("res://gameplay/main/name_input.tscn")


func _on_next_pressed():
	pass # Replace with function body.


func _on_civilian_pressed():
	# Reset progress before starting the level
	_reset_role_progress("beginner")
	get_tree().change_scene_to_file("res://gameplay/level/beginner/living_room.tscn")


func _on_intermediate_pressed():
	# Reset progress before starting the level
	_reset_role_progress("intermediate")
	get_tree().change_scene_to_file("res://gameplay/level/intermediate/office.tscn")


func _on_professional_pressed():
	# Reset progress before starting the level
	_reset_role_progress("professional")
	get_tree().change_scene_to_file("res://gameplay/level/professional/soc_office.tscn")


func _reset_role_progress(role: String) -> void:
	"""Reset quest progress when starting a role from menu"""
	# Load quest_tracker script and call static reset method
	var quest_tracker_script = load("res://quest_tracker.gd")
	if quest_tracker_script:
		quest_tracker_script.reset_role_progress_static(role)
		print("✅ Quest progress cleared for new game: %s" % role)
	else:
		push_error("❌ Failed to load quest_tracker script!")
	
	# Also reset user stats score
	var stats_script = load("res://user_stats_hud.gd")
	if stats_script and stats_script.has_method("reset_score_static"):
		stats_script.reset_score_static()
		print("✅ Score reset for new game")
