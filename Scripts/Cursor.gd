extends Node2D

@onready var viewport := get_viewport()

@export var cursor_sprite : Sprite2D

#var mouse_global_position : Vector2
var mouse_viewport_position : Vector2

func _process(_delta: float) -> void:
    #mouse_global_position = get_global_mouse_position()
    mouse_viewport_position = viewport.get_mouse_position()

    cursor_sprite.global_position = mouse_viewport_position

    #if Global.player_physics_head != null:
        #cursor_sprite.look_at(Global.player_physics_head.global_position)
