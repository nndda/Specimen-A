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

func _ready():
	$Lights.curve.clear_points()
	for n in glbl.worm_segment_max:
		$Lights.curve.add_point(Vector2(0,0))

func _process(_delta):
	if get_point_count() > glbl.worm_segment_max:
		if glbl.moving_f > 0:
			remove_point(0)
	else:
		if glbl.moving_f > 0:
			add_point($"../Head".position)
	UpdateWormLength()
	UpdateLightPath()
