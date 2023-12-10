extends Area2D

@export\
var entities_path : Array[NodePath] = []
var entities : Array[Node] = []

var player_entered := false

func _ready():
    for entity : NodePath in entities_path:
        entities.append(get_node(entity))

func _on_body_entered(body : Node2D) -> void:
    if body.get_name() == &"Head":
        if !player_entered:
            player_entered = true

            for entity : Node in entities:
                entity.process_mode = Node.PROCESS_MODE_INHERIT

            queue_free()
