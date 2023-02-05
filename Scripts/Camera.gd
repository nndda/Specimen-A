extends Camera2D

func _process(_delta):
	global_position = glbl.head_pos
	offset_h = clamp( (get_global_mouse_position().x - self.global_position.x) / 174 , -1 , 1 )
	offset_v = clamp( (get_global_mouse_position().y - self.global_position.y) / 125 , -1 , 1 )
