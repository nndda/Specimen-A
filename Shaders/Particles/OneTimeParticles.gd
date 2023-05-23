extends GPUParticles2D

var free_timer : Timer = Timer.new()

#func _enter_tree() -> void:
#	emitting = true

func _ready() -> void:
    show()
    emitting = true


    call_deferred( "add_child", free_timer )
    free_timer.start( lifetime )
    free_timer.connect( "timeout", Callable( self, "killParticle" ) )

func killParticle() -> void:
    self.queue_free()
