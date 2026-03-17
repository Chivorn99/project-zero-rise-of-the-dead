extends Area2D

var player_at_door = false
var e_was_down = false

# IMPORTANT: You can get the exact perfect path by going to your FileSystem,
# right-clicking your outside_world.tscn file, and clicking "Copy Path".
var outside_level_path = "res://scene/level/production/outside_world.tscn" 

func _ready():
	e_was_down = Input.is_key_pressed(KEY_E)

func _process(_delta):
	var e_is_down = Input.is_key_pressed(KEY_E)
	# If player is on the exit mat and presses 'E'
	if player_at_door and e_is_down and not e_was_down:
		print("Exiting shop...")

		# Return to the exact outside position recorded when entering the shop.
		if Global.shop_return_pos != Vector2.ZERO:
			Global.player_spawn_pos = Global.shop_return_pos
		else:
			# Fallback in case no position was saved.
			Global.player_spawn_pos = Vector2(135, 175)
		
		get_tree().change_scene_to_file(outside_level_path)

	e_was_down = e_is_down

func _on_body_entered(body):
	if body.name == "Player":
		player_at_door = true

func _on_body_exited(body):
	if body.name == "Player":
		player_at_door = false