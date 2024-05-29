extends Polygon2D

@export var area_cover : Area2D
@export var destroy_on_reveal := false

@export_category("Durations")
@export var fade_in_duration : float = 0.5
@export var fade_out_duration : float = 0.5
var visibility_tween : Tween

func _ready() -> void:
    visible = true
    material = material.duplicate()
    fade_in()
    if area_cover != null:
        area_cover.body_entered.connect(_on_area_cover_body_entered)
        area_cover.body_exited.connect(_on_area_cover_body_exited)


func _on_area_cover_body_entered(body : Node2D) -> void:
    if body.name == &"Head":
        fade_out(fade_out_duration)

func _on_area_cover_body_exited(body : Node2D) -> void:
    if body.name == &"Head":
        fade_in(fade_in_duration)


func fade_in(duration : float = 0.5) -> void:
    (material as ShaderMaterial).set_shader_parameter(&"enabled", true)
    visible = true

    visibility_tween = create_tween().bind_node(self)
    visibility_tween.tween_property(
            self, ^"modulate:a", 1.0, duration
        )\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)\
        .from_current()

func fade_out(duration : float = 0.5) -> void:
    visibility_tween = create_tween().bind_node(self)
    visibility_tween.tween_property(
            self, ^"modulate:a", 0.0, duration
        )\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_QUAD)\
        .from_current()

    await visibility_tween.finished
    visible = false
    (material as ShaderMaterial).set_shader_parameter(&"enabled", false)

    if destroy_on_reveal:
        queue_free()
