extends Area2D

var req_normal = 15
var req_big = 5
var inside_level_path = "res://scene/level/production/helipad_final.tscn"

var player_at_door = false

@onready var prompt = $Label

func _ready():
	prompt.hide()

func _process(_delta):
	if player_at_door:
		if Global.normal_kills >= req_normal and Global.big_kills >= req_big:
			prompt.text = "Press [E] to Enter Helipad"
			
			if Input.is_key_pressed(KEY_E):
				print("Access Granted! Entering Helipad...")
				get_tree().change_scene_to_file(inside_level_path)
				
		else:
			prompt.text = "LOCKED: Thin the horde!\nNormal: " + str(Global.normal_kills) + "/" + str(req_normal) + "\nBig: " + str(Global.big_kills) + "/" + str(req_big)

func _on_body_entered(body):
	if body.name == "Player":
		player_at_door = true
		prompt.show()

func _on_body_exited(body):
	if body.name == "Player":
		player_at_door = false
		prompt.hide()