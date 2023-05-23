extends Line2D

@onready var damage_area : Object = $"../DamageCollision"
func InitCollisionShape() -> void:
    for sgmnt in get_point_count() - 2:
        var shape_node		: CollisionShape2D = CollisionShape2D.new()
        var shape			: SegmentShape2D = SegmentShape2D.new()

        shape.a				= points[ sgmnt ]
        shape.b				= points[ sgmnt + 1 ]

        shape_node.shape	= shape
        damage_area.add_child( shape_node )

func UpdateCollisionShape() -> void:
    if glbl.moving or $"../Head".attacking:
        for sgmnt in glbl.worm_segment_max - 2:
            damage_area.get_child( sgmnt ).shape.a = points[ sgmnt ]
            damage_area.get_child( sgmnt ).shape.b = points[ sgmnt + 1 ]


func UpdateWormLength() -> void:
    var sgmnt_count : int = get_point_count()
    for sgmnt in sgmnt_count - 1:
        if glbl.worm_length_array.size() <= sgmnt:
            glbl.worm_length_array.append(
            points[ sgmnt ].distance_to(
            points[ wrapi( sgmnt, 0, sgmnt_count ) + 1 ] )
            )
        else:
            glbl.worm_length_array[ sgmnt ] = (
            points[ sgmnt ].distance_to(
            points[ wrapi( sgmnt, 0, sgmnt_count ) + 1 ] )
            )


func UpdateLightPath() -> void: if $Lights.visible:
    for n in get_point_count() - 1 :
        $Lights.curve.set_point_position(
        ( get_point_count() - 2) - n, points[ n ] )
    if glbl.moving and !$Lights/AnimationPlayer.is_playing():
        $Lights/AnimationPlayer.play( "Idle" )

var health_bar_offsets : PackedFloat32Array = [ 0.02, 0.04 ]

#@onready var health_bar = $"../HealthUI"
#@onready var health_bar = $"../HealthUIS"
@onready var health_bar : Object
func UpdateHealthUI() -> void: if health_bar.visible:

#		health_bar_offsets[0] = range_lerp(glbl.health,100.0,0.0,0.02,0.96)
#		health_bar_offsets[1] = range_lerp(glbl.health,100.0,0.0,0.04,0.98)

#		health_bar_offsets[0] = clamp(health_bar_offsets[0],0.02,0.96)
#		health_bar_offsets[1] = clamp(health_bar_offsets[1],0.04,0.98)

        for n in ( get_point_count() ):
            if health_bar.get_point_count() <= n:
                    health_bar.add_point( points[ n ] )
            else: 	health_bar.points[ n ] = points[ n ]

#		health_bar.gradient.offsets[1] = health_bar_offsets[0]
#		health_bar.gradient.offsets[2] = health_bar_offsets[1]


func _on_Lights_tree_entered() -> void:
    $Lights.curve.clear_points()
    for n in glbl.worm_segment_max:
        $Lights.curve.add_point( Vector2.ZERO )
#func _on_Lights_ready():
#	$Lights/AnimationPlayer.play("Idle")
func _ready() -> void: InitCollisionShape()
#	$"../HealthUI".clear_points()



func _process( _delta ) -> void:

    if glbl.cfg.always_show_health_bar: health_bar.visible = true
#	else:
#		health_bar.visible = $AnimationPlayer/Hit.current_animation == "Hit"

    $Lights.visible = !glbl.cfg.optimal_graphic


#	$"../UI/LowHealthOverlay".modulate.a = remap(
#		glbl.health, 50.0, 0.0, 0.0, 1.0 )
#	$"../UI/LowHealthOverlay".modulate.a = clamp(
#		$"../UI/LowHealthOverlay".modulate.a, 0, 1 )
#	$"../UI/LowHealthOverlay/AnimationPlayer".playback_speed = remap(
#		glbl.health, 50.0, 0.0, 0.8, 1.5 )


    UpdateWormLength()
    UpdateCollisionShape()
    UpdateLightPath()
#	UpdateHealthUI()

func _physics_process( _delta ) -> void:

    if get_point_count() > glbl.worm_segment_max:
        if glbl.moving_f > 0 or $"../Head".attacking:
            remove_point( 0 )
    else:
        if glbl.moving_f > 0 or $"../Head".attacking:
            add_point( $"../Head".position )

func _on_Hit_animation_started( anim_name ) -> void:
    if anim_name == "Hit": $"../Head".invincible = true
#		print("Hit started")
#		health_bar.visible = true
#		health_bar.modulate.a = 1.0

func _on_Hit_animation_finished( anim_name ) -> void:
    if anim_name == "Hit":
#		print("Hit finished")
        $"../Head".invincible = false
#		$AnimationPlayer/Hit.play("FadeOutHealthBar")

    if anim_name == "FadeOutHealthBar":
#		health_bar.visible = false
        pass






