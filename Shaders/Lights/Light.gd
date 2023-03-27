extends Node2D

func _ready(): $VisibilityHandler.show()

func _process(_delta):
	if $PointLight2D.visible:
		if glbl.is_shake_by_player and global_position.distance_to( glbl.head_pos ) <= 300.0:
			if randf() >= 0.5:
				$AnimationPlayer.play("Flick_1")
			else:
				$AnimationPlayer.play("Flick_0")
