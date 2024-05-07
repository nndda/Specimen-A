extends Area2D

var damage_min : float = 10.0
var damage_max : float = 16.0

signal triggered

@onready var explosion_particles : GPUParticles2D = $Explosion
@onready var shards : CPUParticles2D = preload(
    "res://Shaders/Particles/GlassShardsSparks.tscn"
).instantiate()

func trigger() -> void:
    Camera.shake_start(35.0, 0.95, 36.0)
    explosion_particles.explode()

    $AnimationPlayer.play(&"Detonate")
    triggered.emit()
    add_child(shards)

func _on_body_entered(body : Node2D) -> void:
    if body.get_name() == &"Head":
        trigger()
        body.damage_player(20.0)

func _on_animation_finished(anim_name : StringName) -> void:
    if anim_name == &"Detonate":
        for n : Node in [
            $Sprite2D,
            $IdleLights,
        ]:
            n.queue_free()

