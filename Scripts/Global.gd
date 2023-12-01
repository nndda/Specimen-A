extends Node2D

var enemy_exception_bodies : Array[ PhysicsBody2D ]
var current_scene : Node

var layer : Array[String] = [
    "Objects/Corpses",
    "Objects/Particles",
    "Objects/Statics",
    "Objects",
    "Entities" ]
var layer_dict : Dictionary = {}
func update_layers() -> void:
    layer_dict.clear()
    for itm in layer:
        layer_dict[ itm ] = current_scene.get_node( itm )

var current_objects     : Array
var top_scale           : float = 1.1

var player              : Node2D

#var allow_move          : bool = true
var moving              : bool
var moving_f            : float

var attacking           : bool

var head_pos            : Vector2
var head_canvas_pos     : Vector2

var worm_segment_max    : int = 34
var worm_length         : float
var worm_length_array   : Array[float]

var worm_body           : Object

var health              : float = 100.0

var player_physics_head : CharacterBody2D
var player_physics_body : Area2D

signal camera_shaken_by_player

var skill_current       : int = skill.none

enum skill {
    none,
    DischargeShrapnel,
    EMPBurst,
    SynthesizeAcids,
}
var skills_discovered   : int = 4 # Dbg purpose

var shrapnel_current    : int = 0
var emp_charge          : int = 0
var acid                : int = 0

func sum_array( array : PackedFloat32Array ) -> float:
    var t : float = 0.0
    for n in array: t += n
    return t

#   CONFIG
var cfg = {
    always_show_health_bar = false,
    optimal_graphic = false,
    show_damage = true,

    master = 50,
    sfx = 50,
    bgm = 50,
    }

func _enter_tree():
    init_tile_sets()

func _process( _delta ) -> void:

    health = clamp( health, 0.0, 100.0 )

#    if player != null:
#        if player.allow_move: moving = true if (
#            Input.is_action_pressed( "Move" )
#            ) else false
#        else: moving = false
#
#    if moving: moving_f += 0.1
#    else: moving_f -= 0.085
#
#    moving_f = clamp( moving_f, 0.0,
#    float( head_pos.distance_to(
#        get_global_mouse_position() ) >= 25 ) )

#    worm_length = sum_array( worm_length_array )

var tilemap_depth : int = 8
var tile_set : TileSet = preload("res://Worlds/Tilesets/Tileset.map.tres")

func init_tile_sets() -> void:
    var user_tile_res : Callable = func(n, m):\
        return "user://Tileset.map." + str(m) + "-" + str(n) + ".res"

    for n in tilemap_depth:
        DirAccess.remove_absolute( user_tile_res.call(n, 1) )
        ResourceSaver.save( tile_set, user_tile_res.call(n, 1) )

        if n < tilemap_depth - 2:
            DirAccess.remove_absolute( user_tile_res.call(n, 2) )
            ResourceSaver.save( tile_set, user_tile_res.call(n, 2) )

            if n == tilemap_depth - 3:
                DirAccess.remove_absolute( user_tile_res.call(n, 3) )
                ResourceSaver.save( tile_set, user_tile_res.call(n, 3) )
