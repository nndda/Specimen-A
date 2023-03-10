extends Node2D

#@export_category("TileMap")
@export_node_path("TileMap") var map
@export_node_path("TileMap") var map_decor
@export_node_path("TileMap") var map_decor_light
@export_range(1,12) var depth : int = 8

#@export_category("CanvasLayer")
@export_node_path("CanvasLayer") var top_layer
@export_node_path("CanvasLayer") var bottom_layer

@onready var max_scale = glbl.top_scale

signal layers_generated

func GenerateLayers() -> void:

	get_node(bottom_layer).add_child( preload( "res://Worlds/GlobalModulate.tscn" ).instantiate() )
	get_node(bottom_layer).follow_viewport_enabled = true
	get_node(bottom_layer).follow_viewport_scale = 1

	get_node(top_layer).add_child( preload( "res://Worlds/GlobalModulate.tscn" ).instantiate() )
	get_node(top_layer).follow_viewport_enabled = true
	get_node(top_layer).follow_viewport_scale = max_scale

	for n in depth:

		var layer		: CanvasLayer	= CanvasLayer.new()
		var map_layer	: TileMap		= get_node(map).duplicate()

		layer.layer						= -1
		layer.follow_viewport_enabled	= true
		layer.follow_viewport_scale		= remap( n, 0, depth-1, 1.0, max_scale )

		map_layer.tile_set = map_layer.tile_set.duplicate()
		map_layer.modulate = Color.WHITE

		layer.name = str(n)
		layer.call_deferred( "add_child", map_layer)
		layer.call_deferred( "add_child", load("res://Worlds/GlobalModulate.tscn").instantiate())


		if n < depth - 2:

			var map_decor_layer : TileMap	= get_node(map_decor).duplicate()
			map_decor_layer.tile_set		= map_decor_layer.tile_set.duplicate()

			layer.call_deferred( "add_child", map_decor_layer)

			if n == depth - 3:
				var map_decor_light_layer		: TileMap			= get_node(map_decor_light).duplicate()

				map_decor_light_layer.tile_set = map_decor_light_layer.tile_set.duplicate()

				layer.call_deferred( "add_child", map_decor_light_layer)
#				map_decor_layer.material		= load("res://Shaders/Materials/Add.CanvasItemMaterial.tres")

		call_deferred( "add_child", layer)

	var map_top_layer	: TileMap		= get_node(map).duplicate()
#	map_top_layer.modulate = Color.DARK_RED
	map_top_layer.modulate = Color("#070101")
	get_node(top_layer).call_deferred( "add_child", map_top_layer)
	

	get_node(map).queue_free()
	get_node(map_decor_light).queue_free()
	emit_signal("layers_generated")
