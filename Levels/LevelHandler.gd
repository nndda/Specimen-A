extends Node2D


func _ready():
	$"Tile-Wall_3D".GenerateLayers()

#	if get_tree().has_group("SHOW"):
#		for dbg in get_tree().get_nodes_in_group("SHOW"):
#			if dbg is Node2D:
#				if !dbg.visible:
#					print(dbg)
#					dbg.show()
#				dbg.show()
#			dbg.visible = true
	RemoveEditorItems()
	glbl.gameplay_ui_layer = $UI

func RemoveEditorItems() -> void:
	if get_tree().has_group("DBG"):
		for dbg in get_tree().get_nodes_in_group("DBG"):
			dbg.queue_free()
