extends Node2D

@onready var light : PointLight2D = $PointLight2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var visibility_handler : Node = $VisibilityHandler

var energy_initial : float = 1.0
var transitioning := false

func _ready() -> void:
    energy_initial = light.energy
    visibility_changed.connect(toggle_light)
    Global.camera_shaken_by_player.connect(flick)

func toggle_light() -> void:
    light.enabled = visible

func kill() -> void:
    $Sprite2D.call_deferred(&"reparent", get_parent())
    queue_free()

func flick(substantial : bool) -> void:
    if visible:
        if !transitioning and substantial:
            if global_position.distance_to(Global.head_pos) <= 380.0:
                animation_player.speed_scale = randf_range(0.9, 1.2)
                animation_player.play(&"Flick_%d" % randi_range(0, 1))

func lights_out() -> void:
    transitioning = true
    animation_player.speed_scale = randf_range(1.0, 1.2)
    animation_player.play(&"LightsOut", 0.1)

func lights_on() -> void:
    animation_player.speed_scale = randf_range(1.0, 1.2)
    animation_player.play(&"LightsOn", 0.1)

    await animation_player.animation_finished
    transitioning = false
    
func disable() -> void:
    visibility_handler.enabler.visible = false
    visible = false
    light.enabled = false
    light.energy = 0.0

func enable() -> void:
    visibility_handler.enabler.visible = true
    visible = true
    light.enabled = true
    light.energy = energy_initial

func offset_anim(anim_name : StringName, anim_player_path : NodePath) -> void:
    var anim_player : AnimationPlayer = get_node(anim_player_path)
    anim_player.stop()

    await get_tree().create_timer(randf_range(0.6,1.8)).timeout
    anim_player.play(anim_name)
