extends Camera2D

# A scene to propagate Camera.copy_camera() function

@export var auto_disable := false
@export var manual_trigger := false

@onready var trigger_start_area : Area2D = $TriggerStart
@onready var trigger_stop_area : Area2D = $TriggerStop

func _ready() -> void:
    $ReferenceRect.queue_free()
    if manual_trigger:
        trigger_start_area.queue_free()
        trigger_stop_area.queue_free()

func start_cutscene() -> void:
    Camera.copy_camera(self, auto_disable)

func stop_custscene() -> void:
    Camera.copy_camera_reset()
    queue_free()

func _on_trigger_start_body_entered(body : Node2D) -> void:
    if body.get_name() == &"Head":
        start_cutscene()

func _on_trigger_stop_body_entered(body : Node2D) -> void:
    if body.get_name() == &"Head":
        stop_custscene()
