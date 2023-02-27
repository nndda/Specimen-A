extends Area2D

var ot = true

func _on_NextArea_body_entered(body):
	if body.get_name() == "Head":
#		get_tree().change_scene("res://Levels/02/02.tscn")
		if ot:
			$"../TopLayer2/ColorRect/AnimationPlayer".play("Outro")
			ot = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Outro":
		get_tree().change_scene("res://Levels/02/02.tscn")
