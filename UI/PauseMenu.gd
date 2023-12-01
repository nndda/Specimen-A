extends CanvasLayer

var paused : bool = false
@onready var level_root : Node2D = $".."

func _enter_tree():
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _input(event):
    if event.is_action_pressed(&"Pause"):
        paused = !paused
        visible = paused
        Camera.paused = paused
        Input.mouse_mode =\
            Input.MOUSE_MODE_VISIBLE if paused else\
            Input.MOUSE_MODE_CONFINED

func _ready():
    $Control/LevelName.text = level_root.level_name
