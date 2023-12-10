extends GPUParticles2D

@onready var free_timer := Timer.new()

func _ready() -> void:
    show()
    emitting = true

    free_timer.ready.connect(func():
        free_timer.start(lifetime)
        free_timer.timeout.connect(queue_free)
    )
    call_deferred(&"add_child", free_timer)
