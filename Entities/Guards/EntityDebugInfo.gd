extends CanvasLayer

@onready var ui_container : Control = $PanelContainer
@onready var item_container : Control = $PanelContainer/MarginContainer/VBoxContainer/Items
@onready var entity : CharacterBody2D = get_parent()
var data : Dictionary = {}

func _ready() -> void:
    for item in item_container.get_children():
        if item is Label:
            data[StringName(item.name)] = item

func _process(_delta: float) -> void:
    ui_container.position = entity.position

    for n in data:
        var value = entity.get(n)

        if value is float:
            value = snappedf(value, 0.01)
        elif value is bool:
            if value:
                data[n].modulate = Color.CYAN
            else:
                data[n].modulate = Color.HOT_PINK

        (data[n] as Label).text = "%s: %s" % [n, str(value)]

func toggle_visibility() -> void:
    item_container.visible = !item_container.visible
