extends Node2D

@onready var light : PointLight2D = $PointLight2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready():
    connect( "visibility_changed", func(): light.enabled = visible )
    Global.connect( "camera_shaken_by_player", func():\
    if visible:
        if global_position.distance_to( Global.head_pos ) <= 360.0:
            animation_player.play( "Flick_" + [ "0", "1" ].pick_random() ) )
