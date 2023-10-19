extends Node2D

@export_node_path("Node2D") var pseudo_3d_generator : NodePath

func _enter_tree() -> void: glbl.current_scene = self

func _ready() -> void:
    var t1 : int = Time.get_ticks_msec()
    for c in get_children(): if c is CanvasItem: c.show()
    add_child( preload( "res://Worlds/GlobalModulate.tscn" ).instantiate() )
    glbl.update_layers()

    for layer in glbl.layer:
        dbg.print_header( self, layer )
        for inst in self.get_node(layer).get_children():
            if inst is InstancePlaceholder:
                printt(" Instancing: " + str( inst ) )

                inst.create_instance()
                inst.queue_free()

        print()

    for layer in glbl.layer: for inst in self.get_node( layer ).get_children():
        if inst is CharacterBody2D: glbl.current_objects.append( inst )

    cam.init_visual_loading()

    get_node( pseudo_3d_generator ).generate_layers()

    printt( ">", float( Time.get_ticks_msec() - t1 ) / 1000 )
    printt( ">", Time.get_datetime_string_from_system( false, true ), self )
