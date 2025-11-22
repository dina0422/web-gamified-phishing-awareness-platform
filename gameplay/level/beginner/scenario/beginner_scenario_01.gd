extends Node

## Beginner Scenario 01
## Prize winning phishing email scenario

var scenario_controller: Node = null
var email_viewer: CanvasLayer = null
var decision_prompt: CanvasLayer = null
var educational_debrief: CanvasLayer = null

# Scenario data
var email_data = {
	"from": "prizewinners@totallylegit-prizes.com",
	"to": "you@email.com",
	"subject": "🎉 CONGRATULATIONS! You've Won $10,000!",
	"body": """Dear Winner,

We are THRILLED to inform you that YOUR EMAIL ADDRESS has been randomly selected in our GRAND PRIZE DRAW!

You have WON $10,000 in CASH! 💰

To claim your prize, simply click the link below and provide your bank account details for immediate transfer:

[CLAIM YOUR PRIZE NOW!]

URGENT: This offer expires in 24 hours! Act fast!

Best regards,
International Prize Committee
prizewinners@totallylegit-prizes.com"""
}

var question = "What should you do with this email?"

var options = [
	"Click the link to claim the prize immediately",
	"Reply asking for more information about the prize",
	"Delete the email - it's clearly a phishing attempt",
	"Forward it to friends so they can win too"
]

var correct_answer = 2  # Index of the correct option (Delete the email)

var points_for_options = [
	-50,  # Wrong: Click link
	-20,  # Wrong: Reply
	100,  # Correct: Delete
	-30   # Wrong: Forward
]

var red_flags = [
	"Suspicious sender email address (totallylegit-prizes.com)",
	"Unsolicited prize notification",
	"Creates false urgency (24 hour expiration)",
	"Requests sensitive financial information",
	"Generic greeting instead of your name",
	"Too good to be true offer"
]

var explanation = """This is a classic phishing scam. The sender is trying to trick you into providing your bank account details by offering a fake prize. 

Key red flags include:
- Suspicious email domain
- Unsolicited contact
- Requests for sensitive information
- Urgent pressure tactics
- Generic greetings

The correct action is to delete the email immediately and never click on links or provide personal information to unknown senders."""

var learning_points = """**What you should remember:**

1. **Verify the sender**: Always check if the email address is legitimate
2. **Question unexpected prizes**: If you didn't enter a contest, you didn't win
3. **Never share sensitive info**: Banks and legitimate companies never ask for account details via email
4. **Beware of urgency**: Scammers create false deadlines to pressure you
5. **When in doubt, delete**: It's always safer to delete suspicious emails

**Real-world tip**: If you receive an email claiming you won something from a real company, visit their official website directly (don't click email links) and contact their support team to verify."""

func _ready():
	scenario_controller = get_parent()
	
	if scenario_controller:
		print("✅ Beginner Scenario 01: Found scenario_controller")
	else:
		push_error("❌ Beginner Scenario 01: scenario_controller not found!")
		
func start_scenario():
	print("🎮 Starting Beginner Scenario 01...")
	
	if not email_viewer:
		push_error("❌ EmailViewer not found!")
		return
	
	# Display the phishing email
	email_viewer.display_email(email_data)
	
	# Connect signal to continue to decision phase
	if not email_viewer.continue_pressed.is_connected(_on_email_continue):
		email_viewer.continue_pressed.connect(_on_email_continue)

func _on_email_continue():
	print("📋 Showing decision prompt...")
	
	if not decision_prompt:
		push_error("❌ DecisionPrompt not found!")
		return
	
	# Show the decision prompt
	decision_prompt.setup_prompt(
		question,
		options,
		[correct_answer],
		points_for_options,
		"Think about what makes this email suspicious...",
		30.0  # 30 second time limit
	)
	
	# Connect to decision made signal
	if not decision_prompt.option_selected.is_connected(_on_decision_made):
		decision_prompt.option_selected.connect(_on_decision_made)

func _on_decision_made(option_index: int, option_text: String, points: int):
	print("✅ Decision made: ", option_text, " (", points, " points)")
	
	if not educational_debrief:
		push_error("❌ EducationalDebrief not found!")
		return
	
	# Show educational debrief
	var is_correct = (option_index == correct_answer)
	
	educational_debrief.show_debrief(
		is_correct,
		points,
		explanation,
		red_flags,
		learning_points,
		points,  # current_score (you'll need to get this from your game state)
		100      # max_score for this scenario
	)
	
	# Connect to completion signal
	if not educational_debrief.completed.is_connected(_on_scenario_complete):
		educational_debrief.completed.connect(_on_scenario_complete)

func _on_scenario_complete():
	print("🏁 Scenario 01 complete!")
	# Here you can transition to next scenario or return to level select
