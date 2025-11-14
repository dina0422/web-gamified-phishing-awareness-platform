extends CharacterBody2D

@export var move_speed: float = 100.0

var can_move: bool = true
var input_direction: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("player")

func _physics_process(_delta):
	if can_move:
		_handle_movement()
	else:
		# Stop movement when in dialogue
		velocity = Vector2.ZERO
		move_and_slide()

func _handle_movement():
	# Get input direction
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Apply movement
	if input_direction != Vector2.ZERO:
		velocity = input_direction * move_speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func set_can_move(value: bool):
	can_move = value
	if not can_move:
		velocity = Vector2.ZERO

# Animation handling (if you have AnimatedSprite2D)
func _update_animation():
	if not can_move:
		return
	
	if has_node("AnimatedSprite2D"):
		var anim = $AnimatedSprite2D
		
		if input_direction != Vector2.ZERO:
			# Walking animations
			if abs(input_direction.x) > abs(input_direction.y):
				if input_direction.x > 0:
					anim.play("walk_right")
				else:
					anim.play("walk_left")
			else:
				if input_direction.y > 0:
					anim.play("walk_down")
				else:
					anim.play("walk_up")
		else:
			# Idle animations
			anim.play("idle")
