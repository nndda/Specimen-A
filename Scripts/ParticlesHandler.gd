extends CPUParticles2D

export(bool) var stay = false

onready var copytimer = Timer.new()
func _ready():
	one_shot = stay
	copytimer.one_shot = stay
	copytimer.wait_time = lifetime# * speed_scale + 0.1
	self.add_child(copytimer)
	emitting = true

var ot = true

func _process(_delta):
	if emitting:

		if ot:
			copytimer.start(lifetime)
			ot = false

		if stay:
			speed_scale = copytimer.time_left / copytimer.wait_time
