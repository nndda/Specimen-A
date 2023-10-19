extends CharacterBody2D

@export var health      : float = 50
@export var speed       : float = 80.0
@export var moving_away : bool = false
@export var stationary  : bool = false
#@export_range( 0.0, 1.0 )
#var rotate_weight      : float = 0.8

@export_group("Nodes")
@export_node_path("PathFollow2D") var path      : NodePath
@export_node_path("Area2D") var custom_trigger  : NodePath
@export_node_path("Node2D") var weapon_node     : NodePath
@export_node_path("Node2D") var corpse_scene    : NodePath
@export_file("*.tscn")
var blood_scene : String = "res://Shaders/Particles/BloodSplatters.tscn"

var weapon      : Object
var triggered   : bool = false
var firing      : bool = false
signal is_triggered

@export_group( "Timing" )
@export_range( 0.0, 5.0, 0.1 ) var init_cooldown    : float = 0.0
@export_range( 0.8, 5.0, 0.1 ) var cooldown         : float = 0.8
var fire_clear  : bool = false
var fire_ready  : bool = false
var clear       : bool = true
var player_near : bool = false

signal path_changed( path )
signal target_reached
@onready var nav_agent : Object = $NavigationAgent2D

var velo            : Vector2
var move_direction  : Vector2

func get_player_pos() -> Vector2: return glbl.head_pos

func _ready() -> void:

    printt( "-", self.get_name(), corpse_scene, global_position )

    corpse = get_node( corpse_scene )
    corpse.reparent( glbl.layer_dict[ "Objects/Corpses" ] )

    corpse.modulate.a       = 0.8
    corpse.z_as_relative    = false
    corpse.z_index          = -100

    weapon = get_node( weapon_node )

    clear = init_cooldown == 0.0
    $AttackCooldown.wait_time = cooldown

    if get_node_or_null( custom_trigger ) != null:
        $TriggerArea.queue_free()
        get_node( custom_trigger ).connect( "body_entered",
        Callable( self, "_on_TriggerArea_body_entered" ) )
    else: custom_trigger = NodePath( "TriggerArea" ) # Set default

    if stationary:
        nav_agent = null
        for free_itms in [ $KeepDistance, $KeepMove, $NavigationAgent2D ]:
            free_itms.queue_free()

    else:
        for hidden_itms in [ $KeepDistance, $KeepMove ]:
            for hidden_items in hidden_itms.get_children():
                hidden_items.hide()

#    $VisibilityHandler.show()
    $VisibilityHandler/N.show()
    $VisibilityHandler/N.connect( "screen_entered", Callable( self, "show" ) )
    $VisibilityHandler/N.connect( "screen_exited",  Callable( self, "hide" ) )

func _process( _delta ) -> void:

    corpse.global_position = global_position
    corpse.look_at( glbl.head_pos )

    if triggered:
        rotation_degrees = wrapf( rotation_degrees, 0, 360 )
        fire_clear = fire_ready and weapon.on_line

    else:
        if player_near and cam.shaking: triggered = true

        if get_node_or_null( path ) != null:
            global_position = get_node( path ).global_position
            global_rotation = get_node( path ).global_rotation

    if fire_clear:
        weapon.fire()
        fire_ready = false
    
    $VisibilityHandler/N.global_position = global_position

func _physics_process( _delta ) -> void : if triggered:
    look_at( glbl.head_pos )
    if !stationary: nav_agent.set_velocity( Vector2( speed, speed ) )
    else:           $Sprite2D.rotation_degrees = -rotation_degrees

func Weapon_AnimationFinished( anim ) -> void:
    if anim == "Firing": $AttackCooldown.start( cooldown )
func _on_AttackCooldown_timeout() -> void: fire_ready = true

var blood   : Object
var corpse  : Object

func damage( power : float ) -> void:

    if !triggered: emit_signal( "is_triggered" )
    health -= power

    if health <= 0:
        corpse.z_as_relative = true
        corpse.z_index = 0
        queue_free()

    else:
        blood                   = load( blood_scene ).instantiate()
        blood.custom_init_pos   = true
        blood.init_pos          = global_position
        glbl.layer_dict[ "Objects/Particles" ].add_child( blood )



var arrived : bool = false
func set_target_pos( pos : Vector2 ) -> void:
    arrived = false
    nav_agent.target_position = pos

var direction : Vector2
func _on_NavigationAgent2D_velocity_computed( safe_velocity ) -> void:
    if !nav_agent.is_navigation_finished():
        velo = safe_velocity
        velocity = velo * direction
        move_and_slide()
    elif !arrived:
        arrived = true
        nav_agent.emit_signal("path_changed")

func _on_UpdatePlayerPos_timeout() -> void:
    if global_position.distance_to( glbl.head_pos ) >= 160.0:
        if !moving_away:
            direction = global_position.direction_to( glbl.head_pos )
            set_target_pos( glbl.head_pos )
    else:
        randomize()
        $KeepDistance.rotation_degrees = randf_range( -15, 15 )
        var pos_rand = Vector2(
            randf_range( $KeepDistance/n1.position.x,   $KeepDistance/n2.position.x ),
            randf_range( $KeepMove/n1.position.y,       $KeepMove/n2.position.y ) )
        $KeepDistance/Position2D.position = pos_rand

        direction = global_position.direction_to( $KeepDistance/Position2D.global_position )
        set_target_pos( $KeepDistance/Position2D.global_position )

func _on_TriggerArea_body_entered( body ) -> void:
    if body.get_name() == "Head": emit_signal( "is_triggered" )
func _on_TriggerArea_area_entered( area ) -> void:
    if area.get_name() == "DamageCollision": emit_signal( "is_triggered" )

func _on_is_triggered() -> void: if !triggered:
    triggered = true
    printt( "", self.get_name(), dbg.value_is( "triggered", "true" ) )
    $AttackCooldown.start( cooldown )

    for f in [ "GeneralArea", "TriggerArea" ]:
        if get_node_or_null( f ) != null: get_node( f ).queue_free()
    if get_node_or_null( path ) != null: get_node( path ).queue_free()
    if !stationary: $NavigationAgent2D/UpdatePlayerPos.start()

func _on_general_area_entered( area ) -> void:
    if area.get_name() == "ShakeArea": player_near = true
func _on_general_area_exited( area ) -> void:
    if area.get_name() == "ShakeArea": player_near = false

