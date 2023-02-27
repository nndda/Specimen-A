extends Area2D


func _ready():
	pass


func _on_FinalCutscene_body_entered(body):
	if body.get_name() == "Head":
		$"../Camera2D".following = false
		$"../Camera2D".global_position = $Camera2D.global_position
		
#		$"../Camera2D".current = false
#		$Camera2D.current = true
