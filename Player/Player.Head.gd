extends KinematicBody2D

var easer = 0.0
var max_speed = 350.0
var speed = 430.0

var velo
func _physics_process(_delta):

	easer += ( 0.1 * 1.0 if glbl.moving else -1.0 )
	easer = clamp(easer,0.0,1.0)

	velo = move_and_slide(
		float(glbl.moving) * ( ease(easer,0.5) * speed ) * global_position.direction_to(get_global_mouse_position())
	)

	if glbl.moving:
		self.look_at(get_global_mouse_position())

	if Input.is_action_pressed("ui_accept"):
		speed = 720
	else:
		speed = 430
