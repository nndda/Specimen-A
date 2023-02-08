extends StaticBody2D

export(float) var health = 100.0

export(NodePath) var particle_node

export(Array) var destroy_objects

func _ready():
	if get_node(particle_node) != null:
		get_node(particle_node).hide()

func Damage(power:float = 35.0) -> void:
	health -= power

	if get_node(particle_node)	!= null:
		var particle			= get_node(particle_node).duplicate()
		particle.visible		= true
		particle.emitting		= true
		get_parent().add_child(particle)

	print(" Damage():" + str(power) + " -> " + str(self) )

	if health <= 0:

		if !destroy_objects.empty():
			for obj in destroy_objects:
				get_node(obj).queue_free()

		queue_free()
