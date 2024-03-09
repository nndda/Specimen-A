extends Node2D

var enemy_exception_bodies : Array[PhysicsBody2D]
var current_scene : Node

const environment := preload("res://Worlds/GlobalEnvironment.tscn")
const canvas_modulate := preload("res://Worlds/GlobalModulate.tscn")

var layer : Array[NodePath] = [
    ^"Objects/Corpses",
    ^"Objects/Particles",
    ]
var layer_dict := {}
func update_layers() -> void:
    layer_dict.clear()
    for itm : NodePath in layer:
        layer_dict[ itm ] = current_scene.get_node(itm)

var current_objects     : Array
var top_scale           : float = 1.1

var player : Node2D

#var allow_move : bool = true
var moving : bool
var moving_f : float

var attacking : bool

var moving_or_attacking : bool

var head_pos            : Vector2
var head_canvas_pos     : Vector2

var worm_segment_max    : int = 34
var worm_length         : float
var worm_length_array   : Array[float]

var worm_body           : Object

var health              : float = 100.0

var player_physics_head : CharacterBody2D
var player_physics_body : Area2D

var player_destroy_through : Area2D

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

func sum_array(array : PackedFloat32Array) -> float:
    var t : float = 0.0
    for n in array: t += n
    return t


var user_data := {
    "level_unlocked" : 0,
    "achievements" : {

    },
#   CONFIG
    "config" : {
        "optimal_graphic" : false,
        "fullscreen" : false,
        "resolution_idx" : 0,
        "brightness" : 1,
        "contrast" : 1,

        "master" : 0,
        "sfx" : 0,
        "bgm" : 0,

        #"always_show_health_bar" : false,
        #"show_damage" : false,

        "Move" : OS.get_keycode_string(KEY_F),
        "Attack" : OS.get_keycode_string(KEY_SPACE),
        },
    }
var user_config := {
    "optimal_graphic" : false,
    "fullscreen" : false,
    "resolution_idx" : 0,
    "brightness" : 1,
    "contrast" : 1,

    "master" : 0,
    "sfx" : 0,
    "bgm" : 0,

    #"always_show_health_bar" : false,
    #"show_damage" : false,

    &"Move" : OS.get_keycode_string(KEY_F),
    &"Attack" : OS.get_keycode_string(KEY_SPACE),
}
var user_config_default : Dictionary
var user_data_default : Dictionary

const USER_CONFIG_PATH := "user://user.config.cfg"
const USER_PROGRESS_PATH := "user://user.progress.cfg"

const USER_DATA_PASS = "specimen-a"

func update_user_config() -> void:
    var config := ConfigFile.new()
    if !FileAccess.file_exists(USER_CONFIG_PATH):
        for n in user_config_default.keys():
            config.set_value("config", n, user_config_default[n])
        var err_save := config.save(USER_CONFIG_PATH)
        if err_save != OK:
            printerr("Failed to save user config: ", err_save)
    else:
        var err := config.load(USER_CONFIG_PATH)
        if err == OK:
            for n in user_config.keys():
                config.set_value("config", n, user_config[n])
            var err_save := config.save(USER_CONFIG_PATH)
            if err_save != OK:
                printerr("Failed to save user config: ", err_save)

func load_user_config() -> void:
    if !FileAccess.file_exists(USER_CONFIG_PATH):
        update_user_config()
    else:
        var config := ConfigFile.new()
        var err := config.load(USER_CONFIG_PATH)
        if err == OK:
            for n in config.get_section_keys("config"):
                user_config[n] = config.get_value("config", n)
        else:
            printerr("Failed to load user config: ", err)

func _enter_tree():
    user_data_default = user_data.duplicate(true)
    user_config_default = user_config.duplicate(true)
    load_user_config()

func _input(event : InputEvent) -> void:
    if event is InputEventKey:
        if event.is_action_pressed(&"Debug - Restart scene"):
            get_tree().call_deferred(&"reload_current_scene")

func _process(_delta : float) -> void:

    health = clamp(health, 0.0, 100.0)

    #moving_or_attacking = moving or attacking

#    if player != null:
#        if player.allow_move: moving = true if (
#            Input.is_action_pressed("Move")
#         ) else false
#        else: moving = false
#
#    if moving: moving_f += 0.1
#    else: moving_f -= 0.085
#
#    moving_f = clamp(moving_f, 0.0,
#    float(head_pos.distance_to(
#        get_global_mouse_position()) >= 25))

#    worm_length = sum_array(worm_length_array)

var tile_maps := {}
