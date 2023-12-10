extends Node

@export var set_process_mode_to : Node.ProcessMode = Node.PROCESS_MODE_INHERIT
@export_node_path("CanvasItem") var root_path : NodePath
@onready var root : CanvasItem = get_parent() if root_path.is_empty() else get_node( root_path )
@onready var enabler : VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

func _ready():
    enabler.global_position = root.global_position
    enabler.global_rotation = root.global_rotation
    enabler.screen_entered.connect(_on_screen_entered)
    enabler.screen_exited.connect(_on_screen_exited)
    root.visible = false
    root.process_mode = set_process_mode_to

func _on_screen_entered():
    root.visible = true
    root.process_mode = Node.PROCESS_MODE_INHERIT

func _on_screen_exited():
    root.visible = false
    root.process_mode = set_process_mode_to
