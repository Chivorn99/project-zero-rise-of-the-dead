extends CharacterBody2D

const SPEED = 120.0
@onready var anim = $AnimatedSprite2D 

var last_direction = Vector2.DOWN

func _physics_process(delta):
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