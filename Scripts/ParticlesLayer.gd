extends CanvasLayer

func _process(_delta):
	$CPUParticles2D.global_position = glbl.head_pos
