extends Area2D

var player_at_door = false
var player_ref = null
var inside_level_path = "res://scene/level/production/shop_interior.tscn"
var e_was_down = false

func _ready():
	e_was_down = Input.is_key_pressed(KEY_E)

func _process(_delta):
	var e_is_down = Input.is_key_pressed(KEY_E)
	if player_at_door and e_is_down and not e_was_down:
		if player_ref != null:
			Global.shop_return_pos = player_ref.global_position

		Global.player_spawn_pos = Vector2.ZERO
		print("Teleporting inside...")
		get_tree().change_scene_to_file(inside_level_path)

	e_was_down = e_is_down

func _on_body_entered(body):
	if body.name == "Player":
		player_at_door = true
		player_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		player_at_door = false
		if body == player_ref:
			player_ref = null
