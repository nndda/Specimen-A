extends Node2D

func _enter_tree():
	glbl.current_scene = self

func _ready():
	add_child(
		preload(
			"res://Worlds/GlobalModulate.tscn"
			).instantiate()
	)
	glbl.update_layers()
	for layer in glbl.layer:
		dbg.print_header(str(self),str(layer))
		for inst in self.get_node(layer).get_children():
			if inst is InstancePlaceholder:
				printt(
					"|", str(Time.get_datetime_string_from_system(false,true)," Instancing: " + str(inst))
					)
				inst.create_instance()
		print()



#
#@export_category("Dialogue")
#@export_multiline var dialogue_lines : Array[String]

#func _ready():
#	for dbg_itm in get_tree().get_nodes_in_group("DBG"):
#		dbg_itm.queue_free()































#@export var character : Array[chr]

#@export_category	("Interractable")
#@export var			one_time = false
#@export_file("*.txt") var dialogue_file
#
#@export_group("Return") 
#@export var Give_Item : bool = false
#@export var Item : glbl.item_id
#@export var Give_Signal : bool = false
#@export var Signal_ : String
#
#@export_category("Gate/Door")
#@export_node_path("Node2D") var destination
#@export var Locked = false
#@export var key = glbl.item_id







