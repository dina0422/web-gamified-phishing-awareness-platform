# res://scenario_completion_helper.gd
extends Node

## Helper script to connect scenario completion to quest tracker and leaderboard
## Add this as an autoload singleton: Project > Project Settings > Autoload

signal scenario_completed(scenario_id: String, score: int)
signal area_completed(area_name: String)

var current_scenario_score: int = 0

# ============================================
# SCENARIO COMPLETION
# ============================================

func complete_scenario(scenario_id: String, earned_points: int) -> void:
	"""Call this when player completes a phishing scenario"""
	print("✅ Scenario completed: %s (+%d points)" % [scenario_id, earned_points])
	
	current_scenario_score += earned_points
	scenario_completed.emit(scenario_id, earned_points)
	
	# Check if this was the last scenario in the area
	check_area_completion()

func check_area_completion() -> void:
	"""Check if all scenarios in current area are completed"""
	var quest_tracker = get_quest_tracker()
	if not quest_tracker:
		return
	
	# Get current scene name
	var current_scene := get_tree().current_scene.scene_file_path.get_file()
	
	# Check if all scenarios in this scene are done
	var scenario_controller = get_tree().current_scene.find_child("ScenarioController", true, false)
	if scenario_controller and scenario_controller.has_method("are_all_scenarios_complete"):
		if scenario_controller.are_all_scenarios_complete():
			complete_area(current_scene)

func complete_area(scene_name: String) -> void:
	"""Call this when player completes all scenarios in an area"""
	print("🎉 Area completed: %s" % scene_name)
	
	area_completed.emit(scene_name)
	
	# Notify quest tracker
	var quest_tracker = get_quest_tracker()
	if quest_tracker:
		quest_tracker.complete_scene(scene_name)

# ============================================
# SCORE MANAGEMENT
# ============================================

func get_current_score() -> int:
	"""Get cumulative score for current session"""
	return current_scenario_score

func reset_score() -> void:
	"""Reset score (e.g., when starting new role)"""
	current_scenario_score = 0
	print("🔄 Score reset")

# ============================================
# HELPER FUNCTIONS
# ============================================

func get_quest_tracker() -> Node:
	"""Get reference to QuestTracker node"""
	var quest_tracker = get_tree().current_scene.find_child("QuestTracker", true, false)
	if not quest_tracker:
		push_error("âŒ QuestTracker not found in scene!")
	return quest_tracker

func get_user_stats_hud() -> Node:
	"""Get reference to UserStatsHUD node"""
	var hud = get_tree().current_scene.find_child("UserStatsHUD", true, false)
	if not hud:
		push_error("âŒ UserStatsHUD not found in scene!")
	return hud

# ============================================
# QUICK ACCESS METHODS
# ============================================

func notify_correct_answer(points: int) -> void:
	"""Quick method to call when player makes correct phishing decision"""
	var hud = get_user_stats_hud()
	if hud:
		hud.add_score(points)

func notify_wrong_answer(penalty: int) -> void:
	"""Quick method to call when player makes wrong phishing decision"""
	var hud = get_user_stats_hud()
	if hud:
		hud.subtract_score(penalty)

func show_quest_update(objective: String, hint: String = "") -> void:
	"""Quick method to update quest objective"""
	var quest_tracker = get_quest_tracker()
	if quest_tracker:
		quest_tracker.update_objective(objective, hint)

# ============================================
# DEBUGGING
# ============================================

func _input(event: InputEvent) -> void:
	"""Debug shortcuts"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F9:
			print("\n=== COMPLETION HELPER DEBUG ===")
			print("Current Score: ", current_scenario_score)
			print("Quest Tracker Found: ", get_quest_tracker() != null)
			print("UserStatsHUD Found: ", get_user_stats_hud() != null)
			print("Current Scene: ", get_tree().current_scene.scene_file_path)
			print("==============================\n")
