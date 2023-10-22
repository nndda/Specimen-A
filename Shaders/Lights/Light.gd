extends Node2D

func flick() -> void: if visible:
    $AnimationPlayer.play( "Flick_" + str( [ 0, 1 ].pick_random() ) )

func _on_tree_entered():
    glbl.connect( "camera_shaken_by_player", Callable( self, "flick" ) )

func _on_tree_exiting():
    print(self.get_name(), " exiting...")


