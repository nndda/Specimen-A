extends CPUParticles2D

func _process(_delta):
	self.global_position = Vector2(
		get_global_transform_with_canvas().origin.x,
		get_global_transform_with_canvas().origin.y 
	)
