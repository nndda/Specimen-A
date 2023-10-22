extends Node

@export var set_process_mode : Node.ProcessMode = Node.PROCESS_MODE_INHERIT
@export_node_path( "CanvasItem" ) var root_path : NodePath
@onready var root : CanvasItem = get_parent() if root_path.is_empty() else get_node( root_path )

func _on_ready():
    $VisibleOnScreenEnabler2D.global_position = root.global_position
    root.visible = false

func _on_screen_entered():
    root.visible = true
    root.process_mode = Node.PROCESS_MODE_INHERIT

func _on_screen_exited():
    root.visible = false
    root.process_mode = set_process_mode
