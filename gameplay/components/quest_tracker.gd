extends CanvasLayer

## Quest Tracker UI
## Shows current objectives/tasks in the top-left corner

@onready var panel = $Panel
@onready var quest_title = $Panel/MarginContainer/VBoxContainer/QuestTitle
@onready var objective_label = $Panel/MarginContainer/VBoxContainer/ObjectiveLabel
@onready var hint_label = $Panel/MarginContainer/VBoxContainer/HintLabel

var current_objective: String = ""
var current_hint: String = ""

func _ready():
	# Start hidden or show initial quest
	show_quest("Welcome to PhishProof", "Find and talk to Adam", "Look for the NPC with a phone")

func show_quest(title: String, objective: String, hint: String = ""):
	"""Display a quest/objective"""
	quest_title.text = title
	objective_label.text = "📍 " + objective
	
	if hint != "":
		hint_label.text = "💡 Tip: " + hint
		hint_label.show()
	else:
		hint_label.hide()
	
	current_objective = objective
	current_hint = hint
	
	# Animate in
	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.3)
	
	print("✅ QuestTracker: Showing quest - %s" % objective)

func update_objective(new_objective: String, hint: String = ""):
	"""Update the current objective"""
	show_quest(quest_title.text, new_objective, hint)

func complete_quest():
	"""Mark quest as complete and hide"""
	objective_label.text = "✅ " + current_objective + " (Complete!)"
	
	# Wait a bit then fade out
	await get_tree().create_timer(2.0).timeout
	
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished
	
	panel.hide()

func hide_quest():
	"""Hide the quest tracker"""
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished
	panel.hide()
