extends Node2D

@onready var light : PointLight2D = $PointLight2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    visibility_changed.connect(toggle_light)
    Global.camera_shaken_by_player.connect(flick)

func toggle_light() -> void:
    light.enabled = visible

func flick() -> void:
    if visible:
        if global_position.distance_to(Global.head_pos) <= 380.0:
            animation_player.speed_scale = randf_range(0.9, 1.2)
            animation_player.play(&"Flick_%d" % randi_range(0, 1))
