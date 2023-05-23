extends Node2D

@export var stay : bool = false

@export var custom_init_pos : bool = false
var init_pos : Vector2

@onready var copytimer : Timer = Timer.new()
#func _enter_tree():
#	var one_shot_v : bool
#	var lifetime_v : float
#	var emitting : bool

#func _enter_tree():

func _ready():

#	if get_parent() != glbl.layer_dict["Objects/Particles"]:
#		$VisibleOnScreenEnabler2D.queue_free()
    self.show()

    if custom_init_pos: global_position = init_pos

    self.one_shot = stay
    copytimer.one_shot = stay
    copytimer.wait_time = self.lifetime * self.speed_scale + 0.05
    self.add_child( copytimer )
    self.emitting = true

var ot : bool = true

func _process( _delta ) -> void:
    if self.emitting:

        if ot:
            copytimer.start(self.lifetime)
            ot = false

        if stay: self.speed_scale = copytimer.time_left / copytimer.wait_time

    if self.speed_scale == 0: self.process_mode = Node.PROCESS_MODE_DISABLED
