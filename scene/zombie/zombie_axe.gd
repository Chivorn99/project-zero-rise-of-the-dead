extends CharacterBody2D

# --- Boss Stats ---
var speed = 45.0
var detection_radius = 150.0
var attack_radius = 25.0
var damage = 20
var attack_cooldown = 0.0
const ATTACK_COOLDOWN_TIME = 0.8
var health = 150
var is_dying = false

# Added the TALKING state!
enum State {WAITING, TALKING, IDLE, CHASE, ATTACK}
var current_state = State.WAITING
var is_attacking = false

var player_in_talk_zone = false

@onready var anim = $AnimatedSprite2D
@onready var dialogue_ui = $DialogueUI
@onready var dialogue_label = $DialogueUI/Panel/Label
var player = null

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	anim.play("idle_down")
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	dialogue_ui.hide() # Ensure the UI is hidden when the scene loads

func _process(delta):
	# 1. Trigger the conversation
	if current_state == State.WAITING and player_in_talk_zone and Input.is_key_pressed(KEY_E):
		dialogue_label.text = "You made it to the helipad, Varaman... but you're too late! RAAAARRGGHH!"
		dialogue_ui.show()
		current_state = State.TALKING
		
	# 2. Read the text, press Enter, and start the fight!
	elif current_state == State.TALKING and Input.is_key_pressed(KEY_ENTER):
		dialogue_ui.hide()
		current_state = State.CHASE
		$TalkRadius.set_deferred("monitoring", false)

func _physics_process(delta):
	if player == null or is_dying:
		return

	if attack_cooldown > 0:
		attack_cooldown -= delta

	var distance_to_player = global_position.distance_to(player.global_position)

	# Don't change state while attacking
	if is_attacking:
		return

	# Only check for chasing/attacking if he isn't waiting or talking
	if current_state != State.WAITING and current_state != State.TALKING:
		if distance_to_player <= attack_radius and attack_cooldown <= 0:
			current_state = State.ATTACK
		elif distance_to_player <= detection_radius:
			current_state = State.CHASE
		else:
			current_state = State.IDLE

	# Execute the action based on the state
	match current_state:
		State.WAITING, State.TALKING, State.IDLE:
			velocity = Vector2.ZERO
			play_directional_animation("idle")
			
		State.CHASE:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			play_directional_animation("walk")
			move_and_slide()
			
		State.ATTACK:
			velocity = Vector2.ZERO
			is_attacking = true
			play_directional_animation("first_attack")
			perform_attack()

# --- Animation Logic ---
func play_directional_animation(action: String):
	var direction = (player.global_position - global_position).normalized()
	var anim_direction = "down"
	
	if abs(direction.x) > abs(direction.y):
		anim_direction = "side"
		anim.flip_h = direction.x < 0
	else:
		if direction.y > 0:
			anim_direction = "down"
		else:
			anim_direction = "up"
			
	anim.play(action + "_" + anim_direction)

# --- Damage Logic ---
func perform_attack():
	attack_cooldown = ATTACK_COOLDOWN_TIME
	
	# Wait for damage timing
	await get_tree().create_timer(0.3).timeout
	
	# Deal damage if still valid
	if player != null:
		var dist = global_position.distance_to(player.global_position)
		if dist < attack_radius * 1.5 and player.has_method("take_damage"):
			player.take_damage(damage)
	
	# Wait for animation to finish (adjust time to match your animation length)
	await get_tree().create_timer(0.5).timeout
	
	# End attack state
	is_attacking = false
	current_state = State.CHASE

func take_damage(amount):
	if is_dying:
		return
	
	health -= amount
	print("Zombie Axe hit! Health: ", health)
	
	if health <= 0:
		die()

func die():
	is_dying = true
	is_attacking = false
	velocity = Vector2.ZERO
	anim.play("first_death_side")

func _on_animated_sprite_2d_animation_finished():
	if anim.animation.begins_with("first_death"):
		queue_free()

# --- Talk Radius Signals ---
func _on_talk_radius_body_entered(body):
	if body.name == "Player":
		player_in_talk_zone = true

func _on_talk_radius_body_exited(body):
	if body.name == "Player":
		player_in_talk_zone = false