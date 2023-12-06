extends Area2D

@onready var head := $"../Head"

func damage_player(power : float) -> void:
    head.damage_player(power * 0.02)
