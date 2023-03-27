extends Node2D

@export_node_path("Node2D")				var pseudo_3d_generator
@export_node_path("LightOccluder2D")	var global_occluder
@export_node_path("StaticBody2D")		var global_wall

func _enter_tree():
	glbl.current_scene = self

func _ready():

	add_child( preload( "res://Worlds/GlobalModulate.tscn" ).instantiate() )
	glbl.update_layers()

	for layer in glbl.layer:

		dbg.print_header( self, layer )

		for inst in self.get_node(layer).get_children():
			if inst is InstancePlaceholder:
				printt("|", str(Time.get_datetime_string_from_system(false,true)," Instancing: " + str(inst)))
				inst.create_instance()
		print()

	for layer in glbl.layer:
		for inst in self.get_node(layer).get_children():
			if inst is Node2D:
				if ![	"Lights",		"Corpses",
						"Particles",	"Statics",
						"Destructibles"
					].has( inst.get_name() ):
					glbl.current_objects.append( inst )

	cam.InitVisualLoading()

	get_node(pseudo_3d_generator).GenerateLayers()

	var \
	global_occluder_polygon				= OccluderPolygon2D.new()
	global_occluder_polygon.polygon		= get_node(global_wall).get_child(0).polygon
	get_node(global_occluder).occluder	= global_occluder_polygon

