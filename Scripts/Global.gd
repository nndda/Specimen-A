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

var moving : bool
var moving_f : float

var attacking : bool

var moving_or_attacking : bool

var head_pos            : Vector2
var head_canvas_pos     : Vector2

var health              : float = 100.0

var player_physics_head : CharacterBody2D
var player_physics_body : Area2D

const PLAYER_HEAD_NAME : StringName = &"Head"
const PLAYER_BODY_NAME : StringName = &"Body"

var player_destroy_through : Area2D
var player_general_area : Area2D

@warning_ignore("unused_signal")
signal camera_shaken_by_player(substantial : bool)

@warning_ignore("unused_signal")
signal level_changed

#var skill_current       : int = skill.none
#
#enum skill {
    #none,
    #DischargeShrapnel,
    #EMPBurst,
    #SynthesizeAcids,
#}
#var skills_discovered   : int = 4 # Dbg purpose
#
#var shrapnel_current    : int = 0
#var emp_charge          : int = 0
#var acid                : int = 0

func sum_array(array : PackedFloat32Array) -> float:
    var t : float = 0.0
    for n in array: t += n
    return t


var user_data := {
    "level_unlocked" : 0,
    "level_stats" : {
        "tutorial_passed": false,
        "lv2_emergency_light": false,
    },
    "achievements" : {

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
const USER_DATA_PATH := "user://user_data"

const USER_DATA_PASS = "specimen-a"

#region user config
func update_user_config() -> void:
    var config := ConfigFile.new()
    var err := OK

    if FileAccess.file_exists(USER_CONFIG_PATH):
        err = config.load(USER_CONFIG_PATH)

    if err != OK:
        printerr("Error loading user config: ", error_string(err))
    else:
        var config_data : Dictionary = user_config_default.merged(user_config, true)

        for n in config_data.keys():
            config.set_value("config", n, config_data[n])
    
    var err_save := config.save(USER_CONFIG_PATH)
    if err_save != OK:
        printerr("Error saving user config: ", error_string(err_save))

func load_user_config() -> void:
    if !FileAccess.file_exists(USER_CONFIG_PATH):
        update_user_config()
    else:
        var config := ConfigFile.new()
        var err := config.load(USER_CONFIG_PATH)
        if err != OK:
            printerr("Error loading user config: ", error_string(err))
        else:
            for n in config.get_section_keys("config"):
                user_config[n] = config.get_value("config", n)
#endregion

#region user data
func update_user_data() -> void:
    var data_file := FileAccess.open_encrypted_with_pass(
        USER_DATA_PATH, FileAccess.WRITE, USER_DATA_PASS
    )
    var err := FileAccess.get_open_error()

    if err != OK:
        printerr("Error saving user data: ", error_string(err))
    else:
        data_file.store_string(
            var_to_str(user_data_default)
        )
        data_file.close()

    data_file = null

func load_user_data() -> void:    
    var data_file := FileAccess.open_encrypted_with_pass(
        USER_DATA_PATH, FileAccess.READ, USER_DATA_PASS
    )
    var err := FileAccess.get_open_error()

    if err != OK:
        push_error("Error loading user data: ", error_string(err))
    elif err == ERR_FILE_NOT_FOUND or\
        !FileAccess.file_exists(USER_DATA_PATH):
        update_user_data()
    else:
        user_data.merge(
            str_to_var(data_file.get_as_text()) as Dictionary,
            true
        )
        data_file.close()

    data_file = null
#endregion

func _enter_tree() -> void:
    user_data_default = user_data.duplicate(true)
    user_config_default = user_config.duplicate(true)

    user_data_default.make_read_only()
    user_config_default.make_read_only()

    load_user_config()
    load_user_data()

func _input(event : InputEvent) -> void:
    if event is InputEventKey:
        if event.is_action_pressed(&"Debug - Restart scene"):
            get_tree().reload_current_scene()

func _process(_delta : float) -> void:
    health = clamp(health, 0.0, 100.0)

func _exit_tree() -> void:
    tile_maps.clear()

var tile_maps := {}
