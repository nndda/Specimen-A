extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_timer_bg_anim():
	randomize()
	$Body/AnimationPlayer/Timer.start(rand_range(1.2,2.8))
func _on_Timer_timeout():
	$Body/AnimationPlayer.play("Flick")
	set_timer_bg_anim()
