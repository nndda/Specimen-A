extends Line2D


func UpdateWormLength() -> void:
	var sgmnt_count = get_point_count()
	for sgmnt in sgmnt_count - 1:
		if glbl.worm_length_array.size() <= sgmnt:
			glbl.worm_length_array.append( 
				points[sgmnt].distance_to( points[ wrapi( sgmnt, 0, sgmnt_count ) + 1 ] )
			)
		else:
			glbl.worm_length_array[ sgmnt ] = (
				points[sgmnt].distance_to( points[ wrapi( sgmnt, 0, sgmnt_count ) + 1 ] )
			)

func UpdateLightPath() -> void:
	for n in get_point_count() - 1 :
		$Lights.curve.set_point_position(
			(get_point_count() - 2) - n,
			points[n] )

var health_bar_offsets : PoolRealArray = PoolRealArray([
	0.02,0.04 ])
onready var health_bar = $"../HealthUI"
func UpdateHealthUI() -> void:
	if health_bar.visible:
		health_bar_offsets[0] = range_lerp(glbl.health,100.0,0.0,0.02,0.96)
		health_bar_offsets[1] = range_lerp(glbl.health,100.0,0.0,0.04,0.98)

		health_bar_offsets[0] = clamp(health_bar_offsets[0],0.02,0.96)
		health_bar_offsets[1] = clamp(health_bar_offsets[1],0.04,0.98)

		for n in ( get_point_count() - 1 ):
			if health_bar.get_point_count() <= n:
				health_bar.add_point(points[n])
			else:
				health_bar.points[n] = points[n]

		health_bar.gradient.offsets[1] = health_bar_offsets[0]
		health_bar.gradient.offsets[2] = health_bar_offsets[1]

#	health_bar.width_curve.set_point_value(1,
#		range_lerp(glbl.health,0,100,0.0,0.5)
#		)
#	health_bar.width_curve.set_point_value(2,
#		range_lerp(glbl.health,0,100,0.0,0.75)
#		)
#	health_bar.width_curve.set_point_value(3,
#		range_lerp(glbl.health,0,100,0.0,1.0)
#		)
#	health_bar.width_curve.set_point_value(4,
#		range_lerp(glbl.health,0,100,0.0,1.0)
#		)

#func ri() -> String:
#	return str(randi() % 9)

func _ready():
	$"../HealthUI".clear_points()
	$Lights.curve.clear_points()
	for n in glbl.worm_segment_max:
		$Lights.curve.add_point(Vector2(0,0))
	
#	for n in 20:
#		print(str(n*5) + "%    {content: \"Log Start: " + ri() + ri() + "/" + ri() + ri() + "/" + ri() + ri() + ri() + ri() + "\";}")

func _process(_delta):
	if get_point_count() > glbl.worm_segment_max:
		if glbl.moving_f > 0:
			remove_point(0)
	else:
		if glbl.moving_f > 0:
			add_point($"../Head".position)
	UpdateWormLength()
	UpdateLightPath()
	UpdateHealthUI()
