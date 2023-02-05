extends KinematicBody2D

var easer = 0.0
var max_speed = 350.0
var speed = 430.0

var face_obstacle = false

func _process(_delta):
	$Arrow.look_at(get_global_mouse_position())
	$Arrow.modulate.a = glbl.moving_f
	$Arrow.offset.x = (glbl.moving_f * 60) + 68
	
	glbl.head_pos = global_position
	
	$FaceObstacle.look_at(get_global_mouse_position())
	glbl.allow_move = !$FaceObstacle.is_colliding()
	if $FaceObstacle.is_colliding():
		if Input.is_action_just_pressed("Move"):
			$FaceObstacleIcon.global_position = $FaceObstacle.get_collision_point()
			$FaceObstacleIcon/AnimationPlayer.play("Blink")

var velo
func _physics_process(_delta):

	easer += ( 0.1 * 1.0 if glbl.moving else -1.0 )
	easer = clamp(easer,0.0,1.0)

	velo = move_and_slide(
		float(glbl.moving_f) * (( speed ) * global_position.direction_to(get_global_mouse_position()))
	)

	if glbl.moving_f > 0:
		self.look_at(get_global_mouse_position())

	if Input.is_action_pressed("ui_accept"):
		speed = 720
	else:
		speed = 430
