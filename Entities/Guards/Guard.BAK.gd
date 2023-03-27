extends CharacterBody2D

@export var health : float = 50
@export var speed : float = 60.0


@export var moving_away = false
@export var stationary = false


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
		$KeepDistance.queue_free()

	$VisibilityHandler.show()

func _process(_delta):

	corpse.global_position = global_position
	corpse.look_at(glbl.head_pos)
	corpse.visible = health <= 0

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

#		if !stationary:
#			@warning_ignore("shadowed_variable")
#			nav_agent.target_position = glbl.head_pos
#			nav_agent.target_desired_distance = 32*5
#			velo = nav_agent.get_next_path_position() * speed
#			velocity = velo
#			move_and_slide()

#			var move_direction = position.direction_to(nav_agent.get_next_path_position())
#			move_direction = position.direction_to(nav_agent.get_next_path_position())
#			velo = move_direction * speed
#			look_at_direction(move_direction)

#			nav_agent.set_velocity(velo)

#			$Label.rotation_degrees = -rotation_degrees
#			$Label.text = str(move_direction)

		look_at(glbl.head_pos)


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

#	blood.custom_init_pos		= true
#	blood.init_pos				= global_position
#	get_node("../../Objects/Decor").add_child(blood)
#	get_node("../../Objects/Bloods").add_child(blood)

	health		-= power

	if health <= 0:

#		corpse.init_pos = global_position
#		corpse.global_rotation = global_rotation
#		corpse.visible = true
#		corpse.process_mode = Node.PROCESS_MODE_INHERIT
#		print(corpse.get_parent())
#		corpse.call_deferred( "reparent", get_node("../../Objects/Corpses") )
#		corpse.reparent( get_node("../../Objects/Bloods") )

#		print(corpse.get_parent())
#		corpse.active = true
#		corpse.visible = true

#		corpse.reparent(glbl.layer_dict["Objects/Corpses"])
		corpse.visible = true

		queue_free()

	else:
#		blood	= load(blood_scene).instantiate()
		blood	= load(blood_scene).instantiate()
		blood.custom_init_pos = true
		blood.init_pos = global_position
		glbl.layer_dict["Objects/Particles"].add_child(blood)
#		blood = preload("res://Shaders/Particles/BloodSplatters.tscn").instance()

var arrived = false
func SetTargetPos(pos:Vector2) -> void:
	arrived = false
	nav_agent.set_target_location(pos)

#func look_at_direction(direction:Vector2) -> void:
#	direction = direction.normalized()
#	move_direction = direction

func _on_NavigationAgent2D_path_changed():
	nav_agent.get_current_navigation_path()
#	emit_signal("path_changed", nav_agent.get_current_navigation_path())

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
		if !moving_away:
			SetTargetPos(glbl.head_pos)
	else:
		$KeepDistance.rotation_degrees = randf_range(-15,15)
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
	if custom_trigger != null:
		get_node(custom_trigger).queue_free()
	if path != null:
		get_node(path).queue_free()



func _on_general_area_entered(area):
	if area.get_name() == "ShakeArea":
		player_near = true
func _on_general_area_exited(area):
	if area.get_name() == "ShakeArea":
		player_near = false

