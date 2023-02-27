extends Area2D

var ot = true

func _on_NextArea_body_entered(body):
	if body.get_name() == "Head":
#		get_tree().change_scene("res://Levels/02/02.tscn")
		if ot:
			$"../PostFX/FadeOut/AnimationPlayer".play("FadeOut")
			ot = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Levels/02/02.tscn")
