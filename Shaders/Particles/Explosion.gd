extends GPUParticles2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func explode() -> void:
    animation_player.play(&"explode")
