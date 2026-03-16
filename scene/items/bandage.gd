extends Area2D

var player_in_zone = null
var heal_amount = 10 # Lesser heal than a full heart item

func _process(delta):
	# If the player is standing on the bandage AND presses E
	if player_in_zone != null and Input.is_key_pressed(KEY_E):
		# Heal the player
		if player_in_zone.has_method("heal"):
			player_in_zone.heal(heal_amount)

			# Delete the bandage from the map
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone = body


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone = null
