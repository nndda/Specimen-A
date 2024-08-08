extends Line2D

var body_segment_max := get_point_count()
var body_segment_max_physics : int = body_segment_max - 9
var body_segment_length_arr : PackedFloat32Array = []
var body_segment_physics_arr : Array = range(
    body_segment_max, body_segment_max - body_segment_max_physics, -1
)

var collision_segments_shape : Array[SegmentShape2D] = []

#@onready var lights_path : Path2D = $Lights
#@onready var lights_anim : AnimationPlayer = $Lights/AnimationPlayer
#@onready var lights_anim_delay : Timer = $Lights/AnimationPlayer/Delay

func init_collision_shape() -> void:
    body_segment_physics_arr.make_read_only()

    for segment : int in body_segment_max_physics:
        var shape_node := CollisionShape2D.new()
        var shape := SegmentShape2D.new()

        shape.b = points[segment + 1]
        shape.a = points[segment]

        shape_node.shape = shape

        # NOTE: Debug purpose only
        #shape_node.debug_color = Color.YELLOW
        #shape_node.z_index = 99

        $"../DamageCollision".add_child(shape_node)
        collision_segments_shape.append(shape)

    collision_segments_shape.make_read_only()

func update_collision_shape() -> void:
    for segment : int in body_segment_max_physics:
        collision_segments_shape[segment].b = points[body_segment_physics_arr[segment] - 1]
        collision_segments_shape[segment].a = points[body_segment_physics_arr[segment] - 2]

# WARNING : performance issue
#func update_body_length() -> void:
    #var sgmnt_count := get_point_count()
    #for sgmnt in sgmnt_count - 1:
        #if body_segment_length_arr.size() <= sgmnt:
            #body_segment_length_arr.append(
            #points[ sgmnt ].distance_to(
            #points[ wrapi(sgmnt, 0, sgmnt_count) + 1 ])
            #)
        #else:
            #body_segment_length_arr[ sgmnt ] = (
            #points[ sgmnt ].distance_to(
            #points[ wrapi(sgmnt, 0, sgmnt_count) + 1 ])
            #)

# NOTE: disabled for performance
#func update_light_path() -> void:
    #if lights_path.visible:
        #for n : int in body_segment_max - 5:
            #lights_path.curve.set_point_position(n, points[n])

func _ready() -> void:
    $Lights.queue_free()
    #if !lights_anim.is_playing():
        #lights_anim.play(&"Idle")
    call_deferred(&"init_collision_shape")

    #lights_path.curve.clear_points()
    #for n : int in body_segment_max - 5:
        #lights_path.curve.add_point(Vector2.ONE)
    #update_light_path()

#func _on_lights_anim_finished(anim_name : StringName) -> void:
    #if anim_name == &"Idle":
        #lights_anim_delay.start(0.5)
        #await lights_anim_delay.timeout
        #lights_anim.play(&"Idle")
