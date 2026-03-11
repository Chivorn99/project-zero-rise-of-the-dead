extends Area2D

var player_at_door = false

# IMPORTANT: You can get the exact perfect path by going to your FileSystem,
# right-clicking your apartment_hall_way.tscn file, and clicking "Copy Path".
var hallway_path = "res://scene/level/production/apartment_hall_way.tscn" 

func _process(delta):
	# If player is on the exit mat and presses 'E'
	if player_at_door and Input.is_key_pressed(KEY_E):
		print("Exiting shop...")
		get_tree().change_scene_to_file(hallway_path)

func _on_body_entered(body):
	if body.name == "Player":
		player_at_door = true

func _on_body_exited(body):
	if body.name == "Player":
		player_at_door = false