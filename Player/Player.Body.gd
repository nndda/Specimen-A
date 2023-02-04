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

func _process(_delta):
	if get_point_count() > glbl.worm_segment_max:
		if glbl.moving:
			remove_point(0)
	else:
		if glbl.moving:
			add_point($"../Head".position)
	UpdateWormLength()
