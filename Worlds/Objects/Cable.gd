extends Line2D

@export var lights := false

func _ready() -> void:
    if !lights:
        $Light.queue_free()
        set_script(null)
    else:
        $Light.points = points

func lights_off() -> void:
    if lights:
        lights = false
        $Light.queue_free()
        set_script(null)
