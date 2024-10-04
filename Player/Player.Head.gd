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

var allow_control       := true
var allow_attack        := true
var allow_move          := true

var attacking           := false
var attack_strength     : float
var attack_out          : float
var attack_dir          : Vector2
var attack_cooldown     : float = 2.0

var attack_speed        : float = 22.0

var attack_distance_max : float = 32.0 * 12.0:
    set = set_attack_distance_max

func set_attack_distance_max(val : float) -> void:
    attack_distance_max = val * val

var attack_pos : PackedVector2Array = [Vector2.ZERO, Vector2.ZERO]
var attack_incr : float = 4.0

var attack_button_pressed := false

const mouse_moving_distance_max : float = 46 ** 2
var mouse_global_pos : Vector2
var mouse_global_pos_dir : Vector2
var mouse_viewport_pos : Vector2
var mouse_moving_distance : float
var canvas_position : Vector2

@onready var attack_cooldown_timer : Timer = $AttackCooldown

@onready var body : Line2D = $"../Body"

@onready var jaw_a : Sprite2D = $Mouth/Jaw_0
@onready var jaw_b : Sprite2D = $Mouth/Jaw_1

@onready var health_ticker : Timer = $"../UI/HealthBar/HealthTicker"

# Player UIs
@onready var ui : CanvasLayer = $"../UI"
@onready var ui_attack_indicator : TextureProgressBar = $"../UI/AttackIndicator"
@onready var ui_attack_indicator_size_half : Vector2 = ui_attack_indicator.size * 0.5
@onready var ui_attack_cooldown : TextureProgressBar = $"../UI/AttackCooldown"
@onready var ui_attack_cooldown_size_half : Vector2 = ui_attack_cooldown.size * 0.5
@onready var ui_arrow : Sprite2D = $"../UI/Arrow"

var ui_obstacle_pos_temp := Vector2.ZERO
@onready var ui_obstacle : Sprite2D = $"../UINoFollow/FaceObstacleIcon"
@onready var ui_obstacle_anim : AnimationPlayer = $"../UINoFollow/FaceObstacleIcon/AnimationPlayer"

# Physics
@onready var raycast_obstacle : RayCast2D = $FaceObstacle
@onready var raycast_destroy_through : RayCast2D = $"DestroyThrough-R"
@onready var raycast_attack_min_range : RayCast2D = $AttackMinRange

@onready var area_destroy_through : Area2D = $"DestroyThrough-A"
@onready var player_general_area : Area2D = $PlayerGeneralArea

var open_mouth_rotation : float
func open_mouth(n : float) -> void:
    open_mouth_rotation = n * 30.0
    jaw_a.rotation_degrees = -open_mouth_rotation
    jaw_a.rotation_degrees = clampf(
        jaw_a.rotation_degrees, -open_mouth_rotation, 0.0
    )

    jaw_b.rotation_degrees = open_mouth_rotation
    jaw_b.rotation_degrees = clampf(
        jaw_b.rotation_degrees + open_mouth_rotation, 0.0, 30.0
    )

func attack_handler() -> void:
    attack_button_pressed = Input.is_action_pressed(&"Attack")

    ui_attack_indicator.visible =\
        attack_button_pressed\
        and allow_attack\
        and allow_control

    if allow_attack and allow_control:

        attack_out += attack_incr if attack_button_pressed else -attack_incr
        attack_out = clampf(attack_out, 0.0, 100.0)
        open_mouth(attack_out * 0.01)
        if attack_button_pressed:
            ui_arrow.look_at(mouse_viewport_pos)
            ui_arrow.position     = canvas_position
            ui_arrow.modulate.a   = attack_out * 0.01
            ui_arrow.offset.x     = attack_out * 0.6 + 68
            raycast_obstacle.\
            look_at(mouse_global_pos)
            global_rotation = raycast_obstacle.global_rotation

        if Input.is_action_just_released(&"Attack"):
            if !raycast_attack_min_range.is_colliding():
                player_general_area.monitorable = true
                player_general_area.monitoring = true
                attacking = true
                attack_dir = mouse_global_pos_dir
                attack_strength = attack_out

                attack_cooldown_timer.start(attack_cooldown * attack_out * 0.01 + 1.2)
                attack_pos[0]           = global_position
                allow_attack            = false

            else:
                # Trigger obstacle indicator if attack range is too close
                ui_obstacle_pos_temp = raycast_attack_min_range.get_collision_point()
                ui_obstacle_anim.play(&"Blink")

    ui_attack_indicator.value      = attack_out
    ui_attack_cooldown.value       = (
        (attack_cooldown_timer.time_left / attack_cooldown_timer.wait_time) * 100
    )

func _enter_tree() -> void:
    if Global.current_difficulty == Global.Difficulty.NORMAL:
        attack_cooldown = 1.1

        health_max = 125.0
        health_tick = 1.25
        health_regen = 1.6
    Global.player = self

func _ready() -> void:
    if show_debug:
        monitor_var()
        $"../DBG/VBoxContainer".set_vars()
    else:
        #$"../DBG".queue_free() # NOTE: Removing the debug UI messed up the player UI
        $"../DBG".visible = false

    ui_attack_cooldown.max_value   = 100

# TODO: reduce... things in _process
func _process(_delta : float) -> void:
    mouse_global_pos = get_global_mouse_position()
    mouse_global_pos_dir = global_position.direction_to(mouse_global_pos)
    mouse_viewport_pos = Cursor.mouse_viewport_position
    mouse_moving_distance = global_position.distance_squared_to(mouse_global_pos)

    canvas_position = get_global_transform_with_canvas().origin

    moving = Input.is_action_pressed(&"Move")\
        and mouse_moving_distance >= mouse_moving_distance_max\
        and allow_move\
        and allow_control
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

    ui_attack_indicator.position    = canvas_position - ui_attack_indicator_size_half
    ui_attack_cooldown.position     = canvas_position - ui_attack_cooldown_size_half

    raycast_obstacle.look_at(mouse_global_pos)

    #region X mark UI obstacle indicator functions
    if allow_control:
        if raycast_obstacle.is_colliding():
            if Input.is_action_just_pressed(&"Move"):
                ui_obstacle_pos_temp = raycast_obstacle.get_collision_point()
                ui_obstacle_anim.play(&"Blink")

    ui_obstacle.visible = ui_obstacle_anim.current_animation == "Blink" or !allow_move
    if ui_obstacle.visible:
        ui_obstacle.global_position = ui_obstacle_pos_temp
    #endregion

    attack_handler()

    if show_debug:
        monitor_var()

var velo : Vector2
var velo_max : Vector2
var attack_velo : Vector2
var collision : KinematicCollision2D
func _physics_process(delta : float) -> void:
    area_destroy_through.monitoring = attacking
    allow_move = !raycast_obstacle.is_colliding()

    if !attacking:
        velo = (
            moving_f
            * speed
            * mouse_global_pos_dir
        )
        velocity = velo
        move_and_slide()

    else:
        attack_distance_max = 6.4 * attack_strength
        velo_max = attack_speed * attack_dir
        velo = velo_max
        collision = move_and_collide(velo)

        attack_pos[1] = global_position

        if collision != null:
            velo = velo.bounce(collision.get_normal())
            shake_cam()
            reset_atk_dmg()
            attacking = false

        if attack_pos[0].distance_squared_to(attack_pos[1]) >= attack_distance_max:
            velo = velo.move_toward(Vector2.ZERO, delta)

            reset_atk_dmg()
            attacking = false

        velo = velo.clamp(Vector2.ZERO, velo_max)

        body.points[-1] = position

    if moving_f > 0.0 and !attacking:
        look_at(mouse_global_pos)

    ui_attack_cooldown.visible = attack_cooldown_timer.time_left > 0
    Global.attacking = attacking
    Global.moving = moving
    Global.moving_or_attacking = attacking or moving or moving_f > 0

    if Global.moving_or_attacking:
        if body.get_point_count() > body.body_segment_max:
            body.remove_point(0)
        else:
            body.add_point(position)

        body.update_collision_shape()
        #body.update_light_path()

func shake_cam() -> void:
    Camera.shake_start(
        attack_strength * 0.25 + 15,
        0.95,
        attack_strength * 0.08 + 16
    )
    #print(attack_strength)
    Global.camera_shaken_by_player.emit(attack_strength > 32.0)

@onready var light_general : PointLight2D = $Light

var general_light_tween : Tween
func fade_out_light() -> void:
    general_light_tween = create_tween()
    general_light_tween.tween_property(
        light_general, ^"modulate:a", 0.0, 0.85
        #light_general, ^"energy", 0.0, 0.85
    )\
    .set_ease(Tween.EASE_OUT)\
    .set_trans(Tween.TRANS_EXPO)

    await general_light_tween.finished
    light_general.enabled = false

func fade_in_light() -> void:
    light_general.enabled = true
    general_light_tween = create_tween()
    general_light_tween.tween_property(
        light_general, ^"modulate:a", 1.0, 0.85
        #light_general, ^"energy", 0.65, 0.85
    )\
    .set_ease(Tween.EASE_OUT)\
    .set_trans(Tween.TRANS_EXPO)

func reset_atk_dmg() -> void:
    open_mouth(0.0)
    attack_strength = 0.0
    attack_out = 0.0

func _on_AttackCooldown_timeout() -> void:
    allow_attack = true

signal damaged(current_health : float)
var invincible := false
var restarting := false
func damage_player(power : float) -> void:
    if !invincible:
        if health_ticker.is_stopped():
            health_ticker.start(health_tick)

        health =\
            clampf( health - ( (power * 1.2) if !attacking else 0.05),
            #clampf( health - ( (power * 0.9) if !attacking else 0.05),
            0.0, health_max )

        damaged.emit(health)

        # player killed
        if health <= 0:
            if !restarting:
                restarting = true
                Global.current_scene.pause_menu.disallow_pause()
                open_mouth(100.0)
                allow_attack = false
                allow_move = false
                allow_control = false
                Camera.start_fade_in()

                await Camera.faded_in
                Global.current_scene.call_deferred(
                    &"set_process_mode",
                    Node.PROCESS_MODE_DISABLED
                )

                await Global.scene_tree.create_timer(0.9).timeout
                Global.health = 100.0
                Global.scene_tree.call_deferred(
                    &"reload_current_scene"
                )

func monitor_var() -> void:
    $"../DBG/VBoxContainer".data = [
        #"fps",              Engine.get_frames_per_second(),
        #"allow_move",       allow_move,
        #"allow_attack",     allow_attack,
        #"moving",           Global.moving,
        #"attacking",        Global.attacking,
        #"moving_f",         Global.moving_f,
        #"moving_atking",    Global.moving_or_attacking,
        #"health",           round(health),
       ]
    $"../DBG/VBoxContainer".mon_vars()

var damage_output : float = 0.0
func _on_DestroyThroughA_body_entered(body_node : Node2D) -> void:
    if body_node.has_method(&"damage"):

        damage_output = (body_node.health + 20.0\
            if body_node.health - attack_strength <= 0\
            else attack_strength
        ) + attack_incr

        #if body_node.get(&"shielded") != null:
            #print("shielded")
            #if body_node.shielded:
                #body_node.damage(attack_strength)
            #else:
                #body_node.damage(
                    #body_node.health if body_node.health - attack_strength <= 0 else\
                    #attack_strength
                #)
        #else:
            #print("not shielded")
        body_node.damage(damage_output)

        shake_cam()

func _on_head_tree_entered() -> void:
    Global.player_physics_head = $"."
func _on_body_tree_entered() -> void:
    Global.player_physics_body = $"../DamageCollision"
func _on_destroy_through_tree_entered() -> void:
    Global.player_destroy_through = $"DestroyThrough-A"
func _on_general_area_tree_entered() -> void:
    Global.player_general_area = $PlayerGeneralArea

func _on_head_tree_exiting() -> void:
    Global.player_physics_head = null
func _on_body_tree_exiting() -> void:
    Global.player_physics_body = null
func _on_destroy_through_tree_exiting() -> void:
    Global.player_destroy_through = null
func _on_general_area_tree_exiting() -> void:
    Global.player_general_area = null
