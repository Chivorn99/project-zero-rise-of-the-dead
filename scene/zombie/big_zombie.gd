extends CharacterBody2D

const SPEED = 15.0
const ATTACK_RANGE = 22.0
const DAMAGE_RANGE = 30.0

@onready var anim = $AnimatedSprite2D

var player = null
var is_attacking = false
var is_dying = false
var health = 175
var attack_cooldown = 0.0
const ATTACK_COOLDOWN_TIME = 0.8
var use_second_attack = false

# Revival system
var has_revived = false
var is_reviving = false
var revive_reverse_frame = -1
var revive_frame_timer = 0.0
var revive_frame_delay = 0.0
var ground_timer = 0.0
var waiting_on_ground = false

# Damage timing
var damage_timer = 0.0
var damage_pending = false

func _ready():
    player = get_tree().current_scene.get_node_or_null("Player")
    if anim.sprite_frames:
        if anim.sprite_frames.has_animation("first_death_side"):
            anim.sprite_frames.set_animation_loop("first_death_side", false)
        if anim.sprite_frames.has_animation("second_death_side"):
            anim.sprite_frames.set_animation_loop("second_death_side", false)
    if not anim.animation_finished.is_connected(_on_animated_sprite_2d_animation_finished):
        anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func _physics_process(delta):
    if waiting_on_ground:
        ground_timer -= delta
        if ground_timer <= 0:
            waiting_on_ground = false
            _start_reverse_playback()
        return

    # REVIVAL
    if is_reviving and revive_reverse_frame >= 0:
        revive_frame_timer -= delta
        if revive_frame_timer <= 0:
            revive_reverse_frame -= 1
            if revive_reverse_frame < 0:
                _finish_revive()
            else:
                anim.frame = revive_reverse_frame
                revive_frame_timer = revive_frame_delay
        return

    if is_dying or is_reviving:
        return

    if damage_pending:
        damage_timer -= delta
        if damage_timer <= 0:
            damage_pending = false
            deal_damage()

    if attack_cooldown > 0:
        attack_cooldown -= delta

    if player == null or player.is_dead:
        is_attacking = false
        velocity = Vector2.ZERO
        anim.play("idle_down")
        return

    if is_attacking:
        return

    var distance = global_position.distance_to(player.global_position)
    var direction = global_position.direction_to(player.global_position)

    if distance < ATTACK_RANGE and attack_cooldown <= 0:
        attack(direction)
        return

    # CHASE
    velocity = direction * SPEED

    if abs(direction.x) > abs(direction.y):
        anim.play("walk_side")
        anim.flip_h = direction.x < 0
    else:
        if direction.y < 0:
            anim.play("walk_up")
        else:
            anim.play("walk_down")

    move_and_slide()

func attack(direction):
    is_attacking = true
    velocity = Vector2.ZERO

    var prefix
    if has_revived:
        prefix = "second_attack" if randi() % 2 == 0 else "first_attack"
    else:
        prefix = "second_attack" if use_second_attack else "first_attack"
        use_second_attack = !use_second_attack

    if abs(direction.x) > abs(direction.y):
        anim.play(prefix + "_side")
        anim.flip_h = direction.x < 0
    else:
        if direction.y < 0:
            anim.play(prefix + "_up")
        else:
            anim.play(prefix + "_down")

    damage_pending = true
    damage_timer = 0.4

func deal_damage():
    if is_dying or is_reviving or player == null or player.is_dead:
        return
    var dist = global_position.distance_to(player.global_position)
    if dist < DAMAGE_RANGE and player.has_method("take_damage"):
        player.take_damage(15)

func _on_animated_sprite_2d_animation_finished() -> void:
    if anim.animation.begins_with("first_attack") or anim.animation.begins_with("second_attack"):
        is_attacking = false
        attack_cooldown = ATTACK_COOLDOWN_TIME
    elif anim.animation == "first_death_side":
        if not is_reviving:
            _start_ground_wait()
    elif anim.animation == "second_death_side":
        queue_free()

func take_damage(amount):
    if is_dying or is_reviving:
        return

    health -= amount
    print("Big Zombie hit! Health: ", health)

    if health <= 0:
        die()

func die():
    is_dying = true
    is_attacking = false
    damage_pending = false
    velocity = Vector2.ZERO

    if not has_revived:
        anim.play("first_death_side")
    else:
        anim.play("second_death_side")

func _start_ground_wait():
    is_reviving = true
    waiting_on_ground = true
    ground_timer = 2.0
    print("Big Zombie collapsed... lying on the ground")

    var last_frame = anim.sprite_frames.get_frame_count("first_death_side") - 1
    anim.pause()
    anim.frame = last_frame

func _start_reverse_playback():
    print("Big Zombie getting back up!")
    var frame_count = anim.sprite_frames.get_frame_count("first_death_side")
    var fps = anim.sprite_frames.get_animation_speed("first_death_side")
    if fps <= 0:
        fps = 5.0

    revive_reverse_frame = frame_count - 1 
    revive_frame_delay = 1.0 / fps 
    revive_frame_timer = revive_frame_delay
    anim.frame = revive_reverse_frame

func _finish_revive():
    revive_reverse_frame = -1
    has_revived = true
    is_dying = false
    is_reviving = false
    waiting_on_ground = false
    health = 100
    attack_cooldown = 0.5
    anim.play("idle_down")
    print("Big Zombie revived! Health: ", health)
