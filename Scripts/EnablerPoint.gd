extends Area2D

@onready var root : Node = get_parent()

@export var disable_parent := false
@export var hide_parent := false
@export var items_path : Array[NodePath] = []
var items : Array[Node] = []

var player_entered := false

func _ready():
    body_entered.connect(_on_body_entered)
    root.ready.connect(initialize_objects)

func initialize_objects() -> void:
    for item : NodePath in items_path:
        items.append(get_node(item))
    if disable_parent:
        root.process_mode = Node.PROCESS_MODE_DISABLED
        call_deferred(&"reparent", get_node(^"../../"))
    if hide_parent:
        if root is CanvasItem:
            root.visible = false

func _on_body_entered(body : Node2D) -> void:
    if body.name == &"Head":
        if !player_entered:
            player_entered = true
        enable()

func enable() -> void:
    if disable_parent:
        root.process_mode = Node.PROCESS_MODE_INHERIT
    if hide_parent:
        if root is CanvasItem:
            root.visible = true
    for item : Node in items:
        item.process_mode = Node.PROCESS_MODE_INHERIT
    queue_free()
