extends CharacterBody2D

# --- Boss Stats ---
var speed = 45.0
var detection_radius = 150.0 # How close Player needs to be to trigger chase
var attack_radius = 25.0     # How close to start swinging the axe

# --- State Machine ---
enum State { IDLE, CHASE, ATTACK }
var current_state = State.IDLE

# --- References ---
@onready var anim = $AnimatedSprite2D
var player = null

func _ready():
	# Finds Varaman automatically when the scene loads
	# (Make sure your player node is perfectly named "Player"!)
	player = get_tree().get_root().find_child("Player", true, false)
	anim.play("idle_down")

func _physics_process(delta):
	# If the player doesn't exist yet, just stand still
	if player == null:
		return

	# Calculate how far away Varaman is
	var distance_to_player = global_position.distance_to(player.global_position)

	# 1. Decide what the boss should be doing
	if distance_to_player <= attack_radius:
		current_state = State.ATTACK
	elif distance_to_player <= detection_radius:
		current_state = State.CHASE
	else:
		current_state = State.IDLE

	# 2. Execute the action based on the state
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			play_directional_animation("idle")
			
		State.CHASE:
			# Get the exact angle towards the player and walk there
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			play_directional_animation("walk")
			move_and_slide()
			
		State.ATTACK:
			velocity = Vector2.ZERO
			play_directional_animation("first_attack")

# --- The Animation Magic ---
# This function calculates where the player is and picks the right animation
func play_directional_animation(action: String):
	var direction = (player.global_position - global_position).normalized()
	var anim_direction = "down" # Default
	
	# If he is moving more horizontally than vertically
	if abs(direction.x) > abs(direction.y):
		anim_direction = "side"
		# Flip the sprite depending on left/right direction!
		anim.flip_h = direction.x < 0 
	else:
		# If moving more vertically
		if direction.y > 0:
			anim_direction = "down"
		else:
			anim_direction = "up"
			
	# Combine the action (e.g., "walk") with the direction (e.g., "side")
	anim.play(action + "_" + anim_direction)