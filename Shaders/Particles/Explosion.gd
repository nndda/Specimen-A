extends GPUParticles2D

@export var leave_trace := true
@onready var trace_sprite : Sprite2D = $Sprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    trace_sprite.visible = false

func explode() -> void:
    animation_player.play(&"explode")
    trace_sprite.visible = true
