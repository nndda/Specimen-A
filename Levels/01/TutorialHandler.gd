extends Node2D

func _ready():
	$"../TutorialScreen/Control/VBoxContainer/Moving".hide()
	$"../TutorialScreen/Control/VBoxContainer/Attacking".hide()

func _on_MovingConfirmArea_body_entered(body):
	if body.get_name() == "Head":
		$MovingConfirmArea.queue_free()
		$"../TutorialScreen/Control/VBoxContainer/Attacking".show()


func _on_AttackingConfirmArea_body_entered(body):
	if body.get_name() == "Head":
		$AttackingConfirmArea.queue_free()
		$"../TutorialScreen".queue_free()
