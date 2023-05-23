extends Node2D
func _ready() -> void: $VisibilityHandler.show()
func _process( _delta ) -> void:
    if $PointLight2D.visible: if glbl.is_shake_by_player:
        $AnimationPlayer.play( "Flick_" + str( [ 0, 1 ].pick_random() ) )
