extends Area2D

# Put directly below light's parent

export(NodePath) var light

func _ready():
	$Timer.start(rand_range(120.0,600.0))

func _process(_delta):
	get_node(light).shadow_enabled = !glbl.cfg.optimal_graphic

func _on_self_area_entered(area):
	if area.get_name() == "AreaShake":
		Flick()
func _on_self_body_entered(_body):
	pass # Replace with function body.

func Flick() -> void:
	$Timer.start(rand_range(120.0,600.0))
	if randf() > 0.5:
		$AnimationPlayer.play("Flick")
	else:
		$AnimationPlayer.play("Flick2")

func _on_Timer_timeout():
	$Timer.start(rand_range(120.0,600.0))
	Flick()
