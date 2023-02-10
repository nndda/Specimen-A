extends Area2D

func DamagePlayer(power:float) -> void:
	var power_shielded = power * 0.15
	$"../Head".DamagePlayer(power_shielded)
