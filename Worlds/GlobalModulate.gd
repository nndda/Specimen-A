extends CanvasModulate

signal color_changed(col : Color)

func _set(property: StringName, value: Variant) -> bool:
    if property == &"color":
        color = value
        color_changed.emit(value)
    return true
