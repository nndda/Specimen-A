extends Node2D

@export_node_path("Node") var root_
@onready var root : Node = get_node( root_ )

func _ready():  if root.immune != null: root.immune = true
func _exit_tree(): if root.immune != null: root.immune = false
