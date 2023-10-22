extends Node2D

var damage : float = 4.25
var firing : bool = false

@export_node_path("Area2D","RayCast2D") var line_of_sight

var trigger_area : NodePath
@onready var on_line : bool = false

func _on_line( object ) -> void: if [ "Head", "DamageCollision" ]\
.has( object.get_name() ): on_line = true
func _off_line( object ) -> void: if [ "Head", "DamageCollision" ]\
.has( object.get_name() ): on_line = false

func _ready() -> void:

    if get_parent().get_node_or_null( get_parent().custom_trigger ) == null:
            trigger_area = NodePath( "../TriggerArea" )
    else:   trigger_area = NodePath( get_parent().custom_trigger )

#    if not get_node( trigger_area ) is CollisionObject2D:
#        push_error( dbg.value_is( trigger_area, "!CollisionObject2D" ) )

    if  get_node_or_null( line_of_sight ) != null and\
        line_of_sight is CollisionObject2D:

        printt( "", self.get_name(),
        "line_of_sight : " + str( get_node( line_of_sight ).get_class() ) )

        if get_node( line_of_sight ) is RayCast2D:

            get_node( line_of_sight ).add_exception(
                get_node( trigger_area ) )

        elif get_node( line_of_sight ) is Area2D:

            for signal_on in [ "body_entered", "area_exited" ]:
                get_node( line_of_sight ).connect( signal_on,
                Callable( self, "_on_line" ) )

            for signal_off in [ "body_exited", "area_exited" ]:
                get_node( line_of_sight ).connect( signal_off,
                Callable( self, "_off_line" ) )

    else: push_error( dbg.value_is( "weapon_node", "null" ) )

#    if get_node_or_null( firing_animation_player ) != null:
#        get_node( firing_animation_player ).connect(
    $FireFunction.animation_player.connect(
        "animation_finished",
        Callable( get_parent(), "Weapon_AnimationFinished" ) )
#    else:
#        push_error( dbg.value_is( "firing_animation_player", "null" ) )

func _process( _delta ) -> void: get_parent().firing = firing
func _physics_process( _delta ) -> void:
    if get_parent().triggered: if get_node( line_of_sight ) is RayCast2D:
        on_line = get_node( line_of_sight ).is_colliding()

func fire() -> void: $FireFunction.animation_player.play( "Firing" )
