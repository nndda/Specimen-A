extends Node2D


func _ready():
#	pass
	$"Tile-Wall".occluder_light_mask = 0
	$"Tile-Wall_3D".GenerateLayers()
#	$PostFX.show()
	$TopLayer.follow_viewport_scale = glbl.top_scale
	RemoveEditorItems()
	
#func _process(_delta):
#	$Entities/Label.text = str($"Player/Head".invincible)

func RemoveEditorItems() -> void:
	if get_tree().has_group("DBG"):
		for dbg in get_tree().get_nodes_in_group("DBG"):
			dbg.queue_free()
