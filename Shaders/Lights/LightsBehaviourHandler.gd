extends Area2D

# Put directly below light's parent

func _ready():
#	$AnimationPlayer.root_node = $AnimationPlayer.get_path_to(get_parent())
	$Timer.start(rand_range(120.0,600.0))
#	$Timer.start(rand_range(2.0,6.0))


func _on_self_area_entered(_area):
	pass # Replace with function body.
func _on_self_body_entered(_body):
	pass # Replace with function body.


func _on_Timer_timeout():
	$Timer.start(rand_range(120.0,600.0))
#	$Timer.start(rand_range(4.0,6.0))
	$AnimationPlayer.play("Flick")
