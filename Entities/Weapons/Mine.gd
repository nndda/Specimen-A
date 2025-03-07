extends Area2D

@export var damage_min : float = 35.0
@export var damage_max : float = 45.0

signal triggered

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var explosion_particles : GPUParticles2D = $Explosion

func trigger() -> void:
    animation_player.play(&"RESET")
    Camera.shake_start(35.0, 0.95, 36.0)
    explosion_particles.explode()

    $AnimationPlayer.play(&"Detonate")
    triggered.emit()

    for n in get_overlapping_bodies():
        if n.is_in_group(&"entity"):
            n.kill()

    var shards : ParticlesHandler = (
        load("res://Shaders/Particles/GlassShardsSparks.tscn") as PackedScene
    ).instantiate()

    shards.amount = 12
    shards.init_pos = global_position

    add_child(shards)

func _ready() -> void:
    animation_player.stop()
    var anim_offset_timer : Timer = $AnimationPlayer/OffsetTimer

    anim_offset_timer.timeout.connect(
        animation_player.play.bind(&"Idle")
    )
    anim_offset_timer.timeout.connect(
        anim_offset_timer.queue_free, CONNECT_DEFERRED
    )
    anim_offset_timer.start(randf_range(0.7, 2.1))

func _on_body_entered(body : Node2D) -> void:
    if body.name == Global.PLAYER_HEAD_NAME:
        trigger()
        body_entered.disconnect(_on_body_entered)
        body.damage_player(randf_range(damage_min, damage_max))

func _on_animation_finished(anim_name : StringName) -> void:    
    animation_player = null
    explosion_particles = null

    if anim_name == &"Detonate":
        for n : Node in [
            $Sprite2D,
            $IdleLights,
            $ExplosionLight,
            $AnimationPlayer,
        ]:
            n.queue_free()

    set_script(null)
