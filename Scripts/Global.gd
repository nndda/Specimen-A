extends Node2D

var enemy_exception_bodies : Array[PhysicsBody2D]
var current_scene : Node

var layer : Array[String] = [
    "Objects/Corpses",
    "Objects/Particles",
    "Objects/Statics",
    "Objects",
    "Entities",
    ]
var layer_dict : Dictionary = {}
func update_layers() -> void:
    layer_dict.clear()
    for itm in layer:
        layer_dict[ itm ] = current_scene.get_node(itm)

var current_objects     : Array
var top_scale           : float = 1.1

var player              : Node2D

#var allow_move          : bool = true
var moving              : bool
var moving_f            : float

var attacking           : bool

var moving_or_attacking    : bool

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


var user_data := {
    "level_unlocked" : 0,
    "achievements" : {

    },

#   CONFIG
    "config" : {
        #"always_show_health_bar" : false,
        "optimal_graphic" : false,
        "fullscreen" : false,
        "resolution_idx" : 0,
        #"show_damage" : false,

        "brightness" : 80,
        "contrast" : 80,

        "master" : 50,
        "sfx" : 50,
        "bgm" : 50,
        },
    }
var user_data_default : Dictionary
const user_data_path := "user://user_data"
func update_user_data() -> void:
    var new_data := FileAccess.open(user_data_path, FileAccess.WRITE_READ)
    new_data.store_buffer(var_to_bytes(user_data))
    new_data.close()

func load_user_data() -> void:
    if !FileAccess.file_exists(user_data_path):
        update_user_data()
    else:
        var data = bytes_to_var(FileAccess.get_file_as_bytes(user_data_path))
        if data is Dictionary:
            if data.keys() == user_data.keys():
                user_data = data
        data = null

func _enter_tree():
    user_data_default = user_data.duplicate(true)
    load_user_data()

func _process( _delta ) -> void:

    health = clamp( health, 0.0, 100.0 )

    #moving_or_attacking = moving or attacking

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
