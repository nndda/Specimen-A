extends KinematicBody2D


func Damage(power:float) -> void:

	var blood					= load(
		"res://Shaders/Particles/BloodSplatter.CPUParticles2D.tscn").instance()
	blood.custom_init_pos		= true
	blood.init_pos				= global_position
	if get_parent() is Area2D:
		get_node("../../../Objects/Decor").add_child(blood)
	else:
		get_node("../../Objects/Decor").add_child(blood)

	$"../..".health_gunner		-= power
	glbl.PopUpPoints(power,global_position)
	if $"../..".health_gunner	<= 0:
		var corpse = load("res://Entities/Guards/Guard-Corpse.tscn").instance()
		corpse.init_pos = global_position
#		if get_node_or_null("../../Objects/Decor") != null:
		if get_parent() is Area2D:
			get_node("../../../Objects/Decor").add_child(corpse)
		else:
			get_node("../../Objects/Decor").add_child(corpse)

		queue_free()
		$"../..".dead 	= true
