extends CharacterBody2D

const SPEED = 120.0

# SURVIVAL STATS
var max_hp = 100
var current_hp = 100

var max_hunger = 100
var current_hunger = 100
var is_dead = false
var spawn_position = Vector2.ZERO
var is_attacking = false
var is_picking_up = false
var attack_cooldown = 0.0
const ATTACK_COOLDOWN_TIME = 0.4

@onready var anim = $AnimatedSprite2D 
@onready var health_bar = $UI/HealthBar
@onready var hunger_bar = $UI/HungerBar
@onready var hitbox = $Hitbox
@onready var hitbox_shape = $Hitbox/CollisionShape2D

var last_direction = Vector2.DOWN

func _ready():
	spawn_position = global_position

	if anim.sprite_frames:
		if anim.sprite_frames.has_animation("attack_up"):
			anim.sprite_frames.set_animation_loop("attack_up", false)
		if anim.sprite_frames.has_animation("attack_down"):
			anim.sprite_frames.set_animation_loop("attack_down", false)
		if anim.sprite_frames.has_animation("attack_side"):
			anim.sprite_frames.set_animation_loop("attack_side", false)
		if anim.sprite_frames.has_animation("pickup_up"):
			anim.sprite_frames.set_animation_loop("pickup_up", false)
		if anim.sprite_frames.has_animation("pickup_down"):
			anim.sprite_frames.set_animation_loop("pickup_down", false)
		if anim.sprite_frames.has_animation("pickup_side"):
			anim.sprite_frames.set_animation_loop("pickup_side", false)

	health_bar.max_value = max_hp
	health_bar.value = current_hp
	
	hunger_bar.max_value = max_hunger
	hunger_bar.value = current_hunger

func _physics_process(delta):
	if is_dead:
		return

	if is_picking_up:
		return

	if attack_cooldown > 0:
		attack_cooldown -= delta

	if is_attacking:
		if not Input.is_action_pressed("attack"):
			is_attacking = false
			hitbox_shape.disabled = true
			if last_direction.y < 0:
				anim.play("idle_up")
			elif last_direction.y > 0:
				anim.play("idle_down")
			else:
				anim.play("idle_side")
		return

	var direction = Vector2.ZERO

	if Input.is_action_pressed("attack") and attack_cooldown <= 0:
		attack()
		return

	if Input.is_action_just_pressed("pickup"):
		pickup()
		return
	
	# INPUT — FIXED: added missing closing parentheses
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1

	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * SPEED
		last_direction = direction
		
		# RUN ANIMATIONS
		if direction.y < 0:
			anim.play("run_up")
		elif direction.y > 0:
			anim.play("run_down")
		else:
			anim.play("run_side")
			
		if direction.x < 0:
			anim.flip_h = true 
		elif direction.x > 0:
			anim.flip_h = false 
			
	else:
		velocity = Vector2.ZERO
		if last_direction.y < 0:
			anim.play("idle_up")
		elif last_direction.y > 0:
			anim.play("idle_down")
		else:
			anim.play("idle_side")

	move_and_slide()

func take_damage(amount):
	if is_dead:
		return

	current_hp -= amount
	health_bar.value = current_hp
	
	print("Player took damage! HP is now: ", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	is_dead = true
	is_attacking = false
	is_picking_up = false
	hitbox_shape.disabled = true
	velocity = Vector2.ZERO
	
	if last_direction.y < 0:
		anim.play("death_one_side") 
	elif last_direction.y > 0:
		anim.play("death_one_side")
	else:
		anim.play("death_one_side")
	
	await get_tree().create_timer(3).timeout
	respawn()

func respawn():
	global_position = spawn_position
	velocity = Vector2.ZERO

	current_hp = max_hp
	current_hunger = max_hunger
	health_bar.value = current_hp
	hunger_bar.value = current_hunger

	is_dead = false
	is_attacking = false
	is_picking_up = false
	attack_cooldown = 0.0
	hitbox_shape.disabled = true
	last_direction = Vector2.DOWN
	anim.flip_h = false
	anim.play("idle_down")

func attack():
	is_attacking = true
	velocity = Vector2.ZERO 

	hitbox_shape.disabled = false
	
	if last_direction.y < 0:
		anim.play("attack_up")
		hitbox.position = Vector2(0, -15) 
	elif last_direction.y > 0:
		anim.play("attack_down")
		hitbox.position = Vector2(0, 15) 
	else:
		anim.play("attack_side")
		if anim.flip_h:
			hitbox.position = Vector2(-15, 0) 
		else:
			hitbox.position = Vector2(15, 0)

func pickup():
	is_picking_up = true
	velocity = Vector2.ZERO
	
	if last_direction.y < 0:
		anim.play("pickup_up")
	elif last_direction.y > 0:
		anim.play("pickup_down")
	else:
		anim.play("pickup_side")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation.begins_with("attack"):
		is_attacking = false
		attack_cooldown = ATTACK_COOLDOWN_TIME 
		hitbox_shape.disabled = true
	elif anim.animation.begins_with("pickup"):
		is_picking_up = false

func _on_hitbox_body_entered(body):
	if body.has_method("take_damage") and body != self:
		body.take_damage(25)
