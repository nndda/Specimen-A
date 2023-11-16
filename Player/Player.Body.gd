extends Line2D

@onready var head : CharacterBody2D = $"../Head"
@onready var damage_area : Object = $"../DamageCollision"

var body_segment_max : int = 32
var body_segment_length_arr : PackedFloat32Array = []

@onready var collision_segments : Array[CollisionShape2D] = []
@onready var collision_segments_shape : Array[SegmentShape2D] = []

@onready var lights_path : Path2D = $Lights
@onready var lights_anim : AnimationPlayer = $Lights/AnimationPlayer


func InitCollisionShape() -> void:
    for sgmnt in get_point_count() - 2:
        var shape_node : CollisionShape2D = CollisionShape2D.new()
        var shape: SegmentShape2D = SegmentShape2D.new()

        shape.a = points[ sgmnt ]
        shape.b = points[ sgmnt + 1 ]

        shape_node.shape = shape
        damage_area.add_child( shape_node )
        collision_segments.append( shape_node )
        collision_segments_shape.append( shape )

#    collision_segments = damage_area.get_children()
#    for shape in collision_segments:
#        collision_segments_shape.append( shape.shape )
    
#    for n in body_segment_max - 2:
#        print( "collision_segments_shape[ " + str(n) + " ].a = points[ " + str(n) + " ]" )

var body_segment_max_safe : int = body_segment_max - 2
func UpdateCollisionShape() -> void:
    for segment in body_segment_max_safe:
        collision_segments_shape[ segment ].a = points[ segment ]
        collision_segments_shape[ segment ].b = points[ segment + 1 ]


func UpdateWormLength() -> void:
    var sgmnt_count : int = get_point_count()
    for sgmnt in sgmnt_count - 1:
        if body_segment_length_arr.size() <= sgmnt:
            body_segment_length_arr.append(
            points[ sgmnt ].distance_to(
            points[ wrapi( sgmnt, 0, sgmnt_count ) + 1 ] )
            )
        else:
            body_segment_length_arr[ sgmnt ] = (
            points[ sgmnt ].distance_to(
            points[ wrapi( sgmnt, 0, sgmnt_count ) + 1 ] )
            )


func UpdateLightPath() -> void: if lights_path.visible:
    for n in get_point_count() - 1 :
        lights_path.curve.set_point_position(
        ( get_point_count() - 2) - n, points[ n ] )
    if head.moving and !lights_anim.is_playing():
        lights_anim.play( "Idle" )

var health_bar_offsets : PackedFloat32Array = [ 0.02, 0.04 ]

#@onready var health_bar = $"../HealthUI"
#@onready var health_bar = $"../HealthUIS"
@onready var health_bar : Object
func UpdateHealthUI() -> void: if health_bar.visible:

#        health_bar_offsets[0] = range_lerp(Global.health,100.0,0.0,0.02,0.96)
#        health_bar_offsets[1] = range_lerp(Global.health,100.0,0.0,0.04,0.98)

#        health_bar_offsets[0] = clamp(health_bar_offsets[0],0.02,0.96)
#        health_bar_offsets[1] = clamp(health_bar_offsets[1],0.04,0.98)

        for n in ( get_point_count() ):
            if health_bar.get_point_count() <= n:
                    health_bar.add_point( points[ n ] )
            else:   health_bar.points[ n ] = points[ n ]

#        health_bar.gradient.offsets[1] = health_bar_offsets[0]
#        health_bar.gradient.offsets[2] = health_bar_offsets[1]


#func _on_Lights_tree_entered() -> void:
#    lights_path.curve.clear_points()
#    for n in body_segment_max:
#        lights_path.curve.add_point( Vector2.ZERO )

#func _on_Lights_ready():
#    lights_anim.play("Idle")
func _ready() -> void:
    InitCollisionShape()
    
    lights_path.curve.clear_points()
    for n in body_segment_max:
        lights_path.curve.add_point( Vector2.ZERO )

#    $"../HealthUI".clear_points()



func _process( _delta ) -> void:

#    if Global.cfg.always_show_health_bar: health_bar.visible = true
#    else:
#        health_bar.visible = $AnimationPlayer/Hit.current_animation == "Hit"

#    $Lights.visible = !Global.cfg.optimal_graphic


#    $"../UI/LowHealthOverlay".modulate.a = remap(
#        Global.health, 50.0, 0.0, 0.0, 1.0 )
#    $"../UI/LowHealthOverlay".modulate.a = clamp(
#        $"../UI/LowHealthOverlay".modulate.a, 0, 1 )
#    $"../UI/LowHealthOverlay/AnimationPlayer".playback_speed = remap(
#        Global.health, 50.0, 0.0, 0.8, 1.5 )


    if head.moving or head.attacking:
#        UpdateWormLength()
        UpdateCollisionShape()
        UpdateLightPath()
#	UpdateHealthUI()

func _physics_process( _delta ) -> void:

    if get_point_count() > body_segment_max:
        if head.moving_f > 0 or head.attacking:
            remove_point( 0 )
    else:
        if head.moving_f > 0 or head.attacking:
            add_point( head.position )

func _on_Hit_animation_started( anim_name ) -> void:
    if anim_name == "Hit": head.invincible = true
#        print("Hit started")
#        health_bar.visible = true
#        health_bar.modulate.a = 1.0

func _on_Hit_animation_finished( anim_name ) -> void:
    if anim_name == "Hit":
#        print("Hit finished")
        head.invincible = false
#        $AnimationPlayer/Hit.play("FadeOutHealthBar")

    if anim_name == "FadeOutHealthBar":
#        health_bar.visible = false
        pass
