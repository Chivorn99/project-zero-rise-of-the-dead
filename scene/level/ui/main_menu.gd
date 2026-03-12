extends Control

var game_scene_path = "res://scene/level/production/apartment_room.tscn"

func _on_start_button_pressed():
	print("Starting game...")
	get_tree().change_scene_to_file(game_scene_path)

func _on_quit_button_pressed():
	print("Quitting game...")
	get_tree().quit()