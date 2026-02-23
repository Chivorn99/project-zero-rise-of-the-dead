extends Node2D

var big_zombie_scene = preload("res://scene/big_zombie.tscn")
var big_zombies_spawned = false

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    if big_zombies_spawned:
        return
    

    var zombie_count = 0
    for child in get_children():
        if child.is_in_group("zombie"):
            zombie_count += 1
    

    if zombie_count == 0:
        big_zombies_spawned = true
        spawn_big_zombies()

func spawn_big_zombies():
    print("All zombies slain! Spawning big zombies...")
    

    var spawn_points = [
        Vector2(80, 60),    
        Vector2(260, 60),   
        Vector2(170, 150),  
    ]
    
    for pos in spawn_points:
        var big_zombie = big_zombie_scene.instantiate()
        big_zombie.global_position = pos
        add_child(big_zombie)
