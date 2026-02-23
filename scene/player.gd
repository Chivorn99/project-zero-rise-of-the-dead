extends CharacterBody2D

const SPEED = 120.0

# SURVIVAL STATS
var max_hp = 100
var current_hp = 100

var max_hunger = 100
var current_hunger = 100
var is_dead = false
var spawn_position = Vector2.ZERO

@onready var anim = $AnimatedSprite2D 
@onready var health_bar = $UI/HealthBar
@onready var hunger_bar = $UI/HungerBar

var last_direction = Vector2.DOWN

# 1. INITIALIZE THE BARS WHEN THE GAME STARTS
func _ready():
	spawn_position = global_position

	health_bar.max_value = max_hp
	health_bar.value = current_hp
	
	hunger_bar.max_value = max_hunger
	hunger_bar.value = current_hunger

func _physics_process(delta):
	if is_dead:
		return

	var direction = Vector2.ZERO
	
	# INPUT
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

# 2. THE FUNCTION THE ZOMBIE WILL TRIGGER
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
	velocity = Vector2.ZERO # Stop sliding
	
	# Play the correct death animation based on where we were looking
	if last_direction.y < 0:
		anim.play("death_one_side") 
	elif last_direction.y > 0:
		anim.play("death_one_side")
	else:
		anim.play("death_one_side")
		
	# MAGIC PAUSE: Wait for 3 seconds before respawning
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
	last_direction = Vector2.DOWN
	anim.flip_h = false
	anim.play("idle_down")
