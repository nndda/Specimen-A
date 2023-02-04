extends Node

var allow_move : bool = true
var moving : bool
var moving_f : float

var worm_segment_max : int = 36
var worm_length : float
var worm_length_array : Array

var worm_body

func sum_array(array:PoolRealArray) -> float:
	var t = 0.0
	for n in array:
		 t += n
	return t

func _process(delta):

	if allow_move:
		moving = true if Input.is_action_pressed("Move") else false

	if moving:
		moving_f += 0.1
	else:
		moving_f -= 0.085
#	moving_f += (1.1 if moving else -2.0 * 0.05) * delta
	moving_f = clamp(moving_f,0.0,1.0)
