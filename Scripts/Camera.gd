extends Camera2D

var shaking = false

var shake_power : float

func ShakeStart( power:float, time:float = 0.8, frequency:float = 16 ) -> void:
	if power >= shake_power:
		shake_power = power
		$ShakeTween/Duration.start(time)
		$ShakeTween/Frequency.start(1/frequency)


func Shake() -> void:
	randomize()
	$ShakeTween.interpolate_property(
		self, "offset", self.offset,
		Vector2(
			rand_range(-shake_power,shake_power),
			rand_range(-shake_power,shake_power)
			)
			* ($ShakeTween/Duration.time_left / $ShakeTween/Duration.wait_time)
			, $ShakeTween/Frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT
		)
	$ShakeTween.start()

var following = true

func _ready():
	glbl.camera = self
func _process(_delta):
	if following:
		global_position = glbl.head_pos

		offset_h = range_lerp( get_viewport().get_mouse_position().x, 0.0, get_viewport_rect().size.x, -1.0, 1.0 )
		offset_v = range_lerp( get_viewport().get_mouse_position().y, 0.0, get_viewport_rect().size.y, -1.0, 1.0 )

func _on_Frequency_timeout():
	Shake()
func _on_Duration_timeout():
	shake_power = 0
	$ShakeTween/Frequency.stop()
