extends CanvasLayer

var paused := false
@onready var level_root := $".."

@onready var level_name := $Control/Area/LevelName
@onready var level_sub := $Control/Area/LevelName/Sub

func _enter_tree() -> void:
    visible =false
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _input(event : InputEvent) -> void:
    if event.is_action_pressed(&"Pause"):
        paused = !paused
        visible = paused
        Camera.paused = paused
        Global.current_scene.process_mode =\
            Node.PROCESS_MODE_DISABLED if paused else\
            Node.PROCESS_MODE_INHERIT
        Input.mouse_mode =\
            Input.MOUSE_MODE_VISIBLE if paused else\
            Input.MOUSE_MODE_CONFINED

func _ready() -> void:
    level_name.text = level_root.level_name
    level_sub.text = ""
