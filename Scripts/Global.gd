extends Node

var allow_move : bool = true
var moving : bool

var worm_segment_max : int = 36
var worm_length : float
var worm_length_array : Array

var worm_body

func sum_array(array:PoolRealArray) -> float:
	var t = 0.0
	for n in array:
		 t += n
	return t

func _process(_delta):
	if allow_move:
		moving = true if Input.is_action_pressed("Move") else false
