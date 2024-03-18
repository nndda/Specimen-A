extends Line2D

@onready var head : CharacterBody2D = $"../Head"
@onready var damage_area : Area2D = $"../DamageCollision"

var body_segment_max := get_point_count()
var body_segment_max_physics : int = body_segment_max - 9
var body_segment_length_arr : PackedFloat32Array = []
var body_segment_physics_arr := PackedInt32Array(
    range(body_segment_max, body_segment_max - body_segment_max_physics, -1))

var collision_segments : Array[CollisionShape2D] = []
var collision_segments_shape : Array[SegmentShape2D] = []

@onready var lights_path : Path2D = $Lights
@onready var lights_anim : AnimationPlayer = $Lights/AnimationPlayer

func init_collision_shape() -> void:
    for segment : int in body_segment_max_physics:
        var shape_node := CollisionShape2D.new()
        var shape := SegmentShape2D.new()

        shape.b = points[ segment + 1 ]
        shape.a = points[ segment ]

        shape_node.shape = shape

        # NOTE: Debug purpose only
        #shape_node.debug_color = Color.YELLOW
        #shape_node.z_index = 99

        damage_area.add_child(shape_node)
        collision_segments.append(shape_node)
        collision_segments_shape.append(shape)

func update_collision_shape() -> void:
    for segment : int in body_segment_max_physics:
        collision_segments_shape[ segment ].b = points[ body_segment_physics_arr[ segment ] - 1 ]
        collision_segments_shape[ segment ].a = points[ body_segment_physics_arr[ segment ] - 2 ]

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

func update_light_path() -> void:
    if lights_path.visible:
        for n : int in body_segment_max - 5:
            lights_path.curve.set_point_position(n, points[n])

func _ready() -> void:
    if !lights_anim.is_playing():
        lights_anim.play(&"Idle")
    call_deferred(&"init_collision_shape")
    lights_path.curve.clear_points()
    for n : int in body_segment_max - 5:
        lights_path.curve.add_point(Vector2.ZERO)

func _physics_process(_delta : float) -> void:
    if Global.moving_or_attacking:
        if get_point_count() > body_segment_max:
            remove_point(0)
        else:
            add_point(head.position)
