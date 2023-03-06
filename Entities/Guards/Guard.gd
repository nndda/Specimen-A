extends CharacterBody2D

@export var health : float = 50
@export var speed : float = 60.0

@export_node_path("Area2D") var custom_trigger
@export_node_path("Node2D") var weapon_node
var weapon
var triggered = false
var firing = false
signal is_triggered


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
	if get_node_or_null(weapon_node) == null:
		weapon = get_node(weapon_node)
	else:
		dbg.err_unexpected_value("weapon_node","null")

	clear = init_cooldown == 0
	$AttackCooldown.wait_time = cooldown

	if get_node_or_null(custom_trigger) != null:
		$TriggerArea.queue_free()
		get_node(custom_trigger).connect( "body_entered", Callable( self, "_on_TriggerArea_body_entered" ) )
	else:
		custom_trigger = NodePath("TriggerArea") # Set default

func _process(_delta):
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
		@warning_ignore("shadowed_variable")
		var move_direction = position.direction_to(nav_agent.get_next_location())
		velo = move_direction * speed
		look_at_direction(move_direction)
		look_at(glbl.head_pos)

		nav_agent.set_velo(velo)

func Weapon_AnimationFinished(anim):
	if anim == "Firing":
		$AttackCooldown.start(cooldown)
func _on_AttackCooldown_timeout():
	fire_ready = true

var blood = preload("res://Shaders/Particles/BloodSplatters.tscn").instance()
var corpse = preload("res://Entities/Guards/Guard-Corpse/Guard-Corpse.tscn").instance()

func Damage(power:float) -> void:

	blood.custom_init_pos		= true
	blood.init_pos				= global_position
	get_node("../../Objects/Decor").add_child(blood)

	health		-= power

	if health	<= 0:
		corpse.init_pos = global_position
		get_node("../../Objects/Decor").add_child(corpse)

		queue_free()
	else:
		blood = preload("res://Shaders/Particles/BloodSplatters.tscn").instance()
		

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
		velo = safe_velocity
		velocity = velo
		move_and_slide()
	elif not arrived:
		arrived = true
		emit_signal("path_changed", [])
		emit_signal("target_reached")

func _on_UpdatePlayerPos_timeout():
	if global_position.distance_to(glbl.head_pos) >= 32.0 * 5.0:
		SetTargetPos(glbl.head_pos)
	else:
		$KeepDistance.rotation_degrees = randf_range(-15,15)
		SetTargetPos($KeepDistance/Position2D.global_position)






func _on_TriggerArea_body_entered(body):
	if body.get_name() == "DamageCollision" or body.get_name() == "Head":
		triggered = true
		$AttackCooldown.start(cooldown)	
		print("> on: " + str(self) + " \"triggered\" is: " + str(triggered))
		emit_signal("is_triggered")

func _on_TriggerArea_area_entered(area):
	pass

func _on_is_triggered() -> void:
	$GeneralArea.queue_free()
	if get_node_or_null(custom_trigger) != null:
		get_node(custom_trigger).queue_free()



func _on_general_area_entered(area):
	if area.get_name() == "ShakeArea":
		player_near = true
func _on_general_area_exited(area):
	if area.get_name() == "ShakeArea":
		player_near = false
