extends Area2D

# Trigger entities in contact of player

@onready var root : Node = get_parent()

@export var get_entities_from_parent := false
@export var entities : Array[Node] = []

var player_entered := false

func _ready():
    body_entered.connect(_on_body_entered)

    await root.ready
    entities = validate_entities(entities)

    if get_entities_from_parent:
        entities.append_array(
            validate_entities(root.get_children())
        )

func trigger() -> void:
    if !player_entered:
        player_entered = true
        body_entered.disconnect(_on_body_entered)
        alert()

func _on_body_entered(body : Node2D) -> void:
    if body.name == Global.PLAYER_HEAD_NAME:
        trigger()

func validate_entities(entities_list : Array[Node]) -> Array[Node]:
    var valid_entities : Array[Node] = []

    for entity in entities_list:
        if entity.is_in_group(&"entity"):
            entity.manual_trigger = true
            valid_entities.append(entity)

    return valid_entities

func alert() -> void:
    for entity : Node in entities:
        if entity != null:
            entity.triggered.emit()

    entities.clear()
    queue_free()
