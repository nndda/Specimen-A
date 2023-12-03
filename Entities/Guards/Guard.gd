extends CharacterBody2D

# Base scene for ALL entities

@export var health : float = 50
@export var speed : float = 80.0
## Is the entity moving away or approach the player's head
@export var moving_away : bool = false
## Is the entity able to move
@export var stationary : bool = false
## Is the entity immune to any damage (invincible)
@export var immune : bool = false

#@export_range( 0.0, 1.0 )
#var rotate_weight      : float = 0.8

@export_group("Nodes")

## Designated 'patrol' path for non-stationary entity. Entity will not follow their path once triggered
@export_node_path("PathFollow2D") var path_ : NodePath; var path : PathFollow2D

## Custom Area2D trigger that will detect player. Replaced the default TriggerArea node
@export_node_path("Area2D") var custom_trigger_ : NodePath; var custom_trigger : Area2D

## Weapon scene for the entity
@export_node_path("Node2D") var weapon_node : NodePath; var weapon : Node2D

## The 'death scene' for when the entity is killed or destroyed
@export_node_path("Node2D") var corpse_scene : NodePath; var corpse : Node2D

## Particle scene for when the entity is attacked or damaged by the player
@export_file("*.tscn") var blood_scene : String = "res://Shaders/Particles/BloodSplatters.tscn"; var blood : Node

var is_triggered    : bool = false
var firing          : bool = false
signal triggered
signal killed

@export_group( "Timing" )
@export_range( 0.0, 5.0, 0.1 ) var init_cooldown    : float = 0.0
@export_range( 0.8, 5.0, 0.1 ) var cooldown         : float = 0.8
@onready var cooldown_timer : Timer = $AttackCooldown

var fire_clear  : bool = false
var fire_ready  : bool = false
var clear       : bool = true
var player_near : bool = false

signal path_changed( path )
signal target_reached
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D

var velo            : Vector2
var move_direction  : Vector2

func _ready() -> void:
    path = get_node_or_null( path_ )
    custom_trigger = get_node_or_null( custom_trigger_ )

    corpse = get_node( corpse_scene )
    corpse.reparent( Global.layer_dict[ "Objects/Corpses" ] )

    corpse.modulate.a       = 0.8
    corpse.z_as_relative    = false
    corpse.z_index          = -100

    weapon = get_node( weapon_node )

    clear = init_cooldown == 0.0
    cooldown_timer.wait_time = cooldown

    if custom_trigger == null:
        custom_trigger_ = NodePath( "TriggerArea" ) # Set default
    else:
        $TriggerArea.queue_free()
        custom_trigger.collision_mask = 512
        custom_trigger.body_entered.connect( _on_TriggerArea_body_entered )

    Global.camera_shaken_by_player.connect( func():
        if player_near: triggered.emit() )

    if stationary:
        nav_agent = null
        for free_itms in [ $KeepDistance, $KeepMove, $NavigationAgent2D ]:
            free_itms.queue_free()

    else:
        for hidden_item in [ $KeepDistance, $KeepMove ]:
            hidden_item.visible = false

func _process( _delta ) -> void:

    corpse.global_position = global_position
    corpse.look_at( Global.head_pos )

    if is_triggered:
        rotation_degrees = wrapf( rotation_degrees, 0, 360 )
        fire_clear = fire_ready and weapon.on_line

    else:
        if path != null:
            global_position = path.global_position
            global_rotation = path.global_rotation

    if fire_clear:
        weapon.fire()
        fire_ready = false

    $VisibilityHandler/VisibleOnScreenEnabler2D.global_position = self.global_position

# TODO:  trigger system is a mess
func _physics_process( _delta ) -> void:
    if is_triggered:
        look_at( Global.head_pos )
        if !stationary:
            nav_agent.set_velocity( Vector2( speed, speed ) )
        else:
            $Sprite2D.rotation_degrees = -rotation_degrees

func Weapon_AnimationFinished( anim ) -> void:
    if anim == "Firing": cooldown_timer.start( cooldown )
func _on_AttackCooldown_timeout() -> void: fire_ready = true

func damage( power : float ) -> void: if !immune:

    print( self," damaged :", power )

    if !is_triggered: triggered.emit()
    health -= power

    if health <= 0:
        corpse.z_as_relative = true
        corpse.z_index = 0
        queue_free()

    else:
        if !(power <= 5.0):
            blood                   = load( blood_scene ).instantiate()
            blood.custom_init_pos   = true
            blood.init_pos          = global_position
            Global.layer_dict[ "Objects/Particles" ].add_child( blood )

# TODO:  navigation is a mess
var arrived : bool = false
func set_target_pos( pos : Vector2 ) -> void:
    arrived = false
    nav_agent.target_position = pos

var direction : Vector2
func _on_NavigationAgent2D_velocity_computed( safe_velocity ) -> void:
    if !nav_agent.is_navigation_finished():
        velocity = safe_velocity * direction
        move_and_slide()
    elif !arrived:
        arrived = true
        nav_agent.path_changed.emit()

@onready var keep_distance : Node2D = $KeepDistance
@onready var keep_distance_pos : Node2D = $KeepDistance/Position2D
@onready var keep_distance_a : Node2D = $KeepDistance/n1
@onready var keep_distance_b : Node2D = $KeepDistance/n2
@onready var keep_move_a : Node2D = $KeepMove/n1
@onready var keep_move_b : Node2D = $KeepMove/n2

func _on_UpdatePlayerPos_timeout() -> void:
    if global_position.distance_to( Global.head_pos ) >= 160.0:
        if !moving_away:
            direction = global_position.direction_to( Global.head_pos )
            set_target_pos( Global.head_pos )
    else:
        randomize()
        keep_distance.rotation_degrees = randf_range( -15, 15 )
        keep_distance_pos.position = Vector2(
            randf_range( keep_distance_a.position.x,   keep_distance_b.position.x ),
            randf_range( keep_move_a.position.y,       keep_move_b.position.y )
            )

        direction = global_position.direction_to( keep_distance_pos.global_position )
        set_target_pos( keep_distance_pos.global_position )

func _on_TriggerArea_body_entered( _body ) -> void:
    triggered.emit()
func _on_TriggerArea_area_entered( _area ) -> void:
    triggered.emit()

func _on_triggered() -> void:
    if !is_triggered:
        is_triggered = true
        printt( "", self.get_name(), " is triggered" )

        cooldown_timer.start( cooldown )

        for f in [ "GeneralArea", "TriggerArea" ]:
            if get_node_or_null( f ) != null:
                get_node( f ).queue_free()

        if path != null: path.queue_free()

        if !stationary: $NavigationAgent2D/UpdatePlayerPos.start()

func _on_GeneralArea_area_entered( _area ) -> void:
    player_near = true
func _on_GeneralArea_area_exited( _area ) -> void:
    player_near = false

