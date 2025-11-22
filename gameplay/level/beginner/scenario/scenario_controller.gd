extends Node

## Scenario Controller
## Orchestrates the phishing awareness scenario flow
## Connects NPC dialogue -> Email display -> Decision -> Debrief

# References to UI components (found in living_room scene)
var email_viewer: CanvasLayer = null
var decision_prompt: CanvasLayer = null
var educational_debrief: CanvasLayer = null
var quest_tracker: CanvasLayer = null
var user_stats_hud: CanvasLayer = null
var player: CharacterBody2D = null

# Score tracking
var current_score: int = 0

# Scenario data for beginner level
var email_data = {
	"from": "noreply@winnerprize.com",
	"to": "you@email.com",
	"subject": "🎉 CONGRATULATIONS! You Won RM10,000!!!",
	"body": """Dear Lucky Winner,

CONGRATULATIONS! You have been selected as our GRAND PRIZE WINNER!

You have won RM10,000 in our special promotion!

To claim your prize, you must act IMMEDIATELY as this offer expires in 24 hours!

Click the link below to verify your identity and receive your prize:
http://bit.ly/claim-prize-now-urgent

This is a LIMITED TIME OFFER and spots are filling up fast!

Best regards,
Winner Claims Department
WinnerPrize International"""
}

# Decision options
var decision_question = "What should you do with this email?"
var decision_options = [
	"Click the link immediately to claim the prize",
	"Reply asking for more information",
	"Delete the email - it looks like a phishing scam",
	"Forward it to friends so they can win too"
]
var correct_answer_index = 2  # "Delete the email" is correct
var option_points = [-20, -10, 50, -30]  # Points for each option

# Educational content
var correct_explanation = """Excellent choice! You correctly identified this as a phishing scam.

This email has multiple red flags that indicate it's a fraudulent attempt to steal your personal information or money."""

var wrong_explanation = """This was actually a dangerous phishing scam that could have compromised your security.

Let's review why this email was suspicious and what you should watch out for in the future."""

var red_flags = [
	"Suspicious sender email (winnerprize.com - not a legitimate organization)",
	"Creates false urgency ('LIMITED TIME', 'expires in 24 hours')",
	"Too good to be true offer (RM10,000 prize you never entered)",
	"Shortened URL (bit.ly) hiding the real destination",
	"Requests immediate action without verification",
	"Generic greeting instead of your actual name",
	"Poor grammar and excessive exclamation marks"
]

var learning_points = """**Key Takeaways:**

• Always verify sender email addresses from official sources
• Be extremely suspicious of 'too good to be true' prize notifications
• Never click shortened URLs from unknown senders
• Legitimate companies won't create artificial urgency
• When in doubt, contact the company directly through their official website
• Delete suspicious emails and report them to IT security"""

func _ready():
	print("✅ ScenarioController: Ready")
	_find_components()
	_connect_signals()

func _find_components():
	"""Find all UI components in the scene tree"""
	var scene_root = get_tree().current_scene
	
	# Find EmailViewer
	email_viewer = scene_root.get_node_or_null("SimulationLayer/EmailViewer")
	if email_viewer:
		print("✅ ScenarioController: Found EmailViewer")
	else:
		push_error("❌ ScenarioController: EmailViewer not found!")
	
	# Find DecisionPrompt
	decision_prompt = scene_root.get_node_or_null("DecisionLayer/DecisionPrompt")
	if decision_prompt:
		print("✅ ScenarioController: Found DecisionPrompt")
	else:
		push_error("❌ ScenarioController: DecisionPrompt not found!")
	
	# Find EducationalDebrief
	educational_debrief = scene_root.get_node_or_null("DebriefLayer/EducationalDebrief")
	if educational_debrief:
		print("✅ ScenarioController: Found EducationalDebrief")
	else:
		push_error("❌ ScenarioController: EducationalDebrief not found!")
	
	# Find QuestTracker
	quest_tracker = scene_root.get_node_or_null("QuestTracker")
	if quest_tracker:
		print("✅ ScenarioController: Found QuestTracker")
	else:
		print("⚠️ ScenarioController: QuestTracker not found (optional)")
	
	# Find UserStatsHUD
	user_stats_hud = scene_root.get_node_or_null("UserStatsHUD")
	if user_stats_hud:
		print("✅ ScenarioController: Found UserStatsHUD")
	else:
		print("⚠️ ScenarioController: UserStatsHUD not found (optional)")
	
	# Find Player
	player = scene_root.get_node_or_null("Atok")
	if player:
		print("✅ ScenarioController: Found Player")

func _connect_signals():
	"""Connect signals from UI components"""
	if email_viewer and email_viewer.has_signal("continue_pressed"):
		email_viewer.continue_pressed.connect(_on_email_continue)
		print("✅ ScenarioController: Connected to email_viewer.continue_pressed")
	
	if decision_prompt and decision_prompt.has_signal("option_selected"):
		decision_prompt.option_selected.connect(_on_decision_made)
		print("✅ ScenarioController: Connected to decision_prompt.option_selected")
	
	if educational_debrief and educational_debrief.has_signal("continue_pressed"):
		educational_debrief.continue_pressed.connect(_on_debrief_continue)
		print("✅ ScenarioController: Connected to educational_debrief.continue_pressed")

# ========================================
# MAIN FLOW FUNCTIONS
# ========================================

func start_scenario():
	"""Start the phishing scenario - called by NPC Adam"""
	print("🎬 ScenarioController: Starting scenario")
	
	# Update quest tracker
	if quest_tracker and quest_tracker.has_method("show_quest"):
		quest_tracker.show_quest(
			"Phishing Awareness Training",
			"Review the suspicious email Adam received",
			"Look carefully for red flags and warning signs"
		)
	
	# Disable player movement
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	# Show the phishing email
	if email_viewer and email_viewer.has_method("display_email"):
		print("📧 ScenarioController: Displaying email...")
		email_viewer.display_email(email_data)
	else:
		push_error("❌ ScenarioController: Cannot display email!")

func _on_email_continue():
	"""Called when player clicks 'Continue' on email"""
	print("➡️ ScenarioController: Email viewed, showing decision prompt...")
	
	# Update quest
	if quest_tracker and quest_tracker.has_method("update_objective"):
		quest_tracker.update_objective(
			"Decide what to do with the email",
			"Think carefully about the red flags you identified"
		)
	
	# Hide email
	if email_viewer and email_viewer.has_method("hide_email"):
		await email_viewer.hide_email()
	
	# ⭐ CRITICAL FIX: Pass 'false' as last parameter to hide points for beginner
	if decision_prompt and decision_prompt.has_method("setup_prompt"):
		decision_prompt.setup_prompt(
			decision_question,
			decision_options,
			[correct_answer_index],  # Array of correct indices
			option_points,
			"Think about the red flags: urgency, suspicious sender, too good to be true...",  # Hint
			0.0,    # No time limit for beginner
			false   # ⭐ HIDE POINT VALUES FOR BEGINNER MODE
		)
		print("❓ ScenarioController: Decision prompt shown (beginner mode - points hidden)")
	else:
		push_error("❌ ScenarioController: Cannot show decision prompt!")

func _on_decision_made(option_index: int, option_text: String, points: int):
	"""Called when player selects an option"""
	print("✅ ScenarioController: Decision made")
	print("   Option Index: %d" % option_index)
	print("   Option Text: %s" % option_text)
	print("   Points: %d" % points)
	
	# Update score
	current_score += points
	print("   Current Score: %d" % current_score)
	
	# Update score in HUD
	if user_stats_hud and user_stats_hud.has_method("update_score"):
		user_stats_hud.update_score(current_score)
	
	# Check if correct
	var is_correct = (option_index == correct_answer_index)
	
	# Update quest
	if quest_tracker and quest_tracker.has_method("update_objective"):
		if is_correct:
			quest_tracker.update_objective(
				"Review the educational feedback",
				"Learn why this was the correct choice"
			)
		else:
			quest_tracker.update_objective(
				"Learn from the feedback",
				"Understand what went wrong and how to improve"
			)
	
	# Hide decision prompt
	if decision_prompt and decision_prompt.has_method("hide_prompt"):
		await decision_prompt.hide_prompt()
	
	# Wait a moment for smooth transition
	await get_tree().create_timer(0.3).timeout
	
	# Prepare debrief data
	var debrief_dict = {
		"correct": is_correct,
		"points": points,
		"explanation": correct_explanation if is_correct else wrong_explanation,
		"red_flags": red_flags,
		"learning_points": learning_points,
		"current_score": current_score,
		"max_score": 100
	}
	
	# Show educational debrief
	if educational_debrief and educational_debrief.has_method("show_debrief"):
		print("📚 ScenarioController: Showing educational debrief...")
		educational_debrief.show_debrief(debrief_dict)
	else:
		push_error("❌ ScenarioController: Cannot show debrief!")

func _on_debrief_continue():
	"""Called when player finishes reading debrief"""
	print("✅ ScenarioController: Scenario complete!")
	
	# Complete quest
	if quest_tracker and quest_tracker.has_method("complete_quest"):
		quest_tracker.complete_quest()
	
	# Hide debrief
	if educational_debrief and educational_debrief.has_method("hide_debrief"):
		await educational_debrief.hide_debrief()
	
	# Re-enable player movement
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)
	
	# TODO: Save score to Firebase
	# TODO: Update user stats in Firestore
	# TODO: Mark scenario as complete in user progress
	# TODO: Update leaderboard if high score
	
	print("🎮 ScenarioController: Player can move again")
	print("📊 Final Score: %d" % current_score)

# ========================================
# QUEST TRACKER HELPER METHODS
# ========================================

func update_quest_objective(objective: String, hint: String = ""):
	"""Helper method to update quest tracker"""
	if quest_tracker and quest_tracker.has_method("update_objective"):
		quest_tracker.update_objective(objective, hint)

func show_quest(title: String, objective: String, hint: String = ""):
	"""Helper method to show new quest"""
	if quest_tracker and quest_tracker.has_method("show_quest"):
		quest_tracker.show_quest(title, objective, hint)

func complete_current_quest():
	"""Helper method to complete quest"""
	if quest_tracker and quest_tracker.has_method("complete_quest"):
		quest_tracker.complete_quest()
