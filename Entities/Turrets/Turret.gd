extends StaticBody2D

var health = 60
var max_health = 60
var dead = false

var triggered = false
var firing = false

onready var line_of_sight = $Gun/LineOfSight
var fire_clear = false
onready var line_of_fire = $Gun/LineOfSight/LineOfFire
var fire_ready = false

export(NodePath) var custom_trigger

export(NodePath) var particle_node

export(int) var particle_amount = 35
var particle_max : int = 35
onready var particle_layer = Node2D.new()

export(float,0.0,5.0) var init_cooldown = 0.0
var clear = true
export(float,0.8,5.0) var cooldown

export(String) var group


func _ready():
	$Gun.damage = 32.0
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
			if is_in_group(group):
				for group_n in get_tree().get_nodes_in_group(group):
					group_n.triggered = true
				ot = false
		rotation_degrees = wrapf(rotation_degrees,0,360)
	
	firing = $Gun/AnimationPlayer.is_playing()
	line_of_fire.enabled = firing
	fire_clear = triggered and fire_ready and $Gun/LineOfSight.is_colliding()
	if fire_clear:
		$Gun/AnimationPlayer.play("Firing")
		fire_ready = false

func _physics_process(_delta):
	if triggered:
		$Gun.look_at(glbl.head_pos)

func Weapon_AnimationFinished(anim):
	if anim == "Firing":
		$AttackCooldown.start(cooldown)
func _on_AttackCooldown_timeout():
	fire_ready = true



func Damage(power:float) -> void:
#	var blood					= load(
#		"res://Shaders/Particles/BloodSplatter.CPUParticles2D.tscn").instance()
#	blood.custom_init_pos		= true
#	blood.init_pos				= global_position
#	get_node("../../Objects").add_child(blood)

	if get_node(particle_node)	!= null:
		var particle			= get_node(particle_node).duplicate()
		particle.amount			= int(clamp( particle_amount - (particle_max - particle_amount) * (health/max_health),1,particle_max))
		particle_amount			-= particle.amount
		particle_amount			= clamp(particle.amount,0,particle_max)

		if particle.custom_init_pos:
			particle.init_pos = global_position

		particle.visible		= true
		particle.emitting		= true

		if particle_layer.get_child_count() > 3:
			particle_layer.get_child(0).queue_free()
		particle_layer.add_child(particle)

	health		-= power
	glbl.PopUpPoints(power,global_position)
	if health	<= 0:
#		var corpse = load("res://Entities/Guards/Guard-Corpse.tscn").instance()
#		corpse.init_pos = global_position
#		get_node("../../Objects").add_child(corpse)
		queue_free()
		dead 	= true


func _on_TriggerArea_body_entered(body):
	if body.get_name() == "DamageCollision" or body.get_name() == "Head":
		triggered = true
		$AttackCooldown.start(cooldown)
#		print("> on: " + str(self) + " is: " + str(triggered))
		if get_node_or_null(custom_trigger) == null:
			$TriggerArea.queue_free()




