extends Node2D

#enum item_id {
#	flower,grass,dirt
#}

var top_scale = 1.1

var camera : Object

var allow_move : bool = true
var moving : bool
var moving_f : float

var attacking : bool

var head_pos : Vector2
var head_canvas_pos : Vector2

var worm_segment_max : int = 56
var worm_length : float
var worm_length_array : Array[float]

var worm_body

var health : float = 100.0



var skill_current = skill.none
enum skill {
	none,
	DischargeShrapnel,
	EMPBurst,
	SynthesizeAcids
}
#var skills_discovered : int = 0
var skills_discovered : int = 4 # Dbg purpose

var shrapnel_current : int = 0
var emp_charge : int = 0
var acid : int = 0



func sum_array(array:Array[float]) -> float:
	var t = 0.0
	for n in array:
		t += n
	return t

#	CONFIG
var cfg = {
	"always_show_health_bar"	: false,
	"optimal_graphic"			: false,
	"show_damage"				: true,
}


func _process(_delta):

#	if Input.is_action_pressed("Skill1"):
#		health -= 2.0
#	if Input.is_action_pressed("Skill2"):
#		health += 2.0

	health = clamp(health,0.0,100.0)

	if allow_move:
		moving = true if Input.is_action_pressed("Move") else false
	else:
		moving = false

	if moving:
		moving_f += 0.1
	else:
		moving_f -= 0.085

	moving_f = clamp( moving_f, 0.0,
		float(glbl.head_pos.distance_to(get_global_mouse_position()) >= 25)
		
)
#	skill_current = wrapi(skill_current,0,skills_discovered)
	worm_length = sum_array(worm_length_array)

var gameplay_ui_layer
func PopUpPoints(value : float, pos : Vector2) -> void:
	if glbl.cfg.show_damage:
		var label = load("res://UI/PointsLabel.tscn").instance()
		label.text = str(round(value))
		label.init_pos = pos
		gameplay_ui_layer.call_deferred("add_child",label)

