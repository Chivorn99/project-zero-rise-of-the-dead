extends CharacterBody2D

const SPEED = 40.0 # Slower than Varaman (so the player can run away!)
@onready var anim = $AnimatedSprite2D

var player = null

func _ready():
	# Find the player in the world. (Make sure your player node is exactly named "Player")
	player = get_tree().current_scene.get_node_or_null("Player")

func _physics_process(delta):
	# If the player isn't found, the zombie just stands still
	if player == null:
		anim.play("idle_down")
		return 

	# 1. Calculate the direction to the player
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED
	
	# 2. Choose the right animation based on which way the zombie is moving most
	if abs(direction.x) > abs(direction.y):
		# Moving mostly left or right
		anim.play("walk_side")
		anim.flip_h = direction.x < 0 # Flip the sprite if walking left
	else:
		# Moving mostly up or down
		if direction.y < 0:
			anim.play("walk_up")
		else:
			anim.play("walk_down")
			
	# 3. Actually move the zombie
	move_and_slide()