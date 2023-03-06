extends Camera2D

#func _on_tree_entered():
#	glbl.camera = self

@onready var shake_tween = create_tween().bind_node(self)

var shaking		: bool = false
var shake_power	: float = 0.0

func ShakeStart( power:float, time:float = 0.8, frequency:float = 16 ) -> void:
	if power >= shake_power:
		shake_power = power
		shaking = true
		$Shake/Duration.start(time)
		$Shake/Frequency.start(1/frequency)

func Shake() -> void:
	randomize()

	shake_tween.tween_property(
		self, "offset", Vector2(
			randf_range(-shake_power,shake_power),
			randf_range(-shake_power,shake_power)
			)
			* ($Shake/Duration.time_left / $Shake/Duration.wait_time),
		$Shake/Frequency.wait_time
	)
	shake_tween.set_trans( Tween.TRANS_SINE )
	shake_tween.set_ease( Tween.EASE_IN_OUT )

	shake_tween.play()


var following = true


func _process(_delta):
	if following:

		global_position = glbl.head_pos

		drag_horizontal_offset = remap(
			get_viewport().get_mouse_position().x,
			0.0, get_viewport_rect().size.x,
			-1.0, 1.0 )
		drag_vertical_offset = remap(
			get_viewport().get_mouse_position().y,
			0.0, get_viewport_rect().size.y,
			-1.0, 1.0 )


func _on_Frequency_timeout():
	Shake()
func _on_Duration_timeout():
	shake_power = 0
	shaking = false
	$ShakeTween/Frequency.stop()
