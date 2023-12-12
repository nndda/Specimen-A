extends CPUParticles2D

@export var stay := false

@export\
var custom_init_pos := false
var init_pos : Vector2

@onready var copytimer := Timer.new()

func emit() -> void:
    visible = true
    copytimer.start(lifetime - 0.05)
    emitting = true

func _ready() -> void:

    if custom_init_pos:
        global_position = init_pos

    copytimer.\
    one_shot = stay
    one_shot = stay
    add_child(copytimer)

    emit()

func _process(_delta : float) -> void:
    if emitting:
        if stay:
            speed_scale = copytimer.time_left / copytimer.wait_time

        if speed_scale == 0:
            #copytimer.queue_free()
            process_mode = Node.PROCESS_MODE_DISABLED
            set_script(null)
