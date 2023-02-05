extends Node2D


func _ready():
#	pass
	$"Tile-Wall".occluder_light_mask = 0
	$"Tile-Wall_3D".GenerateLayers()
	$PostFX.show()
	
