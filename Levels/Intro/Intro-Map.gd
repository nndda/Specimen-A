extends Node2D

func _ready() -> void:
    cam.enabled = false
    cam.following = false
#	cam.global_position = $Camera2D.global_position
    $Camera2D.enabled = true
