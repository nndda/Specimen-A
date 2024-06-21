extends Node2D

#@export var color_active : Color = Color("#f49e1d")
#@export var color_ready : Color = Color("#f21115")

@onready var ray_cast : RayCast2D = $RayCast2D
@onready var ray_cast_mark : Marker2D = $Marker2D
@onready var laser_line : Line2D = $Line2D

func _process(_delta: float) -> void:
    if visible:
        if ray_cast.is_colliding():
            ray_cast_mark.global_position = ray_cast.get_collision_point()
            laser_line.points[1] = ray_cast_mark.position
        else:
            laser_line.points[1].x = 384.0
