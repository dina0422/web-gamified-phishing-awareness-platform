extends Control

const ROLE_SELECTION_SCENE := "res://gameplay/main/role_selection.gd"
const MAIN_MENU_SCENE := "res://main_menu.tscn"

func _ready() -> void:
	$HBoxContainer/enter.pressed.connect(on_button_pressed)
	# (If you have back/next buttons wired via the editor, you're good.)

func on_button_pressed() -> void:
	print("Enter pressed")

	# Get text from LineEdit node named 'name'
	var player_name = $HBoxContainer/name.text.strip_edges()

	# Fallback if empty
	if player_name == "":
		player_name = "Anonymous"

	# Ensure we're signed in (should already be, but safe)
	var ok = await Firebase.sign_in_anonymous()
	if not ok:
		push_error("Sign-in failed. Check API key / internet.")
		return

	# Save display name (local + Firestore)
	Firebase.display_name = player_name
	await Firebase.save_display_name(player_name)  # ok even if offline; local is cached

	# Go to role selection
	var err := get_tree().change_scene_to_file(ROLE_SELECTION_SCENE)
	if err != OK:
		push_error("Failed to change scene (%s): %s" % [ROLE_SELECTION_SCENE, err])

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file(ROLE_SELECTION_SCENE)
