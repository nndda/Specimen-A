extends Line2D

@export var lights := false
@onready var lights_node : Line2D = $Light

func _ready() -> void:
    if !lights:
        lights_node.queue_free()
        set_script(null)
    else:
        lights_node.points = points

func lights_off() -> void:
    if lights:
        lights = false
        lights_node.queue_free()
        set_script(null)
