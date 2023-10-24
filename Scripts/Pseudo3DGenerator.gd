extends Node2D

@export_node_path( "TileMap" )  var map : NodePath
@export_node_path( "TileMap" )  var map_decor : NodePath
@export_node_path( "TileMap" )  var map_decor_light : NodePath
@export_range( 1, 12 )          var depth : int = 8

@export_node_path("CanvasLayer") var top_layer : NodePath

@onready var max_scale : float = Global.top_scale

#@onready var tile_set : TileSet = preload( "res://Worlds/Tilesets/Tileset.map.tres" )

signal layers_generated

func duplicate_tileset( target : TileMap, copy : TileMap ) -> void: target.\
    call_deferred( "set_tileset", copy.tile_set.\
    call_deferred( "duplicate", true ) )

func generate_layers() -> void:

    get_node( top_layer ).add_child( preload( "res://Worlds/GlobalModulate.tscn" ).instantiate() )
    get_node( top_layer ).follow_viewport_scale = max_scale
    get_node( top_layer ).follow_viewport_enabled = true
    get_node( top_layer ).show()

    for n in depth:

        var layer       : CanvasLayer   = CanvasLayer.new()
        var map_layer   : TileMap       = get_node( map ).duplicate()

        layer.name                      = str( n )
        layer.layer                     = 0
        layer.follow_viewport_enabled   = true
        layer.follow_viewport_scale     = remap( n, 0, depth - 1, 1.0, max_scale )

#        map_layer.tile_set = tile_set
        map_layer.tile_set              = get_node( map ).tile_set.duplicate( true )
#        call_deferred( "duplicate_tileset", map_layer, get_node( map ) )
        map_layer.modulate              = Color.WHITE

#        if n != 0:
#            map_layer.tile_set.set_physics_layer_collision_layer( 0, 0 )
#            map_layer.tile_set.set_physics_layer_collision_mask( 0, 0 )
#        else:
#            map_layer.tile_set.set_physics_layer_collision_layer( 0, 1 )
#            map_layer.tile_set.set_physics_layer_collision_mask( 0, 1 )

        map_layer.tile_set.set_physics_layer_collision_layer( 0, int( bool( n ) ) )
        map_layer.tile_set.set_physics_layer_collision_mask( 0, int( bool( n ) ) )

        map_layer.tile_set.set_occlusion_layer_light_mask( 0, 0 )

        layer.call_deferred( "add_child", map_layer )
        layer.call_deferred( "add_child", load( "res://Worlds/GlobalModulate.tscn" ).instantiate())


        if n < depth - 2:
            var map_decor_layer : TileMap   = get_node( map_decor ).duplicate()
#            map_decor_layer.tile_set = tile_set
            map_decor_layer.tile_set        = get_node( map_decor ).tile_set.duplicate( true )
#            call_deferred( "duplicate_tileset", map_decor, get_node( map_decor ) )

            if n == 0:
                map_decor_layer.tile_set.set_physics_layer_collision_layer( 0, 1 )
                map_decor_layer.tile_set.set_physics_layer_collision_mask( 0, 1 )
                map_decor_layer.tile_set.set_occlusion_layer_light_mask( 0, 1 )
            else:
                map_decor_layer.tile_set.set_physics_layer_collision_layer( 0, 0 )
                map_decor_layer.tile_set.set_physics_layer_collision_mask( 0, 0 )
                map_decor_layer.tile_set.set_occlusion_layer_light_mask( 0, 0 )

            layer.call_deferred( "add_child", map_decor_layer )

            if n == depth - 3:
                var map_decor_light_layer : TileMap = get_node( map_decor_light ).duplicate()

#                map_decor_light_layer.tile_set = tile_set
                map_decor_light_layer.tile_set = get_node( map_decor_light ).tile_set.duplicate( true )
#                call_deferred( "duplicate_tileset", map_decor_light_layer, get_node( map_decor_light ) )

                layer.call_deferred( "add_child", map_decor_light_layer )
                map_decor_layer.material = load("res://Shaders/Materials/Add.CanvasItemMaterial.tres")

        call_deferred( "add_child", layer )

    var map_top_layer : TileMap = get_node( map ).duplicate()

#    map_top_layer.tile_set.add_occlusion_layer( 1 )

    map_top_layer.tile_set.set_occlusion_layer_light_mask( 0, 1 )
    map_top_layer.tile_set.set_physics_layer_collision_layer( 0, 0 )
    map_top_layer.tile_set.set_physics_layer_collision_mask( 0, 0 )

    for tilemap in get_node( top_layer ).get_children():
        if tilemap is TileMap: tilemap.modulate = Color( "#070101" )

    get_node( top_layer ).call_deferred( "add_child", map_top_layer )

    for f in [ map, map_decor, map_decor_light ]: get_node( f ).queue_free()

    emit_signal("layers_generated")
