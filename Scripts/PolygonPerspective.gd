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

var points_nodes : Array
var points_init : PoolVector2Array

onready var top_scale = glbl.top_scale

func _ready():
	for n in 3:
		var point = Position2D.new()
		match n:
			0:
				point.position = texture.get_size() / 2.0
			1:
				point.position = Vector2(-texture.get_width(),texture.get_height()) / 2.0
			2: 
				point.position = texture.get_size() / -2.0
			3:
				point.position = Vector2(texture.get_width(),-texture.get_height()) / -2.0
		add_child(point)
		points_nodes.append(point)

	for p in get_children():
		points_init.append( p.position )

func update_skew() -> void:
	for p in get_child_count():
		polygon[p] = get_child(p).position

func _process(_delta):

	match direction:



		SkewDirection.UP:
#===================================================================================================
#			UP											# 0,	-1
			points_nodes[0].global_position = ( (
				( get_viewport_transform().origin - ( get_viewport_rect().size / 2 ) ) / (top_scale*4)
				) +
					(
					points_init[0]							# 16,	16
					+ Vector2(0,-points_init[0].y) * 2		# 0,	-32
					) * top_scale
				)
			points_nodes[1].global_position = ( (
				( get_viewport_transform().origin - ( get_viewport_rect().size / 2 ) ) / (top_scale*4)
				) +
					(
					points_init[1]							# -16,	16
					+ Vector2(0,-points_init[1].y) * 2		# 0,	-32
					) * top_scale
				)



		SkewDirection.DOWN:
#===================================================================================================
#			DOWN											# 0,	1
			points_nodes[2].global_position = ( (
				( get_viewport_transform().origin - ( get_viewport_rect().size / 2 ) ) / (top_scale*4)
				) +
					(
					points_init[2]							# -16,	-16
					+ Vector2(0,-points_init[2].y) * 2		# 0,	-32
					) * top_scale
				)
			points_nodes[3].global_position = ( (
				( get_viewport_transform().origin - ( get_viewport_rect().size / 2 ) ) / (top_scale*4)
				) +
					(
					points_init[3]							# 16,	-16
					+ Vector2(0,-points_init[3].y) * 2		# 0,	-32
					) * top_scale
				)



		SkewDirection.LEFT:
#===================================================================================================
#			LEFT										# -1, 0
			points_nodes[0].global_position = ( (
				( get_viewport_transform().origin - ( get_viewport_rect().size / 2 ) ) / (top_scale*4)
				) +
					(
					points_init[0]						# 16, 16
					+ Vector2(-points_init[0].x,0) * 2	# -32, 0
					) * top_scale
				)
			points_nodes[3].global_position = ( (
				( get_viewport_transform().origin - ( get_viewport_rect().size / 2 ) ) / (top_scale*4)
				) +
					(
					points_init[3]						# 16, -16
					+ Vector2(-points_init[3].x,0) * 2	# -32, 0
					) * top_scale
				)



		SkewDirection.RIGHT:
#===================================================================================================
#			RIGHT										# 1, 0
			points_nodes[1].global_position = ( (
				( get_viewport_transform().origin - ( get_viewport_rect().size / 2 ) ) / (top_scale*4)
				) +
					(
					points_init[1]						# -16, -16
					+ Vector2(-points_init[1].x,0) * 2	# 0, -32
					) * top_scale
				)
			points_nodes[2].global_position = ( (
				( get_viewport_transform().origin - ( get_viewport_rect().size / 2 ) ) / (top_scale*4)
				) +
					(
					points_init[2]						# 16, -16
					+ Vector2(-points_init[2].x,0) * 2	# 0, -32
					) * top_scale
				)



	update_skew()
