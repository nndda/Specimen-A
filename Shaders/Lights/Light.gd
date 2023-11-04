extends Node2D

func _on_tree_entered():
    connect( "visibility_changed", func(): $PointLight2D.enabled = visible )
    Global.connect( "camera_shaken_by_player", func():\
    if visible:
        if global_position.distance_to( Global.head_pos ) <= 360.0:
            $AnimationPlayer.play( "Flick_" + [ "0", "1" ].pick_random() ) )
