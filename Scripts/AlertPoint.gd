extends Area2D

@onready var root : Node = get_parent()

@export\
var items_path : Array[NodePath] = []
var items : Array[Node] = []

var player_entered := false

func _ready():
    body_entered.connect(_on_body_entered)

    await root.ready
    for item : NodePath in items_path:
        var node : Node = get_node(item)
        if !node.has_signal(&"triggered"):
            push_error("Item %s does not have `triggered` signal" % str(node))
        else:
            items.append(node)

func _on_body_entered(body : Node2D) -> void:
    if body.name == &"Head":
        if !player_entered:
            player_entered = true
        alert()

func alert() -> void:
    for item : Node in items:
        if item != null:
            item.triggered.emit()
    queue_free()
