extends Node2D


func _ready():
	$"Tile-Wall_3D".GenerateLayers()

	if get_tree().has_group("SHOW"):
		for dbg in get_tree().get_nodes_in_group("SHOW"):
			dbg.show()
	RemoveEditorItems()
	glbl.gameplay_ui_layer = $UI

#func _process(_delta):
#	if $UI.get_child_count() >= 2:
#		$UI.get_child(0).call_deferred("queue_free")

func RemoveEditorItems() -> void:
	if get_tree().has_group("DBG"):
		for dbg in get_tree().get_nodes_in_group("DBG"):
			dbg.queue_free()
