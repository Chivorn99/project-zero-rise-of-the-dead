extends CharacterBody2D

signal intro_finished
signal phase_one_defeated

# --- Boss Stats ---
var speed = 45.0
var detection_radius = 150.0
var attack_radius = 25.0
var damage = 25
var attack_cooldown = 0.0
const ATTACK_COOLDOWN_TIME = 0.8
var health = 250
var is_dying = false

var has_revived = false
var is_reviving = false
var revive_reverse_frame = -1
var revive_frame_timer = 0.0
var revive_frame_delay = 0.0
var ground_timer = 0.0
var waiting_on_ground = false
var phase_one_defeat_emitted = false

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
	if anim.sprite_frames:
		if anim.sprite_frames.has_animation("first_death_side"):
			anim.sprite_frames.set_animation_loop("first_death_side", false)
		if anim.sprite_frames.has_animation("second_death_side"):
			anim.sprite_frames.set_animation_loop("second_death_side", false)
		for anim_name in ["first_attack_side", "first_attack_up", "first_attack_down", 
						   "second_attack_side", "second_attack_up", "second_attack_down"]:
			if anim.sprite_frames.has_animation(anim_name):
				anim.sprite_frames.set_animation_loop(anim_name, false)
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	dialogue_ui.hide() 

func _process(delta):
	if current_state == State.WAITING and player_in_talk_zone and Input.is_key_pressed(KEY_E):
		dialogue_label.text = "You made it to the helipad, Varaman... but you're too late! RAAAARRGGHH!"
		dialogue_ui.show()
		current_state = State.TALKING
		
	elif current_state == State.TALKING and Input.is_key_pressed(KEY_ENTER):
		dialogue_ui.hide()
		current_state = State.CHASE
		$TalkRadius.set_deferred("monitoring", false)
		emit_signal("intro_finished")

func _physics_process(delta):
	if waiting_on_ground:
		ground_timer -= delta
		if ground_timer <= 0:
			waiting_on_ground = false
			_start_reverse_playback()
		return

	if is_reviving and revive_reverse_frame >= 0:
		revive_frame_timer -= delta
		if revive_frame_timer <= 0:
			revive_reverse_frame -= 1
			if revive_reverse_frame < 0:
				_finish_revive()
			else:
				anim.frame = revive_reverse_frame
				revive_frame_timer = revive_frame_delay
		return

	if player == null or is_dying or is_reviving:
		return

	if attack_cooldown > 0:
		attack_cooldown -= delta

	var distance_to_player = global_position.distance_to(player.global_position)

	if is_attacking:
		return

	if current_state != State.WAITING and current_state != State.TALKING:
		if distance_to_player <= attack_radius and attack_cooldown <= 0:
			current_state = State.ATTACK
		elif distance_to_player <= detection_radius:
			current_state = State.CHASE
		else:
			current_state = State.IDLE

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
			var attack_type = "first_attack"
			if has_revived:
				attack_type = "second_attack" if randf() < 0.7 else "first_attack"
			play_directional_animation(attack_type)
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
	
	await get_tree().create_timer(0.3).timeout

	if player != null and not is_dying and not is_reviving:
		var dist = global_position.distance_to(player.global_position)
		if dist < attack_radius * 1.5 and player.has_method("take_damage"):
			player.take_damage(damage)

func take_damage(amount):
	if is_dying or is_reviving:
		return
	
	health -= amount
	print("Zombie Axe hit! Health: ", health)
	
	if health <= 0:
		die()

func die():
	is_dying = true
	is_attacking = false
	velocity = Vector2.ZERO

	if not has_revived:
		anim.play("first_death_side")
	else:
		anim.play("second_death_side")

func _start_ground_wait():
	is_reviving = true
	waiting_on_ground = true
	ground_timer = 2.0
	if not phase_one_defeat_emitted:
		phase_one_defeat_emitted = true
		emit_signal("phase_one_defeated")
	print("Zombie Axe collapsed... lying on the ground")

	var last_frame = anim.sprite_frames.get_frame_count("first_death_side") - 1
	anim.pause()
	anim.frame = last_frame

func _start_reverse_playback():
	print("Zombie Axe getting back up!")
	var frame_count = anim.sprite_frames.get_frame_count("first_death_side")
	var fps = anim.sprite_frames.get_animation_speed("first_death_side")
	if fps <= 0:
		fps = 5.0

	revive_reverse_frame = frame_count - 1
	revive_frame_delay = 1.0 / fps
	revive_frame_timer = revive_frame_delay
	anim.frame = revive_reverse_frame

func _finish_revive():
	revive_reverse_frame = -1
	has_revived = true
	is_dying = false
	is_reviving = false
	waiting_on_ground = false
	health = 125
	speed = 55.0  # Faster after revival
	attack_cooldown = 0.5
	current_state = State.CHASE
	anim.play("idle_down")
	print("Zombie Axe revived! Health: ", health)

func _on_animated_sprite_2d_animation_finished():
	if anim.animation.begins_with("first_attack") or anim.animation.begins_with("second_attack"):
		is_attacking = false
		attack_cooldown = ATTACK_COOLDOWN_TIME
	elif anim.animation == "first_death_side":
		if not is_reviving:
			_start_ground_wait()
	elif anim.animation == "second_death_side":
		queue_free()

# --- Talk Radius Signals ---
func _on_talk_radius_body_entered(body):
	if body.name == "Player":
		player_in_talk_zone = true

func _on_talk_radius_body_exited(body):
	if body.name == "Player":
		player_in_talk_zone = false