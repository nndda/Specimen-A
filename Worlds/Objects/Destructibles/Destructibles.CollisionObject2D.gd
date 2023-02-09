extends StaticBody2D

export(float) var health = 100.0

export(NodePath) var particle_node

export(Array) var destroy_objects

var max_health

export(int) var particle_amount = 30

var particle_max : int = 30

func _ready():
	max_health = health
	particle_max = particle_amount
	if get_node(particle_node) != null:
		get_node(particle_node).hide()

func Damage(power:float = 35.0) -> void:
	health -= power

	if get_node(particle_node)	!= null:
		var particle			= get_node(particle_node).duplicate()
		particle.amount			= int(clamp( particle_amount - (particle_max - particle_amount) * (health/max_health),1,particle_max))
		particle_amount			-= particle.amount
		particle_amount			= clamp(particle.amount,0,particle_max)
		print(particle_amount)
		print(particle.amount)
#		particle.amount			= int( ( 30 * ( max_health - health ) ) / max_health )
		particle.visible		= true
		particle.emitting		= true
		get_parent().add_child(particle)

	print(" Damage():" + str(power) + " -> " + str(self) )

	if health <= 0:

		if !destroy_objects.empty():
			for obj in destroy_objects:
				get_node(obj).queue_free()

		queue_free()
