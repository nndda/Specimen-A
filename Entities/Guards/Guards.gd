extends KinematicBody2D

var health = 80
var dead = false

var triggered = false
var firing = false

onready var line_of_sight = $Gun/LineOfSight
var fire_clear = false

onready var line_of_fire = $Gun/LineOfSight/LineOfFire
var fire_ready = false

export(float,0.0,5.0) var init_cooldown = 0
var clear = true
export(float,0.8,5.0) var cooldown

export(String) var group

func _ready():
	clear = init_cooldown == 0
	if group != "":
		add_to_group(group)
	$GlobalModulate.queue_free()
	$ColorRect.queue_free()
	$AttackCooldown.wait_time = cooldown

var ot = true
func _process(_delta):
	if triggered:
		if ot:
			if is_in_group(group):
				for group_n in get_tree().get_nodes_in_group(group):
					group_n.triggered = true
				ot = false
		rotation_degrees = wrapf(rotation_degrees,0,360)
		look_at(glbl.head_pos)
	
	firing = $Gun/AnimationPlayer.is_playing()
	line_of_fire.enabled = firing
	fire_clear = triggered and fire_ready and $Gun/LineOfSight.is_colliding()
	if fire_clear:
		$Gun/AnimationPlayer.play("Firing")
		fire_ready = false


func Weapon_AnimationFinished(anim):
	if anim == "Firing":
#		ResetFire()
		$AttackCooldown.start(cooldown)
func _on_AttackCooldown_timeout():
	fire_ready = true
#	pass


#func ResetFire() -> void:
#	pass
#	line_of_fire.enabled = false



func Damage(power:float) -> void:
	print("Damaged")
	var blood = load("res://Shaders/Particles/BloodSplatter.CPUParticles2D.tscn").instance()
	blood.custom_init_pos = true
	blood.init_pos = global_position
	get_node("../../Objects").add_child(blood)
#	blood.global_position = global_position
	
	health -= power
	
	if health <= 0:
		dead = true



func _on_TriggerArea_body_entered(body):
	if body.get_name() == "DamageCollision" or body.get_name() == "Head":
		triggered = true
		$AttackCooldown.start(cooldown)
		print("> on: " + str(self) + " is: " + str(triggered))
		$TriggerArea.queue_free()


