extends CPUParticles2D

@export var stay := false

@export\
var custom_init_pos := false
var init_pos : Vector2

@onready var copytimer : Timer = $CopyTimer

func emit() -> void:
    visible = true
    if stay:
        copytimer.start(lifetime - 0.05)
    emitting = true

func _ready() -> void:
    if stay:
        if copytimer == null:
            push_error("No copytimer Timer on particles with stay=true at: ",
                get_path()
            )
            stay = false
        else:
            copytimer.one_shot = true

    one_shot = true

    if custom_init_pos:
        global_position = init_pos

    emit()

func _process(_delta : float) -> void:
    if emitting:
        if stay:
            speed_scale = copytimer.time_left / copytimer.wait_time

        if speed_scale == 0:
            process_mode = Node.PROCESS_MODE_DISABLED
            if stay:
                copytimer.queue_free()
            set_script(null)
