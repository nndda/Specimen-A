extends PhysicsBody2D

@export_range( 1.0, 300.0 ) var health : float = 40.0
@export var invincible := false
@export_file("*.tscn") var particles_scene : String
@export_node_path("Node2D") var root_node : NodePath
@export var following_visibility_handler := false

var particles : Array

signal hit
signal destroyed

func _ready() -> void:
    if !particles_scene.is_empty():
        for p in 3:
            particles.append( load( particles_scene ).instantiate() )

func _process(_delta) -> void:
    if following_visibility_handler:
        $"VisibilityHandler/VisibleOnScreenEnabler2D".global_position = global_position
        $"VisibilityHandler/VisibleOnScreenEnabler2D".global_rotation = global_rotation

func damage(power : float) -> void:
    if !invincible:
        print( dbg.value_is( "damage", power ) )
        emit_particles()
        health -= power

    hit.emit()

    if health <= 0:
        destroyed.emit()
        get_node( root_node ).queue_free()

func emit_particles() -> void:
    if particles.size() > 0:
        particles[0].custom_init_pos = true
        particles[0].init_pos = global_position
        Global.layer_dict[ "Objects/Particles" ].add_child( particles[0] )
        particles.remove_at(0)

func _on_free_timer_timeout() -> void:
    get_node(root_node).queue_free()
