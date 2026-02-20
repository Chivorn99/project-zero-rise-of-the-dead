extends CharacterBody2D

const SPEED = 40.0
const ATTACK_RANGE = 25.0

@onready var anim = $AnimatedSprite2D

var player = null
var is_attacking = false 

func _ready():
	player = get_tree().current_scene.get_node_or_null("Player")

func _physics_process(delta):
	if player == null or is_attacking:
		return 

	var distance = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)

	# CHECK FOR ATTACK
	if distance < ATTACK_RANGE:
		attack(direction)
		return 

	# CHASE
	velocity = direction * SPEED
	
	if abs(direction.x) > abs(direction.y):
		anim.play("walk_side")
		anim.flip_h = direction.x < 0 
	else:
		if direction.y < 0:
			anim.play("walk_up")
		else:
			anim.play("walk_down")
			
	move_and_slide()

func attack(direction):
	is_attacking = true
	velocity = Vector2.ZERO 
	
	# Play the right attack animation
	if abs(direction.x) > abs(direction.y):
		anim.play("first_attack_side")
		anim.flip_h = direction.x < 0
	else:
		if direction.y < 0:
			anim.play("first_attack_up")
		else:
			anim.play("first_attack_down")

func _on_animated_sprite_2d_animation_finished() -> void:
	is_attacking = false
	anim.play("idle_down") 
