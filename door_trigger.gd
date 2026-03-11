extends Area2D

var player_at_door = false
var inside_level_path = "res://scene/level/production/shop_interior.tscn"

func _process(delta):
	if player_at_door and Input.is_key_pressed(KEY_E):
		print("Teleporting inside...")
		get_tree().change_scene_to_file(inside_level_path)

func _on_body_entered(body):
	print("Something touched the door: ", body.name) 
	if body.name == "Player":
		player_at_door = true

func _on_body_exited(body):
	print("Something left the door: ", body.name) 
	if body.name == "Player":
		player_at_door = false
