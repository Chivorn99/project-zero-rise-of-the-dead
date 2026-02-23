extends Area2D

var player_in_zone = null
var heal_amount = 25 # How much HP it restores

func _process(delta):
	# If the player is standing on the heart AND presses E
	if player_in_zone != null and Input.is_key_pressed(KEY_E):
		
		# Heal the player
		if player_in_zone.has_method("heal"):
			player_in_zone.heal(heal_amount)
			
			# Delete the heart from the map
			queue_free() 

func _on_body_entered(body):
	if body.name == "Player":
		player_in_zone = body

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = null