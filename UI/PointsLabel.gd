extends Label

export(Vector2) var init_pos

func _ready():
	randomize()
#	if get_parent().get_child_count() >= 3:
#		get_parent().get_child(0).call_deferred("queue_free")
	rect_global_position = init_pos + Vector2(
		rand_range(-8,8),
		rand_range(-4,4)
	)
	$Tween.interpolate_property(
		self, "rect_global_position:y", rect_global_position.y, rect_global_position.y - rand_range(32,48), 1.0, Tween.TRANS_SINE, Tween.EASE_OUT_IN
	)
	$Tween.start()
