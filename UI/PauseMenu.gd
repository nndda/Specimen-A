extends CanvasLayer

var paused : bool = false

func _enter_tree():
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _input(event):
    if event.is_action_pressed(&"Pause"):
        paused = !paused
        visible = paused
        Input.mouse_mode =\
            Input.MOUSE_MODE_VISIBLE if paused else\
            Input.MOUSE_MODE_CONFINED
