extends CharacterBody2D

#var easer					= 0.0
var speed					= 360.0

var face_obstacle			= false

var allow_attack			= true

var attacking				= false
var attack_strength			: float
var attack_out				: int
var attack_dir				: Vector2
var attack_cooldown			= 2.5

var attack_speed			= 22.0

var attack_distance_max		: float = 32.0 * 12.0
var attack_pos : Array[Vector2] = [Vector2(),Vector2()]

func OpenMouth(n:float) -> void:
	$Mouth/Jaw_0.rotation_degrees = n*-30
	$Mouth/Jaw_0.rotation_degrees = clamp($Mouth/Jaw_0.rotation_degrees,-30.0,0.0)
	$Mouth/Jaw_1.rotation_degrees = n*30
	$Mouth/Jaw_1.rotation_degrees = clamp($Mouth/Jaw_1.rotation_degrees+n*30,0.0,30.0)


func AttackHandler() -> void:

	$"../UI/AttackIndicator".visible = Input.is_action_pressed("Attack") and allow_attack

	if allow_attack:

		match glbl.skill_current:
			glbl.skill.none:
				attack_out	+= 4 if Input.is_action_pressed("Attack") else -4
				attack_out	= int(clamp(attack_out,0,100))
				OpenMouth(float(attack_out)/100)
				if Input.is_action_pressed("Attack"):
					$"../UI/Arrow".look_at(get_viewport().get_mouse_position())
					$"../UI/Arrow".position		= glbl.head_canvas_pos
					$"../UI/Arrow".modulate.a	= float(attack_out)/100
					$"../UI/Arrow".offset.x		= (float(attack_out)/100 * 60) + 68
					$FaceObstacle.look_at(get_global_mouse_position())
					self.look_at(get_global_mouse_position())

				if Input.is_action_just_released("Attack"):
#					$AreaShake/CollisionShape2D.set_deferred("disabled",false)
					$AreaShake.monitorable	= true
					$AreaShake.monitoring	= true
					attacking			= true
					attack_dir			= glbl.head_pos.direction_to(get_global_mouse_position())
					attack_strength		= float(attack_out)
					$AttackCooldown.start(
						3.25 * ( float( attack_out ) / 100 ) )
					attack_pos[0] = glbl.head_pos
					allow_attack = false

			glbl.skill.DischargeShrapnel:
				if Input.is_action_just_pressed("Attack") and glbl.shrapnel_current > 0:
					pass

			glbl.skill.EMPBurst:
				if Input.is_action_just_pressed("Attack") and glbl.emp_charge > 0:
					pass

			glbl.skill.SynthesizeAcids:
				if Input.is_action_just_pressed("Attack") and glbl.acid > 0:
					pass

	$"../UI/AttackIndicator".value		= attack_out
	$"../UI/AttackCooldown".max_value	= 100
	$"../UI/AttackCooldown".value		= (($AttackCooldown.time_left / $AttackCooldown.wait_time) * 100)


func _ready():
	
#	cam.connect("shaking_started",Callable(self,"ShakeStarted"))
#	cam.connect("shaking_finished",Callable(self,"ShakeFinished"))
#	$AreaShake.set_deferred("monitorable",false)
	
#	$AreaShake.monitorable = false
#	$AreaShake/CollisionShape2D.set_deferred("disabled",true)
#	print($AreaShake/CollisionShape2D.disabled)
#	$AreaShake.monitorable	= false
#	$AreaShake.monitoring	= false
	
#	$DestroyThrough.add_exception($FaceObstacle)
#	$FaceObstacle.add_exception($DestroyThrough)
	MonitorVariables()


func _process(delta):

	MonitorVariables()

#	glbl.health += ( 2.5 * delta ) * 1 if !invincible else 0.5
	glbl.health += ( 2.5 * delta )

	glbl.head_pos				= global_position
	glbl.head_canvas_pos		= get_global_transform_with_canvas().origin


	$"../UI/Arrow".look_at(get_viewport().get_mouse_position())
	$"../UI/Arrow".position		= glbl.head_canvas_pos
	$"../UI/Arrow".modulate.a	= glbl.moving_f
	$"../UI/Arrow".offset.x		= (glbl.moving_f * 60) + 68


	$"../UI/AttackIndicator".position = glbl.head_canvas_pos - $"../UI/AttackIndicator".size / 2
	$"../UI/AttackCooldown".position = glbl.head_canvas_pos - $"../UI/AttackCooldown".size / 2


	$FaceObstacle.look_at(get_global_mouse_position())
	glbl.allow_move = !$FaceObstacle.is_colliding()
	$"../UI/FaceObstacleIcon".visible = $FaceObstacle.is_colliding()
	if $FaceObstacle.is_colliding():
		if Input.is_action_just_pressed("Move"):
			$"FaceObstacle-Pos".global_position = $FaceObstacle.get_collision_point()
			$"../UI/FaceObstacleIcon".position = $"FaceObstacle-Pos".get_global_transform_with_canvas().origin
			$"../UI/FaceObstacleIcon/AnimationPlayer".play("Blink")

	AttackHandler()


var velo
var attack_velo	: Vector2
var collision
func _physics_process(delta):

	attack_distance_max = ( 12.0 * 32.0 ) * (attack_strength / 60)
	$"DestroyThrough-A".monitoring = attacking

	if !attacking:
		velo = (
			( float( glbl.moving_f ) *
			( ( speed ) * global_position.direction_to(get_global_mouse_position()) ) )
		)
		velocity = velo
		move_and_slide()

		if $AreaShake.monitorable:
			ShakeFinished()
		
	else:
		velo			= attack_speed * attack_dir
		collision		= move_and_collide(velo)

		attack_pos[1]	= glbl.head_pos

		if collision != null:
			velo = velo.bounce( collision.get_normal() )
			ShakeCam()
			ResetAtkDmg()
			attacking = false

		if attack_pos[0].distance_to(attack_pos[1]) >= attack_distance_max:
			velo -= Vector2(
				2.0 * delta,
				2.0 * delta )
			ResetAtkDmg()
			attacking = false

		velo = clamp( velo, Vector2.ZERO, attack_speed * attack_dir )

	if glbl.moving_f > 0 and !attacking:
		self.look_at( get_global_mouse_position() )

	$"../UI/AttackCooldown".visible = ( $AttackCooldown.time_left > 0 )
	glbl.attacking = attacking

func ShakeCam() -> void:
	cam.ShakeStart(
		15 + ( 25 * ( attack_strength / 100 ) ),
		0.95,
		16 + 8 * ( attack_strength / 100 ) )
	ShakeStarted()
func ShakeStarted() -> void:
	glbl.is_shake_by_player = true
#	$AreaShake.set_deferred("monitorable",true)
#	print("ShakeStarted")
#	$AreaShake.monitorable = true
func ShakeFinished() -> void:
	glbl.is_shake_by_player = false
#	$AreaShake.set_deferred("monitorable",false)
#	print("ShakeFinished")
#	$AreaShake.monitorable = false


func ResetAtkDmg() -> void:
#	if reset:
	OpenMouth(0)
	attack_strength = 0
	attack_out = 0

func _on_AttackCooldown_timeout():
	allow_attack = true



var invincible = false
func DamagePlayer(power:float) -> void:
	if !invincible:
		var power_total = (power * 1.25) * 1.0 if !attacking else 0.0
		
#		print("DamagePlayer: " + str(
#			power_total
#			)
#		)
		glbl.health -= power_total
		$"../Body/Lights/AnimationPlayer/Hit".play("Hit")
#		$"../Body/AnimationPlayer/Hit".play("Hit")
#		$"../UI/Control/HealthBar/AnimationPlayer".play("Visible")

func MonitorVariables() -> void:
	$"../DBG/VBoxContainer".data = [
		"fps",				Engine.get_frames_per_second(),
		"body length",		round(glbl.worm_length),
		"head pos",			glbl.head_pos.round(),
		"moving",			glbl.moving,
		"attacking",		glbl.attacking,
		"health",			round(glbl.health),
	]


func _on_DestroyThroughA_body_entered(body):
	if body.has_method("Damage"):

		if body.health - attack_strength <= 0:
			body.Damage( body.health )

		else:
			body.Damage( attack_strength )

		ShakeCam()

#		else:
#			if collision != null:
#				if collision.has_method("Damage"):
#					collision.Damage(attack_strength)
#					ResetAtkDmg()
#				ShakeCam()
		
