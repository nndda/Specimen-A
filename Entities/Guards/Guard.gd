extends CharacterBody2D

@export var health : float = 50
@export var speed : float = 80.0

@export var moving_away = false
@export var stationary = false
#@export var rotate_weight : float = 0.8
@export_range(0.0,1.0) var rotate_weight = 0.8


@export_group("Nodes")
@export_node_path("PathFollow2D")	var path
@export_node_path("Area2D")			var custom_trigger
@export_node_path("Node2D")			var weapon_node
#@export_file("*.tscn")				var corpse_scene : String = "res://Entities/Guards/Guard-Corpse/Guard-Corpse.tscn"
@export_node_path("Node2D")			var corpse_scene
@export_file("*.tscn")				var blood_scene : String = "res://Shaders/Particles/BloodSplatters.tscn"
var weapon
var triggered = false
var firing = false
signal is_triggered


@export_group("Timing")
@export_range(0.0,5.0,0.1) var init_cooldown = 0.0
@export_range(0.8,5.0,0.1) var cooldown = 0.8
var fire_clear = false
var fire_ready = false

var clear = true

var player_near = false



signal path_changed(path)
signal target_reached
@onready var nav_agent = $NavigationAgent2D

var velo		: Vector2
var move_direction	: Vector2


func GetPlayerPos() -> Vector2:
	return glbl.head_pos


func _ready():

	corpse = get_node(corpse_scene)
	corpse.reparent(glbl.layer_dict["Objects/Corpses"])
	corpse.modulate.a = 0.8
	corpse.z_as_relative = false
	corpse.z_index = -100

	if get_node_or_null(weapon_node) != null:
		weapon = get_node(weapon_node)
	else:
		push_error( dbg.value_is("weapon_node","null") )

	clear = init_cooldown == 0
	$AttackCooldown.wait_time = cooldown

	if custom_trigger != null:
		$TriggerArea.queue_free()
		get_node(custom_trigger).connect( "body_entered", Callable( self, "_on_TriggerArea_body_entered" ) )
	else:
		custom_trigger = NodePath("TriggerArea") # Set default

	if stationary:
		nav_agent = null
		$KeepDistance.queue_free()
		$NavigationAgent2D.queue_free()
#	else:
#		nav_agent.set_velocity(Vector2(speed,speed))

	$VisibilityHandler.show()

func _process(_delta):

	corpse.global_position = global_position
	corpse.look_at(glbl.head_pos)
#	corpse.visible = health <= 0

	if player_near and cam.shaking:
		triggered = true

	if triggered:
		rotation_degrees = wrapf(rotation_degrees,0,360)

	fire_clear	= triggered and fire_ready and weapon.on_line
	if fire_clear:
		weapon.Fire()
		fire_ready = false

func _physics_process(_delta):
	if triggered:

#		$Seeker.look_at(glbl.head_pos)
#		$Seeker.rotation_degrees = wrapf($Seeker.rotation_degrees,-180,180)

#		weapon.rotation = lerp_angle(
#			weapon.rotation, (
#				glbl.head_pos - weapon.global_position
#				).normalized().angle(), rotate_weight)
		rotation = lerp_angle(
			rotation, (
				glbl.head_pos - global_position
				).normalized().angle(), rotate_weight)

		if !stationary:
			nav_agent.set_velocity(Vector2(speed,speed))

#			$Label.rotation_degrees = -rotation_degrees
#			$Label.text = str(move_direction)

		else:
			$Sprite2D.rotation_degrees = -rotation_degrees

#		look_at(glbl.head_pos)

#	else:
#		if path_enabled:
#


func Weapon_AnimationFinished(anim):
	if anim == "Firing":
		$AttackCooldown.start(cooldown)
func _on_AttackCooldown_timeout():
	fire_ready = true

var blood
var corpse

func Damage(power:float) -> void:

	health		-= power

	if health <= 0:
		corpse.z_as_relative = true
		corpse.z_index = 0
		queue_free()

	else:
		blood	= load(blood_scene).instantiate()
		blood.custom_init_pos = true
		blood.init_pos = global_position
		glbl.layer_dict["Objects/Particles"].add_child(blood)



var arrived = false
func SetTargetPos(pos:Vector2) -> void:
	arrived = false
	nav_agent.target_position = pos

var direction : Vector2
func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	if !nav_agent.is_navigation_finished():
		velo = safe_velocity
		velocity = velo * direction# * speed
		move_and_slide()
	elif !arrived:
		arrived = true
		nav_agent.emit_signal("path_changed")
	
func _on_UpdatePlayerPos_timeout():
#	print()
#	printt("|","timeout",str(round(global_position.distance_to(glbl.head_pos))))
	if global_position.distance_to(glbl.head_pos) >= 32.0 * 5.0:
		if !moving_away:
#			printt("|",dbg.value_is("to glbl.head_pos",glbl.head_pos.round()))
			direction = global_position.direction_to(glbl.head_pos)
			#speed = 65 #* (remap(global_position.distance_to(glbl.head_pos),0,32*5,0,1) * 1.2)
			SetTargetPos(glbl.head_pos)
	else:
		$KeepDistance.rotation_degrees = randf_range(-15,15)
#		printt("|",dbg.value_is("moving away",$KeepDistance/Position2D.global_position.round()))
		direction = global_position.direction_to($KeepDistance/Position2D.global_position)
		SetTargetPos($KeepDistance/Position2D.global_position)






func _on_TriggerArea_body_entered(body):
	if body.get_name() == "Head":
		emit_signal("is_triggered")
func _on_TriggerArea_area_entered(area):
	if area.get_name() == "DamageCollision":
		emit_signal("is_triggered")

func _on_is_triggered() -> void:
	triggered = true
	printt( "|", dbg.value_is("triggered","true") )
	$AttackCooldown.start(cooldown)
	$GeneralArea.queue_free()
	$TriggerArea.queue_free()
#	if custom_trigger != null:
#		get_node(custom_trigger).queue_free()
	if path != null:
		get_node(path).queue_free()
	if !stationary:
		$NavigationAgent2D/UpdatePlayerPos.start()



func _on_general_area_entered(area):
	if area.get_name() == "ShakeArea":
		player_near = true
func _on_general_area_exited(area):
	if area.get_name() == "ShakeArea":
		player_near = false



