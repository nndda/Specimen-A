extends Node2D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	pass
	$"Tile-Wall".occluder_light_mask = 0
	$"Tile-Wall_3D".GenerateLayers()
#	$PostFX.show()
	$TopLayer.follow_viewport_scale = glbl.top_scale
	RemoveEditorItems()
	glbl.gameplay_ui_layer = $UI
	if $UI.get_child_count() >= 3:
		$UI.get_child(0).queue_free()
	
#func _process(_delta):
#	$Entities/Label.text = str($"Player/Head".invincible)

func RemoveEditorItems() -> void:
	show()
	if get_tree().has_group("DBG"):
		for dbg in get_tree().get_nodes_in_group("DBG"):
			dbg.queue_free()
