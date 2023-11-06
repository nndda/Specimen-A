extends CharacterBody2D

var speed               : float = 360.0

var moving              : bool = false
var moving_f            : float

var face_obstacle       : bool = false

var allow_attack        : bool = true
var allow_move          : bool = true

var attacking           : bool = false
var attack_strength     : float
var attack_out          : int
var attack_dir          : Vector2
var attack_cooldown     : float = 2.0

var attack_speed        : float = 22.0

var attack_distance_max : float = 32.0 * 12.0
var attack_pos : PackedVector2Array = [ Vector2.ZERO, Vector2.ZERO ]

var mouse_global_pos : Vector2
var mouse_viewport_pos : Vector2
var canvas_position : Vector2

@onready var attack_cooldown_timer : Timer = $AttackCooldown

@onready var jaw_a : Sprite2D = $Mouth/Jaw_0
@onready var jaw_b : Sprite2D = $Mouth/Jaw_1

# Player UIs
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
@onready var area_shake : Area2D = $AreaShake


func open_mouth( n : float ) -> void:
    jaw_a.rotation_degrees = n * -30.0
    jaw_a.rotation_degrees = clampf(
        jaw_a.rotation_degrees, -30.0, 0.0 )

    jaw_b.rotation_degrees = n * 30.0
    jaw_b.rotation_degrees = clampf(
        jaw_b.rotation_degrees + n * 30.0, 0.0, 30.0 )

func attack_handler() -> void:

    ui_attack_indicator.visible = Input.is_action_pressed( "Attack" ) and allow_attack

    if allow_attack:

        match Global.skill_current:
            Global.skill.none:
                attack_out  += 4 if Input.is_action_pressed( "Attack" ) else -4
                attack_out  = int( clamp( attack_out, 0, 100 ) )
                open_mouth( float( attack_out ) * 0.01 )
                if Input.is_action_pressed( "Attack" ):
                    ui_arrow.look_at( mouse_viewport_pos )
                    ui_arrow.position     = canvas_position
                    ui_arrow.modulate.a   = float( attack_out ) * 0.01
                    ui_arrow.offset.x     = ( ( 3 * float( attack_out ) ) * 0.2 ) + 68
                    raycast_obstacle.look_at( mouse_global_pos )
                    self.look_at( mouse_global_pos )

                if Input.is_action_just_released( "Attack" ):
                    area_shake.monitorable  = true
                    area_shake.monitoring   = true
                    attacking               = true
                    attack_dir              = global_position.direction_to( mouse_global_pos )
                    attack_strength         = float( attack_out )

                    attack_cooldown_timer.start( attack_cooldown * ( float( attack_out ) * 0.01 ) )
                    attack_pos[0]           = global_position
                    allow_attack            = false

#           Global.skill.DischargeShrapnel:
#               if Input.is_action_just_pressed("Attack") and Global.shrapnel_current > 0:
#                   pass
#
#           Global.skill.EMPBurst:
#               if Input.is_action_just_pressed("Attack") and Global.emp_charge > 0:
#                   pass
#
#           Global.skill.SynthesizeAcids:
#               if Input.is_action_just_pressed("Attack") and Global.acid > 0:
#                   pass

    ui_attack_indicator.value      = attack_out
    ui_attack_cooldown.max_value   = 100
    ui_attack_cooldown.value       = (
        ( attack_cooldown_timer.time_left / attack_cooldown_timer.wait_time ) * 100 )

func _enter_tree():
    Global.player = self

func _ready() -> void:
    monitor_var()

func _process( delta ) -> void:


    monitor_var()
    mouse_global_pos = get_global_mouse_position()
    mouse_viewport_pos = get_viewport().get_mouse_position()
    
    canvas_position =  get_global_transform_with_canvas().origin

#    moving = true if ( Input.is_action_pressed( "Move" ) and allow_move ) else false
    if allow_move:
        moving = true if (
        Input.is_action_pressed( "Move" )
        ) else false
    else:
        moving = false

#    moving_f += 0.1 if moving else -0.005
    if moving:
        moving_f += 0.1
    else:
        moving_f -= 0.085

    moving_f = clampf( moving_f, 0.0, global_position.distance_to( mouse_global_pos ) >= 25 )

    Global.health += ( 2.5 * delta )

    Global.head_pos               = global_position
    Global.head_canvas_pos        = get_global_transform_with_canvas().origin


    ui_arrow.look_at( mouse_viewport_pos )
    ui_arrow.position     = canvas_position
    ui_arrow.modulate.a   = moving_f
    ui_arrow.offset.x     = ( moving_f * 60 ) + 68


    ui_attack_indicator.position    = canvas_position - ui_attack_indicator.size * 0.5
    ui_attack_cooldown.position     = canvas_position - ui_attack_cooldown.size * 0.5


    raycast_obstacle.look_at( mouse_global_pos )
    ui_obstacle.visible = !allow_move

    if raycast_obstacle.is_colliding():
        if Input.is_action_just_pressed( "Move" ):
            ui_obstacle_pos.global_position = raycast_obstacle.get_collision_point()
            ui_obstacle.position = ui_obstacle_pos.get_global_transform_with_canvas().origin
            ui_obstacle_anim.play( "Blink" )

    attack_handler()


var velo : Vector2
var attack_velo : Vector2
var collision : KinematicCollision2D
func _physics_process( delta ) -> void:

    area_destroy_through.monitoring = attacking
    allow_move = !raycast_obstacle.is_colliding()

    if !attacking:
        velo = (
            ( moving_f *
            ( ( speed ) * global_position.direction_to( mouse_global_pos ) ) )
        )
        velocity = velo
        move_and_slide()

#        if area_shake.monitorable: shake_finished()

    else:
        attack_distance_max = 6.4 * attack_strength #( 12.0 * 32.0 ) * ( attack_strength / 60 )
        velo            = attack_speed * attack_dir
        collision       = move_and_collide( velo )

        attack_pos[ 1 ] = global_position

        if collision != null:
            velo = velo.bounce( collision.get_normal() )
            shake_cam()
            reset_atk_dmg()
            attacking = false

        if attack_pos[0].distance_to( attack_pos[ 1 ] ) >= attack_distance_max:
#            velo -= Vector2( 2.0 * delta, 2.0 * delta )
            velo -= Vector2.ONE * 2.0 * delta
            reset_atk_dmg()
            attacking = false

        velo = clamp( velo, Vector2.ZERO, attack_speed * attack_dir )

    if moving_f > 0 and !attacking:
        self.look_at( mouse_global_pos )

    ui_attack_cooldown.visible = ( attack_cooldown_timer.time_left > 0 )
    Global.attacking = attacking
    Global.moving = moving

func shake_cam() -> void:
    cam.shake_start(
        ( attack_strength * 0.25 ) + 15, #15 + ( 25 * ( attack_strength / 100 ) ),
        0.95,
        ( ( 2 * attack_strength ) * 0.04 ) + 16 ) #16 + 8 * ( attack_strength / 100 ) )
    Global.emit_signal("camera_shaken_by_player")


func reset_atk_dmg() -> void:
    open_mouth( 0 )
    attack_strength = 0
    attack_out = 0

func _on_AttackCooldown_timeout() -> void: allow_attack = true



var invincible : bool = false
func damage_player( power : float ) -> void: if !invincible:
    var power_total : float = (
        power * 1.25 ) * 1.0 if !attacking else 0.0

#    print("DamagePlayer: " + str( power_total ) )
    Global.health -= power_total
    $"../Body/Lights/AnimationPlayer/Hit".play( "Hit" )
#    $"../Body/AnimationPlayer/Hit".play("Hit")
#    $"../UI/Control/HealthBar/AnimationPlayer".play("Visible")

func monitor_var() -> void:
    $"../DBG/VBoxContainer".data = [
        "fps",              Engine.get_frames_per_second(),
        "body length",      round(Global.worm_length),
#        "head pos",         Global.head_pos.round(),
#        "moving",           moving,
        "attacking",        Global.attacking,
        "health",           round(Global.health),
        ]


func _on_DestroyThroughA_body_entered( body ) -> void:
    if body.has_method( "damage" ):

        if body.health - attack_strength <= 0:
                body.damage( body.health )
        else:   body.damage( attack_strength )

        shake_cam()

#       else:
#           if collision != null:
#               if collision.has_method("damage"):
#                   collision.damage(attack_strength)
#                   reset_atk_dmg()
#               shake_cam()

