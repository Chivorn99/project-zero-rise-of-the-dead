extends Control

var menu_scene_path = "res://scene/level/ui/main_menu.tscn"

@onready var panel = $Center/Panel
@onready var hint = $Center/Panel/Content/Hint

var fade_duration = 1.2
var fade_elapsed = 0.0
var fading_in = true

var blink_speed = 1.8
var blink_elapsed = 0.0
var can_input = false

func _ready():
	panel.modulate.a = 0.0
	grab_focus()

func _process(delta):
	# Panel fade-in
	if fading_in:
		fade_elapsed += delta
		var t = clamp(fade_elapsed / fade_duration, 0.0, 1.0)
		panel.modulate.a = t
		if t >= 1.0:
			fading_in = false
			can_input = true
		return

	# Hint blink after fade completes
	if can_input:
		blink_elapsed += delta
		var alpha = abs(sin(blink_elapsed * blink_speed))
		hint.modulate.a = alpha

func _unhandled_input(event):
	if not can_input:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_tree().change_scene_to_file(menu_scene_path)
