extends CanvasLayer

func _ready():
	hide()

func _on_TriggerArea_body_entered(body):
	if body.get_name() == "Head":
		show()
