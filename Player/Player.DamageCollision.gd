extends Area2D

func damage_player(power:float) -> void:
    var power_shielded = power * 0.08
    $"../Head".damage_player(power_shielded)
