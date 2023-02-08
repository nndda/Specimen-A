extends Node2D

var top_scale = 1.1

var camera : Object

var allow_move : bool = true
var moving : bool
var moving_f : float

var head_pos : Vector2
var head_canvas_pos : Vector2

var worm_segment_max : int = 40
var worm_length : float
var worm_length_array : Array

var worm_body

var health : float = 100.0

func sum_array(array:PoolRealArray) -> float:
	var t = 0.0
	for n in array:
		 t += n
	return t


var attack_mode : int = 0
func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					attack_mode += 1
				BUTTON_WHEEL_DOWN:
					attack_mode -= 1
#		print(attack_mode)

#	CONFIG
var cfg = {
	"always_show_health_bar"	: false,
	"optimal_graphic"			: false,
}





func _process(_delta):

	if Input.is_action_pressed("Skill1"):
		health -= 2.0
	if Input.is_action_pressed("Skill2"):
		health += 2.0

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
