extends StaticBody2D

@export_range(20.0,80.0) var health : float = 40.0
@export_file("*.tscn") var particles_scene

var particles : Array

func _ready(): for p in 3: particles.append( load( particles_scene ).instantiate())

func Damage(power:float) -> void:

	print(dbg.value_is("damage",power))

	EmitParticles()

	health		-= power

	if health <= 0:
		$"../Sprite2D".hide()
		$"../Sprite2D-2".hide()
		$CollisionShape2D.set_deferred("disabled",true)

		if $"../FreeTimer".time_left <= 3.0: $"../FreeTimer".start()

func EmitParticles() -> void:
	if particles.size() > 0:
		particles[0].custom_init_pos = true
		particles[0].init_pos = global_position
		glbl.layer_dict["Objects/Particles"].add_child(particles[0])
		particles.remove_at(0)

func _on_free_timer_timeout(): get_parent().queue_free()
