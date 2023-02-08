extends Polygon2D

# apology for this absolute abomination of a script, ill try to clean n optimize it 

# create a sprite, convert to polygon2d, n then attach this script

enum SkewDirection {RIGHT, DOWN, LEFT, UP}
export(SkewDirection) var direction = SkewDirection.UP

func get_direction(id) -> Vector2:
	return Vector2(
		cos( range_lerp(float(id),0,4,0,TAU) ),
		sin( range_lerp(float(id),0,4,0,TAU) )
	)

onready var top_scale = glbl.top_scale

func get_canvas_pos() -> Vector2:
	return ( ( get_global_transform_with_canvas().origin * 2 ) / get_viewport_rect().size ) - Vector2(1.0,1.0)

func _process(_delta):

		match direction:


			SkewDirection.UP:
	#===================================================================================================
	#			UP											# 0,	-1
				#Bottom-Right
				polygon[0] = (
					( position + ( texture.get_size() / 2.0 ) )
					+
					Vector2( 0, -texture.get_height() )
					+
					( get_canvas_pos() * texture.get_size() ) + ( get_canvas_pos() * glbl.top_scale )
					)
				# Bottom-Left
				polygon[1] = (
					( position + ( Vector2( -texture.get_width(), texture.get_height() ) / 2.0) )
					+
					Vector2( 0, -texture.get_height() )
					+
					( get_canvas_pos() * texture.get_size() ) + ( get_canvas_pos() * glbl.top_scale )
					)




			SkewDirection.DOWN:
	#===================================================================================================
	#			DOWN											# 0,	1
				# Top-Left
				polygon[2] = (
					( position + ( texture.get_size() / -2.0 ) )
					+
					Vector2( 0, texture.get_height() )
					+
					( get_canvas_pos() * texture.get_size() ) + ( get_canvas_pos() * glbl.top_scale )
					)
				#Top-Right
				polygon[3] = (
					( position + ( Vector2( texture.get_width(), -texture.get_height() ) / 2.0 ) )
					+
					Vector2( 0, texture.get_height() )
					+
					( get_canvas_pos() * texture.get_size() ) + ( get_canvas_pos() * glbl.top_scale )
					)



			SkewDirection.LEFT:
	#===================================================================================================
	#			LEFT										# -1, 0
				#Bottom-Right
				polygon[0] = (
					( position + ( texture.get_size() / 2.0 ) )
					+
					Vector2( -texture.get_width(), 0 )
					+
					( get_canvas_pos() * texture.get_size() ) + ( get_canvas_pos() * glbl.top_scale )
					)
				#Top-Right
				polygon[3] = (
					( position + ( Vector2( texture.get_width(), -texture.get_height() ) / 2.0 ) )
					+
					Vector2( -texture.get_width(), 0 )
					+
					( get_canvas_pos() * texture.get_size() ) + ( get_canvas_pos() * glbl.top_scale )
					)



			SkewDirection.RIGHT:
	#===================================================================================================
	#			RIGHT										# 1, 0
				# Bottom-Left
				polygon[1] = (
					( position + ( Vector2( -texture.get_width(), texture.get_height() ) / 2.0) )
					+
					Vector2( texture.get_width(), 0 )
					+
					( get_canvas_pos() * texture.get_size() ) + ( get_canvas_pos() * glbl.top_scale )
					)
				# Top-Left
				polygon[2] = (
					( position + ( texture.get_size() / -2.0 ) )
					+
					Vector2( texture.get_width(), 0 )
					+
					( get_canvas_pos() * texture.get_size() ) + ( get_canvas_pos() * glbl.top_scale )
					)
