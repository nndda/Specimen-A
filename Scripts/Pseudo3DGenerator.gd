extends Node2D

@export_node_path("TileMap") var map : NodePath
@export_node_path("TileMap") var map_decor : NodePath
@export_node_path("TileMap") var map_decor_light : NodePath
@onready var depth : int = 6

@export_node_path("CanvasLayer") var top_layer : NodePath
@export_node_path("CanvasLayer") var top_layer_2 : NodePath

@onready var max_scale : float = Global.top_scale

var tileset : TileSet = preload("res://Worlds/Tilesets/Tileset.map.tres")
var tilesets_copy : PackedStringArray = []
var user_tile_res := func(n, m):\
    return "user://Tileset.map." + str(m) + "-" + str(n) + ".res"

func init_tile_sets() -> void:
    for n in depth:
        tilesets_copy.append(user_tile_res.call(n, 1))
        if n < depth - 2:
            tilesets_copy.append(user_tile_res.call(n, 2))
            if n == depth - 3:
                tilesets_copy.append(user_tile_res.call(n, 3))

    for res in tilesets_copy:
        #if !FileAccess.file_exists(res):
            DirAccess.remove_absolute(res)
            ResourceSaver.save(tileset, res)
        #elif ResourceLoader.load(res) == tileset:
            #DirAccess.remove_absolute(res)
            #ResourceSaver.save(tileset, res)

signal layers_generated

func generate_layers() -> void:
    init_tile_sets()

    for t in [top_layer, top_layer_2]:
        get_node(t).add_child(preload("res://Worlds/GlobalModulate.tscn").instantiate())
        get_node(t).follow_viewport_scale = max_scale
        get_node(t).follow_viewport_enabled = true
        get_node(t).show()
    get_node(top_layer_2).follow_viewport_scale = max_scale + 0.15

    for n in depth:

        var layer := CanvasLayer.new()
        var map_layer := get_node(map).duplicate()

        layer.name = StringName(str(n))
        layer.layer = 0
        layer.follow_viewport_enabled = true
        layer.follow_viewport_scale = remap(n, 0, depth - 1, 1.0, max_scale)

        map_layer.tile_set = load("user://Tileset.map.1-" + str(n) + ".res")
        map_layer.modulate = Color.WHITE

        map_layer.tile_set.set_physics_layer_collision_layer(0, int(n != 0))
        map_layer.tile_set.set_physics_layer_collision_mask(0, int(n != 0))
        if n == 0: map_layer.tile_set.remove_physics_layer(0)

        map_layer.tile_set.set_occlusion_layer_light_mask(0, 0)
        if n != 0:
            map_layer.tile_set.remove_occlusion_layer(0)
        elif n == 0:
            map_layer.tile_set.set_occlusion_layer_light_mask(0, 32)

        map_layer.tile_set.set_navigation_layer_layers(0, int(n == 0))
        if n != 0: map_layer.tile_set.remove_navigation_layer(0)

        layer.call_deferred(&"add_child", map_layer)
        layer.call_deferred(&"add_child", load("res://Worlds/GlobalModulate.tscn").instantiate())


        if n < depth - 2:
            var\
            map_decor_layer := get_node(map_decor).duplicate()
            map_decor_layer.tile_set = load("user://Tileset.map.2-" + str(n) + ".res")

            map_decor_layer.tile_set.set_physics_layer_collision_layer(0, int(n == 0))
            map_decor_layer.tile_set.set_physics_layer_collision_mask(0, int(n == 0))
            if n != 0: map_decor_layer.tile_set.remove_physics_layer(0)

            map_decor_layer.tile_set.set_occlusion_layer_light_mask(0, int(n == 0))
            if n != 0: map_decor_layer.tile_set.remove_occlusion_layer(0)

            layer.call_deferred(&"add_child", map_decor_layer)

            if n == depth - 3:
                var\
                map_decor_light_layer := get_node(map_decor_light).duplicate()
                map_decor_light_layer.tile_set = load("user://Tileset.map.3-" + str(n) + ".res")

                layer.call_deferred(&"add_child", map_decor_light_layer)

        call_deferred(&"add_child", layer)

    for tilemap in (
        get_node(top_layer).get_children() +
        get_node(top_layer_2).get_children() +
        [$"../TopLayer/Tile/Tile"]
       ):
        if tilemap is TileMap:
            tilemap.modulate = Color("#070101")
            for layer in [
                "physics_layer",
                "navigation_layer",
                "occlusion_layer",
            ]:
                if tilemap.tile_set.call(StringName("get_" + layer + "s_count")) >= 1:
                    tilemap.tile_set.call(StringName("remove_" + layer), 0)

    for f in [map, map_decor, map_decor_light]:
        get_node(f).queue_free()

    layers_generated.emit()
