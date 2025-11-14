extends CanvasLayer

signal simulation_completed(score: int, feedback: String)

@onready var option_a = $CenterContainer/PhoneFrame/MarginContainer/VBoxContainer/QuestionPanel/MarginContainer2/VBoxContainer2/OptionA
@onready var option_b = $CenterContainer/PhoneFrame/MarginContainer/VBoxContainer/QuestionPanel/MarginContainer2/VBoxContainer2/OptionB
@onready var option_c = $CenterContainer/PhoneFrame/MarginContainer/VBoxContainer/QuestionPanel/MarginContainer2/VBoxContainer2/OptionC
@onready var option_d = $CenterContainer/PhoneFrame/MarginContainer/VBoxContainer/QuestionPanel/MarginContainer2/VBoxContainer2/OptionD
@onready var back_button = $CenterContainer/PhoneFrame/MarginContainer/VBoxContainer/Header/HBoxContainer/BackButton

var scenario_data = {
	"scenario_name": "MyEG Account Verification Scam",
	"difficulty": "beginner",
	"phishing_indicators": [
		"Suspicious URL (myeg-verify-my.com instead of official myeg.com.my)",
		"Urgency tactics (24 hours warning)",
		"Threat of penalty (RM500 fine)",
		"Generic greeting (tuan/puan instead of personal name)",
		"Request to click external link",
		"Unsolicited account freeze notification"
	],
	"correct_answer": "C",  # Call official helpline
	"answer_scores": {
		"A": 0,    # Worst - clicking phishing link
		"B": 75,   # Good - recognizing it's a scam
		"C": 100,  # Best - verify through official channels
		"D": 0     # Worst - spreading the scam
	},
	"feedback": {
		"A": "❌ INCORRECT!\n\nNever click suspicious links! This is a phishing attempt.\n\nRed flags:\n• Fake URL (not official MyEG domain)\n• Creates false urgency\n• Threatens penalties\n• Requests personal verification\n\nAlways verify through official channels!",
		"B": "✓ GOOD!\n\nYou recognized this as a phishing attempt! That's important.\n\nHowever, the BEST action is to:\n• Report it to the company\n• Verify through official channels\n• Help prevent others from falling victim\n\nJust ignoring might leave others at risk.",
		"C": "✓✓ EXCELLENT!\n\nPerfect response! You:\n✓ Didn't click the suspicious link\n✓ Recognized the phishing indicators\n✓ Chose to verify through official channels\n✓ Protected your personal information\n\nKey red flags you spotted:\n• Fake domain (myeg-verify-my.com)\n• Urgency tactics (24-hour deadline)\n• Threatening penalty\n• Generic greeting\n\nAlways contact companies directly using official contact info!",
		"D": "❌ INCORRECT!\n\nNEVER forward suspicious messages! This would:\n• Spread the scam to more victims\n• Put your contacts at risk\n• Help scammers reach more people\n\nInstead:\n• Delete the message\n• Report it to authorities\n• Warn others it's a scam without forwarding\n\nHelp stop scams, don't spread them!"
	}
}

func _ready():
	option_a.pressed.connect(_on_option_selected.bind("A"))
	option_b.pressed.connect(_on_option_selected.bind("B"))
	option_c.pressed.connect(_on_option_selected.bind("C"))
	option_d.pressed.connect(_on_option_selected.bind("D"))
	back_button.pressed.connect(_on_back_pressed)
	
	# Hide initially
	hide()

func start_simulation():
	show()

func _on_option_selected(answer: String):
	var score = scenario_data["answer_scores"][answer]
	var feedback = scenario_data["feedback"][answer]
	
	# Disable all buttons after selection
	option_a.disabled = true
	option_b.disabled = true
	option_c.disabled = true
	option_d.disabled = true
	
	# Show feedback and emit completion
	await get_tree().create_timer(0.5).timeout
	simulation_completed.emit(score, feedback)
	
	# Store the result in Firebase
	_save_simulation_result(answer, score)

func _save_simulation_result(answer: String, score: int):
	# This will be called by the main game script to integrate with Firebase
	var simulation_result = {
		"scenario": scenario_data["scenario_name"],
		"difficulty": scenario_data["difficulty"],
		"answer_selected": answer,
		"score": score,
		"correct_answer": scenario_data["correct_answer"],
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Access the Firebase singleton/autoload
	if has_node("/root/Firebase"):
		var firebase = get_node("/root/Firebase")
		# Call Firebase save function
		# firebase.save_simulation_result(simulation_result)

func _on_back_pressed():
	hide()
	simulation_completed.emit(0, "Simulation cancelled")

func reset_simulation():
	option_a.disabled = false
	option_b.disabled = false
	option_c.disabled = false
	option_d.disabled = false
	hide()
