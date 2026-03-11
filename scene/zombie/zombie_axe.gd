extends CharacterBody2D

# --- Boss Stats ---
var speed = 45.0
var detection_radius = 150.0
var attack_radius = 25.0

# Added the TALKING state!
enum State {WAITING, TALKING, IDLE, CHASE, ATTACK}
var current_state = State.WAITING

var player_in_talk_zone = false

@onready var anim = $AnimatedSprite2D
@onready var dialogue_ui = $DialogueUI
@onready var dialogue_label = $DialogueUI/Panel/Label
var player = null

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	anim.play("idle_down")
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
	if player == null:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	# Only check for chasing/attacking if he isn't waiting or talking
	if current_state != State.WAITING and current_state != State.TALKING:
		if distance_to_player <= attack_radius:
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
			play_directional_animation("first_attack")

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

# --- Talk Radius Signals ---
func _on_talk_radius_body_entered(body):
	if body.name == "Player":
		player_in_talk_zone = true

func _on_talk_radius_body_exited(body):
	if body.name == "Player":
		player_in_talk_zone = false