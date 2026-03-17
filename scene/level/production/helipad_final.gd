extends Node2D

var zombie_scene = preload("res://scene/zombie/zombie.tscn")
var big_zombie_scene = preload("res://scene/zombie/big_zombie.tscn")

var boss_phase_2 = false
var phase_2_boss = null
var phase_2_defeated = false
var victory_triggered = false
var spawn_timer = null
var remaining_label = null

# Grabs your axe zombie from the scene
@onready var phase_1_boss = $ZombieAxe

func _ready():
	# HUD label to show remaining enemies during the helipad fight.
	var hud_layer = CanvasLayer.new()
	add_child(hud_layer)

	remaining_label = Label.new()
	remaining_label.add_theme_font_size_override("font_size", 20)
	remaining_label.add_theme_color_override("font_color", Color(1, 0.92, 0.5))
	remaining_label.position = Vector2(20, 20)
	remaining_label.text = "Enemies Remaining: 0"
	hud_layer.add_child(remaining_label)

	# 1. CREATE THE FLOATING POPUP TEXT IN CODE
	var warning = Label.new()
	warning.text = "KILL THE FINAL ZOMBIE!"
	warning.add_theme_font_size_override("font_size", 24)
	warning.add_theme_color_override("font_color", Color.RED)
	warning.position = Vector2(-120, -100) # Floats near the top
	add_child(warning)
	
	# Delete the text after 4 seconds
	get_tree().create_timer(4.0).timeout.connect(func(): warning.queue_free())

	# 2. PREP THE BACKUP WAVE SPAWNER (starts after boss intro ends)
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 5.0 # Spawns backup every 5 seconds!
	spawn_timer.autostart = false
	spawn_timer.timeout.connect(_on_spawn_wave)
	add_child(spawn_timer)

	if is_instance_valid(phase_1_boss):
		if phase_1_boss.has_signal("intro_finished"):
			phase_1_boss.intro_finished.connect(_on_phase_1_intro_finished)
		if phase_1_boss.has_signal("phase_one_defeated"):
			phase_1_boss.phase_one_defeated.connect(_on_phase_1_defeated)

	_update_remaining_ui()

func _on_spawn_wave():
	if phase_2_defeated:
		return

	# Spawns normal zombies in Phase 1, and Big Zombies in Phase 2!
	var minion
	if boss_phase_2:
		minion = big_zombie_scene.instantiate()
	else:
		minion = zombie_scene.instantiate()
	
	# Spawn randomly around the edges of the helipad
	minion.global_position = Vector2(randf_range(-150, 150), randf_range(-150, 150))
	minion.add_to_group("helipad_minions")
	add_child(minion)

func _on_phase_1_intro_finished():
	if spawn_timer != null and spawn_timer.is_stopped():
		spawn_timer.start()

func _on_phase_1_defeated():
	if boss_phase_2:
		return
	print("Phase 1 Boss Defeated! Spawning Phase 2...")
	boss_phase_2 = true
	
	# Spawn the Big Zombie Boss!
	phase_2_boss = big_zombie_scene.instantiate()
	phase_2_boss.global_position = Vector2(0, 0) # Center of helipad
	phase_2_boss.modulate = Color.RED # Tint him red so he looks dangerous
	phase_2_boss.scale = Vector2(1.5, 1.5) # Make him 50% larger!
	add_child(phase_2_boss)

func _update_remaining_ui():
	if remaining_label == null:
		return

	var remaining_minions = get_tree().get_nodes_in_group("helipad_minions").size()
	remaining_label.text = "Enemies Remaining: %d" % remaining_minions

func _process(_delta):
	_update_remaining_ui()

	if boss_phase_2 and not phase_2_defeated and not is_instance_valid(phase_2_boss):
		phase_2_defeated = true
		if spawn_timer != null:
			spawn_timer.stop()

	if phase_2_defeated and not victory_triggered:
		var remaining_minions = get_tree().get_nodes_in_group("helipad_minions").size()
		if remaining_minions <= 0:
			victory_triggered = true
			print("Game Beaten!")
			get_tree().change_scene_to_file("res://scene/level/ui/victory_screen.tscn")