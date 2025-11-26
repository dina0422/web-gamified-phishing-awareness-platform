extends Area2D

# Chair interaction that launches Desktop OS
# When player sits at the chair, they access the computer

const DESKTOP_OS_SCENE = preload("res://gameplay/desktop/desktop_os.tscn")

func interact():
	print("🪑 Chair: Player sitting down at computer...")
	
	# Hide the player and 3D world
	var atok = get_tree().get_first_node_in_group("player")
	if atok:
		atok.visible = false
		# Disable player movement
		atok.set_physics_process(false)
		atok.set_process_input(false)
	
	# Launch desktop OS
	_launch_desktop_os()

func _launch_desktop_os():
	print("💻 Chair: Launching Desktop OS...")
	
	# Get the current scene root
	var scene_root = get_tree().current_scene
	
	# Create desktop OS instance
	var desktop_os = DESKTOP_OS_SCENE.instantiate()
	desktop_os.name = "DesktopOS"
	
	# Connect to desktop OS signals
	if desktop_os.has_signal("phishing_scenario_triggered"):
		desktop_os.phishing_scenario_triggered.connect(_on_phishing_scenario_completed)
	
	# Add as overlay (high z-index to render on top)
	desktop_os.z_index = 100
	scene_root.add_child(desktop_os)
	
	# Auto-launch email app after a short delay
	await get_tree().create_timer(1.0).timeout
	desktop_os.launch_email_app()
	
	print("✅ Chair: Desktop OS launched successfully")

func _on_phishing_scenario_completed(scenario_type: String):
	print("🎯 Chair: Phishing scenario completed -", scenario_type)
	# Here you can track progress, update scores, etc.
	
	# Get user stats HUD and update
	var user_stats = get_tree().get_first_node_in_group("user_stats")
	if user_stats:
		# This would integrate with your existing scoring system
		pass
