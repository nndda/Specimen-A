extends Node2D

var damage : float = 4.25
var firing : bool = false

@export_node_path( "Area2D", "RayCast2D" ) var line_of_sight_; var line_of_sight : Node2D
@export_node_path( "Area2D", "RayCast2D" ) var friendly_sight_; var friendly_sight : Node2D

var parent : Node
var trigger_area : NodePath
@onready var on_line : bool = false

var player_bodies : Array[Node2D] = []

func _on_line( object ) -> void:
#    on_line = [ "Head", "DamageCollision" ].has( object.get_name() )
    on_line = player_bodies.has( object )
func _off_line( object ) -> void:
#    on_line = ![ "Head", "DamageCollision" ].has( object.get_name() )
    on_line = !player_bodies.has( object )

func _enter_tree():
    parent = get_parent()
    player_bodies = [ Global.player_physics_head, Global.player_physics_body ]

func _ready() -> void:
    line_of_sight = get_node_or_null( line_of_sight_ )
    friendly_sight = get_node_or_null( friendly_sight_ )

    trigger_area = NodePath( "../TriggerArea" if parent.custom_trigger == null else parent.custom_trigger_ )

#    if parent.custom_trigger == null:
#        trigger_area = NodePath( "../TriggerArea" )
#    else:
#        trigger_area = NodePath( parent.custom_trigger_ )

    if  line_of_sight != null and\
        line_of_sight is CollisionObject2D:

#        printt( "", self.get_name(), "line_of_sight : " + str( line_of_sight.get_class() ) )

        if line_of_sight is RayCast2D:
            line_of_sight.add_exception( get_node( trigger_area ) )

        elif line_of_sight is Area2D:

            for signal_on in [ "body_entered", "area_exited" ]:
                line_of_sight.connect( signal_on, Callable( self, "_on_line" ) )

            for signal_off in [ "body_exited", "area_exited" ]:
                line_of_sight.connect( signal_off, Callable( self, "_off_line" ) )

#    else:
#        push_error( dbg.value_is( "weapon_node", "null" ) )

    $FireFunction.animation_player.connect(
        "animation_finished", Callable( parent, "Weapon_AnimationFinished" ) )

func _process( _delta ) -> void:
    parent.firing = firing

func _physics_process( _delta ) -> void:
    if parent.triggered:
        if line_of_sight is RayCast2D:
            on_line = line_of_sight.is_colliding() and !friendly_sight.is_colliding()

func fire() -> void:
    $FireFunction.animation_player.play( "Firing" )
