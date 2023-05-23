extends Camera2D

@onready var shake_tween : Tween

var shaking		: bool = false
var shake_power	: float = 0.0

func ShakeStart(
    power : float,
    time : float = 0.8,
    frequency : float = 16
    ) -> void:
    if power >= shake_power:
        shake_power	= power
        shaking		= true
        $Shake/Duration.start( time )
        $Shake/Frequency.start( 1 / frequency )

func Shake() -> void:
    randomize()
    shake_tween = create_tween().bind_node( self )
    shake_tween.tween_property(
        self, "offset", Vector2(
            randf_range( -shake_power, shake_power ),
            randf_range( -shake_power, shake_power )
            )
            * ( $Shake/Duration.time_left / $Shake/Duration.wait_time ),
        $Shake/Frequency.wait_time
    )
    shake_tween.set_trans( Tween.TRANS_SINE )
    shake_tween.set_ease( Tween.EASE_IN_OUT )

    shake_tween.play()

var visload_entity			: Array
var visload_running			: bool = true
var visload_path_follow		: PathFollow2D
var current_objects_list	: Array[ Vector2 ]

func InitVisualLoading() -> void:
    $ColorRect/AnimationPlayer.play( "RESET" )

    visload_running		 = true

    cam.following		 = false
    cam.enabled			 = true

    var visload_path	 : Path2D = Path2D.new()
    var visload_path_fol : PathFollow2D = PathFollow2D.new()
    var visload_curve	 : Curve2D = Curve2D.new()
    var tween			 : Tween = create_tween().bind_node( self )

    visload_path.add_child( visload_path_fol )
    glbl.current_scene.call_deferred( "add_child", visload_path )
    visload_path_fol.progress_ratio = 0.0

    for n in glbl.current_objects:
        if !current_objects_list.has( n.global_position ):
            current_objects_list.append( n.global_position )

    current_objects_list.erase( Vector2.ZERO )

    current_objects_list.sort_custom( func( a, b ): return (
        a.distance_to( glbl.head_pos ) > b.distance_to( glbl.head_pos ) ) )

    for i in current_objects_list:
        visload_curve.add_point( i )
    for e in [ visload_path, visload_path_fol ]:
        visload_entity.append( e )

    print( current_objects_list )

    visload_path.curve	= visload_curve
    visload_path_follow	= visload_path_fol

    tween.tween_property(
        visload_path_fol, "progress_ratio",
        1.0, glbl.current_objects.size() * 0.45 )
    tween.connect(
        "finished", Callable( self, "FinishedVisualLoading" ) )
    tween.set_ease( Tween.EASE_OUT )
    tween.play()

func FinishedVisualLoading() -> void:

    print( "FinishedVisualLoading()" )

    for e in visload_entity:
        e.queue_free()

    glbl.current_objects.clear()
    visload_entity.clear()
    current_objects_list.clear()

    cam.following	= true
    cam.enabled		= true

    $ColorRect/AnimationPlayer.play( "fade_out" )
    visload_running = false


var following : bool = false
func _process( _delta ) -> void:
    if following:
        global_position = glbl.head_pos

        drag_horizontal_offset = remap(
            get_viewport().get_mouse_position().x,
            0.0, get_viewport_rect().size.x,
            -1.0, 1.0 )
        drag_vertical_offset = remap(
            get_viewport().get_mouse_position().y,
            0.0, get_viewport_rect().size.y,
            -1.0, 1.0 )

    else: if visload_path_follow != null:
            if visload_running: global_position = visload_path_follow.global_position

func _on_Frequency_timeout() -> void: Shake()
func _on_Duration_timeout() -> void:
    shake_power		= 0
    shaking			= false
    $Shake/Frequency.stop()
