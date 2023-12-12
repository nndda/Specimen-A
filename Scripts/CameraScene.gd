extends Camera2D

# A scene to propagate Camera.copy_camera() function

@export var auto_disable := false
@export var manual_trigger := false

func _ready() -> void:
    $ReferenceRect.queue_free()
    if !manual_trigger:
        $TriggerStart.body_entered.connect(func(body : Node2D):
            if body.get_name() == &"Head":
                start_cutscne()
        )
        $TriggerStop.body_entered.connect(func(body : Node2D):
            if body.get_name() == &"Head":
                stop_custscene()
        )
    else:
        $TriggerStart.queue_free()
        $TriggerStop.queue_free()

func start_cutscne() -> void:
    Camera.copy_camera(self, auto_disable)

func stop_custscene() -> void:
    Camera.copy_camera_reset()
    queue_free()
