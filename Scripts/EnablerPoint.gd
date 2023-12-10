extends Area2D

@onready var root : Node = get_parent()

@export\
var items_path : Array[NodePath] = []
var items : Array[Node] = []

var player_entered := false

func _ready():
    body_entered.connect(_on_body_entered)
    root.ready.connect(func():
        for item : NodePath in items_path:
            items.append(get_node(item))
    )

func _on_body_entered(body : Node2D) -> void:
    if body.get_name() == &"Head":
        if !player_entered:
            player_entered = true
        enable()

func enable() -> void:
    for item : Node in items:
        item.process_mode = Node.PROCESS_MODE_INHERIT
    queue_free()
