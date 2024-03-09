extends Area2D

#var lines_of_fire : Array[RayCast2D] = []
#var fragments_path : Array[Line2D] = []
#var fragments_spark : Array[GPUParticles2D] = []

var damage_min : float = 8.0
var damage_max : float = 12.0

signal triggered

@onready var explosion_particles : GPUParticles2D = $Explosion
@onready var shards : CPUParticles2D = preload(
    "res://Shaders/Particles/GlassShardsSparks.tscn").instantiate()

func trigger() -> void:
    Camera.shake_start(35.0, 0.95, 36.0)
    explosion_particles.explode()

    $AnimationPlayer.play(&"Detonate")
    triggered.emit()
    for n : Node in [
        $Sprite2D,
        $IdleLights,
    ]:
        n.queue_free()
    add_child(shards)

func _on_body_entered(body : Node2D) -> void:
    if body.get_name() == &"Head":
        trigger()
        body.damage_player(20.0)
