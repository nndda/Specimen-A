extends Area2D

# Enable an area in contact of player

@onready var parent : Node = get_parent()

@export_category("Parent")
@export var disable_parent := false
@export var hide_parent := false

@export_category("Items")
@export var hide_items := true
@export var items_path : Array[Node] = []
var items : Array[Node] = []

var player_entered := false

func _enter_tree() -> void:
    get_parent().ready.connect(initialize_objects)

func _ready():
    body_entered.connect(_on_body_entered)

func initialize_objects() -> void:
    for idx : int in items_path.size():
        if items_path[idx] != null:
            if !items_path[idx].is_in_group(&"free"):
                items.append(items_path[idx])
        else:
            push_error("Error - null item")

    if disable_parent:
        parent.process_mode = Node.PROCESS_MODE_DISABLED
        call_deferred(&"reparent", get_node(^"../../"))

    if hide_parent and parent is CanvasItem:
        parent.visible = false

    for item in items:
        item.process_mode = Node.PROCESS_MODE_DISABLED
        if hide_items and item is CanvasItem:
            item.visible = false

func _on_body_entered(body : Node2D) -> void:
    if body.name == &"Head":
        if !player_entered:
            player_entered = true

        enable()

func enable() -> void:
    if disable_parent:
        parent.process_mode = Node.PROCESS_MODE_INHERIT

    if hide_parent:
        if parent is CanvasItem:
            parent.visible = true

    for item : Node in items:
        if item != null:
            item.process_mode = Node.PROCESS_MODE_INHERIT
            if hide_items and item is CanvasItem:
                item.visible = true

    items_path.clear()
    items.clear()

    queue_free()
