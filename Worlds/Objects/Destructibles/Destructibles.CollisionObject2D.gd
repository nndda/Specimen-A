extends CollisionObject2D

#enum YieldItem {
#	none,
#	MetalScraps,
#	Battery,
#	Acids
#}
#export(YieldItem) var yield_item = YieldItem.MetalScraps
#export(float,0,1) var yield_chance = 0.5

export(float) var health = 70.0

export(NodePath) var particle_node

export(Array) var destroy_objects

var max_health

export(int) var particle_amount = 30

var particle_max : int = 30
onready var particle_layer = Node2D.new()

export(NodePath) var navigation

func _ready():
	if get_node_or_null(navigation) != null:
		print("nav enabled : " + str(get_node(navigation).enabled))
		get_node(navigation).enabled = false
	max_health = health
	particle_max = particle_amount
	if get_node(particle_node) != null:
		get_node(particle_node).hide()

	get_parent().call_deferred( "add_child", particle_layer )

func Damage(power:float = 35.0) -> void:
	health -= power

	glbl.PopUpPoints(power,global_position)

#	match yield_item:
#		YieldItem.MetalScraps:
#			glbl.shrapnel_current += 1
#		YieldItem.Battery:
#			glbl.emp_charge += 1
#			$ElectricityParticle.emitting = true

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

#	print(" Damage():" + str(power) + " -> " + str(self) )

	if health <= 0:

		if !destroy_objects.empty():
			for obj in destroy_objects:
				get_node(obj).queue_free()

		if get_node_or_null(navigation) != null:
			print("nav enabled : " + str(get_node(navigation).enabled))
			get_node(navigation).enabled = true

		queue_free()
