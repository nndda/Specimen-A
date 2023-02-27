extends Node

export(NodePath)	var map
export(NodePath)	var map_decor
export(NodePath)	var map_decor_light
export(int, 8)		var depth	 # 5

onready var max_scale = glbl.top_scale

func GenerateLayers() -> void:
	for n in depth:
		var layer						= CanvasLayer.new()
		var map_layer					= get_node(map).duplicate()

		layer.layer						= -1
		layer.follow_viewport_enable	= true
		layer.follow_viewport_scale		= range_lerp( n, 0, depth-1, 1.0, max_scale )

		map_layer.collision_layer		= get_node(map).collision_layer if n == 0 else 0
		map_layer.collision_mask		= get_node(map).collision_mask if n == 0 else 0
		map_layer.navigation_layers		= 0
		map_layer.occluder_light_mask	= 0# if n < depth - 1 else 1


		layer.call_deferred( "add_child", map_layer)
		layer.call_deferred( "add_child", load("res://Worlds/GlobalModulate.tscn").instance())

		if n < depth - 2:

			var map_decor_layer					= get_node(map_decor).duplicate()
			map_decor_layer.collision_layer		= get_node(map_decor).collision_layer if n == 0 else 0
			map_decor_layer.collision_mask		= get_node(map_decor).collision_mask if n == 0 else 0
			map_decor_layer.navigation_layers	= 0
			map_decor_layer.occluder_light_mask	= 0# if n < depth - 1 else 1

			layer.call_deferred( "add_child", map_decor_layer)

			if n == depth - 3:
				var map_decor_light_layer					= get_node(map_decor_light).duplicate()
				map_decor_light_layer.collision_layer		= get_node(map_decor_light).collision_layer if n == 0 else 0
				map_decor_light_layer.collision_mask		= get_node(map_decor_light).collision_mask if n == 0 else 0
				map_decor_light_layer.navigation_layers		= 0
				map_decor_light_layer.occluder_light_mask	= 0# if n < depth - 1 else 1
				layer.call_deferred( "add_child", map_decor_light_layer)
#				map_decor_layer.material		= load("res://Shaders/Materials/Add.CanvasItemMaterial.tres")


		call_deferred( "add_child", layer)
	get_node(map).queue_free()
#	get_node(map_decor).queue_free()
	get_node(map_decor_light).queue_free()
