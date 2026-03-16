extends CharacterBody2D

const SPEED = 20.0
const ATTACK_RANGE = 17.5 
const DETECTION_RANGE = 140.0

@onready var anim = $AnimatedSprite2D

var player = null
var is_attacking = false 
var is_dying = false
var health = 50 
var attack_cooldown = 0.0
const ATTACK_COOLDOWN_TIME = 0.6 
const DAMAGE_RANGE = 25.0

func _ready():
	player = get_tree().current_scene.get_node_or_null("Player")
	if anim.sprite_frames and anim.sprite_frames.has_animation("death_side"):
		anim.sprite_frames.set_animation_loop("death_side", false)

func _physics_process(delta):
	if is_dying:
		return

	if attack_cooldown > 0:
		attack_cooldown -= delta

	if player == null or player.is_dead:
		is_attacking = false
		velocity = Vector2.ZERO
		anim.play("idle_down") 
		return 
		
	if is_attacking:
		return 

	var distance = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)

	# Only detect/chase player inside this radius.
	if distance > DETECTION_RANGE:
		velocity = Vector2.ZERO
		if abs(direction.x) > abs(direction.y):
			anim.play("idle_side")
			anim.flip_h = direction.x < 0
		else:
			if direction.y < 0:
				anim.play("idle_up")
			else:
				anim.play("idle_down")
		return

	if distance < ATTACK_RANGE and attack_cooldown <= 0:
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

	await get_tree().create_timer(0.3).timeout

	if is_dying or player == null or player.is_dead:
		return
	var dist = global_position.distance_to(player.global_position)
	if dist < DAMAGE_RANGE and player.has_method("take_damage"):
		player.take_damage(8)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation.begins_with("first_attack"):
		is_attacking = false
		attack_cooldown = ATTACK_COOLDOWN_TIME 
	elif anim.animation == "death_side":
		queue_free()

func take_damage(amount):
	if is_dying:
		return

	health -= amount
	print("Zombie hit! Health: ", health)
	
	if health <= 0:
		die()

func die():
	is_dying = true
	is_attacking = false
	velocity = Vector2.ZERO
	anim.play("death_side")