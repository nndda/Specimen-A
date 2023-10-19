extends Node2D

var enemy_exception_bodies : Array[ PhysicsBody2D ]
var current_scene : Object

var layer : Array[String] = [
    "Objects/Corpses",
    "Objects/Particles",
    "Objects/Statics",
    "Objects",
    "Entities" ]
var layer_dict : Dictionary = {}
func update_layers() -> void: for itm in layer:
    layer_dict[ itm ] = current_scene.get_node( itm )

var current_objects     : Array
var top_scale           : float = 1.1

var allow_move          : bool = true
var moving              : bool
var moving_f            : float

var attacking           : bool

var head_pos            : Vector2
var head_canvas_pos     : Vector2

var worm_segment_max    : int = 56
var worm_length         : float
var worm_length_array   : Array[float]

var worm_body           : Object

var health              : float = 100.0

var is_shake_by_player  : bool = false

var skill_current       : int = skill.none

enum skill {
    none,
    DischargeShrapnel,
    EMPBurst,
    SynthesizeAcids
}
var skills_discovered   : int = 4 # Dbg purpose

var shrapnel_current    : int = 0
var emp_charge          : int = 0
var acid                : int = 0



func sum_array( array : Array[ float ] ) -> float:
    var t = 0.0
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

func _process( _delta ) -> void:

    health = clamp( health, 0.0, 100.0 )

    if allow_move: moving = true if (
        Input.is_action_pressed( "Move" )
        ) else false
    else: moving = false

    if moving: moving_f += 0.1
    else: moving_f -= 0.085

    moving_f = clamp( moving_f, 0.0,
    float( head_pos.distance_to(
        get_global_mouse_position() ) >= 25 ) )

    worm_length = sum_array( worm_length_array )
