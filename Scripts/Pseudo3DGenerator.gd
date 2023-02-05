extends Node

export(NodePath)	var map
export(int, 8)		var depth
export(float, 0, 2)	var max_scale = 1.2

func GenerateLayers() -> void:
	for n in depth:

		var layer						= CanvasLayer.new()
		var map_layer					= get_node(map).duplicate()

		layer.layer						= 0
		layer.follow_viewport_enable	= true
		layer.follow_viewport_scale		= range_lerp( n, 0, 8, 1.0, max_scale )

		map_layer.collision_layer		= 0
		map_layer.collision_mask		= 0
		map_layer.navigation_layers		= 0
		map_layer.occluder_light_mask	= 0

		layer.call_deferred( "add_child", map_layer)
		layer.call_deferred( "add_child", load("res://Worlds/GlobalModulate.tscn").instance())
		call_deferred( "add_child", layer)
