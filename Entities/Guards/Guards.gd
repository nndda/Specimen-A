extends KinematicBody2D

var health = 80
var dead = false

var speed = 60.0

var triggered = false
var firing = false

#onready var line_of_sight = $Gun/LineOfSight
var fire_clear = false
#onready var line_of_fire = $Gun/LineOfSight/LineOfFire
var fire_ready = false

export(float,0.0,5.0) var init_cooldown = 0.0
var clear = true
export(float,0.8,5.0) var cooldown

export(NodePath) var custom_trigger

signal path_changed(path)
signal target_reached
onready var nav_agent = $NavigationAgent2D

var velocity		: Vector2
var move_direction	: Vector2


func GetPlayerPos() -> Vector2:
	return glbl.head_pos


func _ready():
	clear = init_cooldown == 0
	$AttackCooldown.wait_time = cooldown

	if get_node_or_null(custom_trigger) != null:
		$TriggerArea.queue_free()
# warning-ignore:return_value_discarded
		get_node(custom_trigger).connect(
			"body_entered",self,"_on_TriggerArea_body_entered"
			)


var ot = true
func _process(_delta):
	if triggered:
		if ot:
			if get_groups().size() > 0:
				for group_n in get_tree().get_nodes_in_group(get_groups()[0]):
					if group_n.has_method("_on_TriggerArea_body_entered"):
						group_n.triggered = true
				ot = false
		rotation_degrees = wrapf(rotation_degrees,0,360)
	
	firing = $Gun/AnimationPlayer.is_playing()
#	line_of_fire.enabled = firing
	fire_clear = triggered and fire_ready and $Gun.on_line
	if fire_clear:
		$Gun/AnimationPlayer.play("Firing")
		fire_ready = false

func _physics_process(_delta):
	
	if triggered:
# warning-ignore:shadowed_variable
		var move_direction = position.direction_to(nav_agent.get_next_location())
		velocity = move_direction * speed
		look_at_direction(move_direction)
		look_at(glbl.head_pos)

		nav_agent.set_velocity(velocity)


func Weapon_AnimationFinished(anim):
	if anim == "Firing":
		$AttackCooldown.start(cooldown)
func _on_AttackCooldown_timeout():
	fire_ready = true



func Damage(power:float) -> void:

	var blood					= load(
		"res://Shaders/Particles/BloodSplatter.CPUParticles2D.tscn").instance()
	blood.custom_init_pos		= true
	blood.init_pos				= global_position
	get_node("../../Objects").add_child(blood)

	health		-= power
	glbl.PopUpPoints(power,global_position)
	if health	<= 0:
		var corpse = load("res://Entities/Guards/Guard-Corpse.tscn").instance()
		corpse.init_pos = global_position
		get_node("../../Objects").add_child(corpse)
		queue_free()
		dead 	= true


var arrived = false
func SetTargetPos(pos:Vector2) -> void:
	arrived = false
	nav_agent.set_target_location(pos)

func look_at_direction(direction:Vector2) -> void:
	direction = direction.normalized()
	move_direction = direction

func _on_NavigationAgent2D_path_changed():
	emit_signal("path_changed", nav_agent.get_nav_path())

func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	if not nav_agent.is_navigation_finished():
		velocity = move_and_slide(safe_velocity)
	elif not arrived:
		arrived = true
		emit_signal("path_changed", [])
		emit_signal("target_reached")

func _on_UpdatePlayerPos_timeout():
	if global_position.distance_to(glbl.head_pos) >= 32.0 * 5.0:
		SetTargetPos(glbl.head_pos)
	else:
		$KeepDistance.rotation_degrees = rand_range(-15,15)
		SetTargetPos($KeepDistance/Position2D.global_position)

func _on_TriggerArea_body_entered(body):
	if body.get_name() == "DamageCollision" or body.get_name() == "Head":
		triggered = true
		$AttackCooldown.start(cooldown)
#		print("> on: " + str(self) + " is: " + str(triggered))
		if get_node_or_null(custom_trigger) == null:
			$TriggerArea.queue_free()




