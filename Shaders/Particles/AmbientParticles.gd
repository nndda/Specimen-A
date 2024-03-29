extends GPUParticles2D

func _ready() -> void:
    $ColorRect.queue_free()

func _process(_delta : float) -> void:
    global_position = Global.head_pos
