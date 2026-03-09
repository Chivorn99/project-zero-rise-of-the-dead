extends Area2D

var player_at_door = false
var inside_level_path = "res://scene/level/production/inside_apartment.tscn"

func _process(delta):
	if player_at_door and Input.is_key_pressed(KEY_E):
		print("Teleporting inside...")
		get_tree().change_scene_to_file(inside_level_path)

func _on_body_entered(body):
	if body.name == "Player":
		player_at_door = true

func _on_body_exited(body):
	if body.name == "Player":
		player_at_door = false
