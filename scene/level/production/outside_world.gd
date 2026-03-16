extends Node2D

var zombie_scene = preload("res://scene/zombie/zombie.tscn")
var big_zombie_scene = preload("res://scene/zombie/big_zombie.tscn")

# Balance Settings
var max_zombies = 8         # Maximum zombies allowed on the map at one time
var spawn_interval = 4.0    # Spawns 1 new zombie every 4 seconds
var max_big_zombies = 2  
var big_spawn_interval = 14.0
var max_total_zombies = 10  # Cap Spawning
var big_spawn_unlock_time = 60.0 
var big_spawn_chance = 0.35    

var elapsed_time = 0.0

func _ready():
	randomize()

	var spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	var big_spawn_timer = Timer.new()
	big_spawn_timer.wait_time = big_spawn_interval
	big_spawn_timer.autostart = true
	big_spawn_timer.timeout.connect(_on_big_spawn_timer_timeout)
	add_child(big_spawn_timer)

func _process(delta):
	elapsed_time += delta

func _on_spawn_timer_timeout():
	var total_zombies = get_tree().get_nodes_in_group("zombies").size()
	var current_zombies = get_tree().get_nodes_in_group("regular_zombies").size()

	if total_zombies < max_total_zombies and current_zombies < max_zombies:
		spawn_zombie()

func _on_big_spawn_timer_timeout():
	if elapsed_time < big_spawn_unlock_time:
		return

	if randf() > big_spawn_chance:
		return

	var total_zombies = get_tree().get_nodes_in_group("zombies").size()
	var current_big_zombies = get_tree().get_nodes_in_group("big_zombies").size()

	if total_zombies < max_total_zombies and current_big_zombies < max_big_zombies:
		spawn_big_zombie()

func spawn_zombie():
	var zombie = zombie_scene.instantiate()

	var random_x = randf_range(-220, 220)
	var random_y = randf_range(-220, 220)

	zombie.global_position = Vector2(random_x, random_y)

	zombie.add_to_group("regular_zombies")
	zombie.add_to_group("zombies")

	add_child(zombie)

func spawn_big_zombie():
	var big_zombie = big_zombie_scene.instantiate()

	var random_x = randf_range(-220, 220)
	var random_y = randf_range(-220, 220)

	big_zombie.global_position = Vector2(random_x, random_y)

	big_zombie.add_to_group("big_zombies")
	big_zombie.add_to_group("zombies")

	add_child(big_zombie)