extends Node2D

@export_node_path("TileMap") var map : NodePath
@export_node_path("TileMap") var map_decor : NodePath
@export_node_path("TileMap") var map_decor_light : NodePath

@export_node_path("CanvasLayer") var top_layer : NodePath
@export_node_path("CanvasLayer") var top_layer_2 : NodePath

const depth : int = 6
@onready var max_scale : float = Global.top_scale

const tileset := preload("res://Worlds/Tilesets/Tileset.map.tres")
var tilesets_copy : PackedStringArray = []
var tilesets_generated := !Global.tile_maps.is_empty()

const global_modulate := preload("res://Worlds/GlobalModulate.tscn")

func user_tile_res(n : int, m : int) -> String:
    return "user://Tileset.map." + str(m) + "-" + str(n) + ".res"

func _enter_tree():
    get_parent().ready.connect(init_tile_sets)

func init_tile_sets() -> void:
    if !tilesets_generated:
        for n in depth:
            tilesets_copy.append(user_tile_res(n, 1))
            if n < depth - 2:
                tilesets_copy.append(user_tile_res(n, 2))
                if n == depth - 3:
                    tilesets_copy.append(user_tile_res(n, 3))

        for res in tilesets_copy:
            ResourceSaver.save(tileset, res)
            Global.tile_maps[res] = ResourceLoader.load(res, "TileSet")
            #Global.tile_maps[res] = load(res)

    call_deferred(&"generate_layers")

signal layers_generated

func generate_layers() -> void:

    for t in [top_layer, top_layer_2]:
        var n := get_node(t)
        n.call_deferred(&"add_child", global_modulate.instantiate())
        n.follow_viewport_scale = max_scale
        n.follow_viewport_enabled = true
        n.visible = true

    get_node(top_layer_2).follow_viewport_scale = max_scale + 0.15

    for n in depth:
        var layer := CanvasLayer.new()
        var map_layer := get_node(map).duplicate()
        var map_tile_set : TileSet = Global.tile_maps[user_tile_res(n, 1)]

        layer.name = StringName(str(n))
        layer.layer = 0
        layer.follow_viewport_enabled = true
        layer.follow_viewport_scale = remap(n, 0, depth - 1, 1.0, max_scale)

        map_layer.modulate = Color.WHITE

        if !tilesets_generated:
            map_tile_set.remove_navigation_layer(0)
            if n != 0:
                map_tile_set.remove_physics_layer(0)
            if n == depth - 1:
                map_tile_set.set_occlusion_layer_light_mask(0, 1)
            else:
                map_tile_set.remove_occlusion_layer(0)

        map_layer.tile_set = map_tile_set
        layer.call_deferred(&"add_child", map_layer)
        layer.call_deferred(&"add_child", global_modulate.instantiate())

        if n < depth - 2:
            var map_decor_layer := get_node(map_decor).duplicate()

            map_decor_layer.tile_set = Global.tile_maps[user_tile_res(n, 2)]
            layer.call_deferred(&"add_child", map_decor_layer)

            if n == depth - 3: # Tileset level lights
                var map_decor_light_layer := get_node(map_decor_light).duplicate()

                map_decor_light_layer.tile_set = Global.tile_maps[user_tile_res(n, 3)]
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
