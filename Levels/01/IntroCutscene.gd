extends Node


func _ready():
	pass


func _on_Intro_animation_finished(anim_name):
	if anim_name == "Intro":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
