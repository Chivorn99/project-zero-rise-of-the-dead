extends Area2D

var req_normal = 15
var req_big = 5
var inside_level_path = "res://scene/level/production/helipad_final.tscn"

func _on_body_entered(body):
	if body.name == "Player":
		if Global.normal_kills >= req_normal and Global.big_kills >= req_big:
			print("Access Granted! Entering Helipad...")
			get_tree().change_scene_to_file(inside_level_path)
		else:
			print("The door is locked tightly. I need to thin out the horde outside first!")
			print("Progress: ", Global.normal_kills, "/", req_normal, " Normal | ", Global.big_kills, "/", req_big, " Big")
