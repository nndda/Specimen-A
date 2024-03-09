extends CharacterBody2D

@export var show_debug := false

var health              : float = 100.0
var health_max          : float = 100.0
var health_tick         : float = 1.75
var health_regen        : float = 1.0

var speed               : float = 360.0

var moving              := false
var moving_f            : float

var face_obstacle       := false

var allow_attack        := true
var allow_move          := true

var attacking           := false
var attack_strength     : float
var attack_out          : float
var attack_dir          : Vector2
var attack_cooldown     : float = 2.0

var attack_speed        : float = 22.0

var attack_distance_max : float = 32.0 * 12.0
var attack_pos : PackedVector2Array = [Vector2.ZERO, Vector2.ZERO]

var mouse_global_pos : Vector2
var mouse_viewport_pos : Vector2
var mouse_moving_distancce : float
var canvas_position : Vector2

@onready var attack_cooldown_timer : Timer = $AttackCooldown

@onready var body : Line2D = $"../Body"

@onready var jaw_a : Sprite2D = $Mouth/Jaw_0
@onready var jaw_b : Sprite2D = $Mouth/Jaw_1

@onready var health_ticker : Timer = $"../UI/HealthBar/HealthTicker"

# Player UIs
@onready var ui : CanvasLayer = $"../UI"
@onready var ui_attack_indicator : TextureProgressBar = $"../UI/AttackIndicator"
@onready var ui_attack_cooldown : TextureProgressBar = $"../UI/AttackCooldown"
@onready var ui_arrow : Sprite2D = $"../UI/Arrow"

@onready var ui_obstacle : Sprite2D = $"../UI/FaceObstacleIcon"
@onready var ui_obstacle_pos : Node2D = $"FaceObstacle-Pos"
@onready var ui_obstacle_anim : AnimationPlayer = $"../UI/FaceObstacleIcon/AnimationPlayer"

# Physics
@onready var raycast_obstacle : RayCast2D = $FaceObstacle
@onready var raycast_destroy_through : RayCast2D = $"DestroyThrough-R"

@onready var area_destroy_through : Area2D = $"DestroyThrough-A"
@onready var player_general_area : Area2D = $PlayerGeneralArea

func open_mouth(n : float) -> void:
    jaw_a.rotation_degrees = n * -30.0
    jaw_a.rotation_degrees = clampf(
        jaw_a.rotation_degrees, -30.0, 0.0)

    jaw_b.rotation_degrees = n * 30.0
    jaw_b.rotation_degrees = clampf(
        jaw_b.rotation_degrees + n * 30.0, 0.0, 30.0)

func attack_handler() -> void:

    ui_attack_indicator.visible = Input.is_action_pressed(&"Attack") and allow_attack
    #ui_attack_indicator.visible = Input.is_action_pressed(&"Attack")

    if allow_attack:
        attack_out  += 4 if Input.is_action_pressed(&"Attack") else -4
        attack_out  = clampf(attack_out, 0.0, 100.0)
        open_mouth(attack_out * 0.01)
        if Input.is_action_pressed(&"Attack"):
            ui_arrow.look_at(mouse_viewport_pos)
            ui_arrow.position     = canvas_position
            ui_arrow.modulate.a   = attack_out * 0.01
            ui_arrow.offset.x     = attack_out * 0.6 + 68
            raycast_obstacle.\
            look_at(mouse_global_pos)
            look_at(mouse_global_pos)

        if Input.is_action_just_released(&"Attack"):
            player_general_area.monitorable = true
            player_general_area.monitoring = true
            attacking = true
            attack_dir = global_position.direction_to(mouse_global_pos)
            attack_strength = attack_out

            attack_cooldown_timer.start(attack_cooldown * attack_out * 0.01)
            attack_pos[0]           = global_position
            allow_attack            = false

    ui_attack_indicator.value      = attack_out
    ui_attack_cooldown.max_value   = 100
    ui_attack_cooldown.value       = (
        (attack_cooldown_timer.time_left / attack_cooldown_timer.wait_time) * 100)

func _enter_tree() -> void:
    Global.player = self

func _ready() -> void:
    if show_debug:
        monitor_var()
        $"../DBG/VBoxContainer".set_vars()
    else:
        #$"../DBG".queue_free()
        $"../DBG".visible = false

# TODO: reduce... things in _process
func _process(_delta : float) -> void:
    mouse_global_pos = get_global_mouse_position()
    mouse_viewport_pos = get_viewport().get_mouse_position()
    mouse_moving_distancce = global_position.distance_to(mouse_global_pos)

    canvas_position = get_global_transform_with_canvas().origin

    moving = Input.is_action_pressed(&"Move")\
        and mouse_moving_distancce >= 45\
        and allow_move
    moving_f = clampf(
        moving_f + (0.1 if moving else -0.085),
        0.0, 1.0
    )

    Global.head_pos               = global_position
    Global.head_canvas_pos        = canvas_position

    ui_arrow.look_at(mouse_viewport_pos)
    ui_arrow.position     = canvas_position
    ui_arrow.modulate.a   = moving_f
    ui_arrow.offset.x     = moving_f * 60 + 68

    ui_attack_indicator.position    = canvas_position - ui_attack_indicator.size * 0.5
    ui_attack_cooldown.position     = canvas_position - ui_attack_cooldown.size * 0.5

    raycast_obstacle.look_at(mouse_global_pos)
    ui_obstacle.visible = !allow_move

    if raycast_obstacle.is_colliding():
        if Input.is_action_just_pressed(&"Move"):
            ui_obstacle_pos.global_position = raycast_obstacle.get_collision_point()
            ui_obstacle.position = ui_obstacle_pos.get_global_transform_with_canvas().origin
            ui_obstacle_anim.play(&"Blink")

    attack_handler()

    if show_debug:
        monitor_var()

var velo : Vector2
var attack_velo : Vector2
var collision : KinematicCollision2D
func _physics_process(delta : float) -> void:
    area_destroy_through.monitoring = attacking
    allow_move = !raycast_obstacle.is_colliding()

    if !attacking:

        velo = (
            moving_f * speed
            * global_position.direction_to(mouse_global_pos)
            )
        velocity = velo
        move_and_slide()

    else:
        attack_distance_max = 6.4 * attack_strength
        velo = attack_speed * attack_dir
        collision = move_and_collide(velo)

        attack_pos[1] = global_position

        if collision != null:
            velo = velo.bounce(collision.get_normal())
            shake_cam()
            reset_atk_dmg()
            attacking = false

        if attack_pos[0].distance_to(attack_pos[1]) >= attack_distance_max:
            velo -= Vector2.ONE * 2.0 * delta
            reset_atk_dmg()
            attacking = false

        velo = clamp(velo, Vector2.ZERO, attack_speed * attack_dir)

    if moving_f > 0.0 and !attacking:
        look_at(mouse_global_pos)

    ui_attack_cooldown.visible = attack_cooldown_timer.time_left > 0
    Global.attacking = attacking
    Global.moving = moving
    Global.moving_or_attacking = attacking or moving or moving_f > 0

    if Global.moving_or_attacking:
        body.update_collision_shape()
        body.update_light_path()

func shake_cam() -> void:
    Camera.shake_start(
        attack_strength * 0.25 + 15,
        0.95,
        attack_strength * 0.08 + 16
    )
    Global.camera_shaken_by_player.emit()

func reset_atk_dmg() -> void:
    open_mouth(0.0)
    attack_strength = 0.0
    attack_out = 0.0

func _on_AttackCooldown_timeout() -> void:
    allow_attack = true

signal damaged(current_health : float)
var invincible := false
func damage_player(power : float) -> void:
    if !invincible:
        if health_ticker.is_stopped():
            health_ticker.start(health_tick)

        health =\
            clampf( health - ( (power * 0.9) if !attacking else 0.05),
            0.0, health_max )

        damaged.emit(health)

func monitor_var() -> void:
    $"../DBG/VBoxContainer".data = [
        "fps",              Engine.get_frames_per_second(),
        "body length",      round(Global.worm_length),
        #"head pos",         Global.head_pos.round(),
        "allow_move",       allow_move,
        "allow_attack",     allow_attack,
        "moving",           Global.moving,
        "attacking",        Global.attacking,
        "moving_f",         Global.moving_f,
        "moving_atking",    Global.moving_or_attacking,
        "health",           round(health),
       ]
    $"../DBG/VBoxContainer".mon_vars()


func _on_DestroyThroughA_body_entered(body_node : Node2D) -> void:
    if body_node.has_method(&"damage"):
        body_node.damage(
            body_node.health if body_node.health - attack_strength <= 0 else\
            attack_strength
        )
        shake_cam()

func _on_head_tree_entered() -> void:
    Global.player_physics_head = $"."
func _on_body_tree_entered() -> void:
    Global.player_physics_body = $"../DamageCollision"
func _on_destroy_through_tree_entered() -> void:
    Global.player_destroy_through = area_destroy_through

func _on_head_tree_exiting() -> void:
    Global.player_physics_head = null
func _on_body_tree_exiting():
    Global.player_physics_body = null
func _on_destroy_through_tree_exiting():
    Global.player_destroy_through = null
