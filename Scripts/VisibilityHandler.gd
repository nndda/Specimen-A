extends Node

@export var set_process_mode_to : Node.ProcessMode = Node.PROCESS_MODE_INHERIT
@export_node_path("CanvasItem") var root_path : NodePath
@onready var root : CanvasItem = get_parent() if root_path.is_empty() else get_node( root_path )

func _ready():
    $VisibleOnScreenEnabler2D.global_position = root.global_position
    $VisibleOnScreenEnabler2D.global_rotation = root.global_rotation
    $VisibleOnScreenEnabler2D.screen_entered.connect(_on_screen_entered)
    $VisibleOnScreenEnabler2D.screen_exited.connect(_on_screen_exited)
    root.visible = false
    root.process_mode = set_process_mode_to

func _on_screen_entered():
    root.visible = true
    root.process_mode = Node.PROCESS_MODE_INHERIT

func _on_screen_exited():
    root.visible = false
    root.process_mode = set_process_mode_to
