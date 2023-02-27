extends Area2D

func DamagePlayer(power:float) -> void:
	var power_shielded = power * 0.08
	$"../Head".DamagePlayer(power_shielded)
	
