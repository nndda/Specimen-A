extends GPUParticles2D

var free_timer : Timer

func _enter_tree() -> void:
    set_script(null)
    free_timer = Timer.new()
    add_child(free_timer)

func _ready() -> void:
    show()
    emitting = true

    free_timer.ready.connect(init_free_timer)
    call_deferred(&"add_child", free_timer)

func init_free_timer() -> void:
    free_timer.start(lifetime)
    free_timer.timeout.connect(queue_free)
