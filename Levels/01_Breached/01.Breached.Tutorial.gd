extends Node2D

@onready var label_breakout := $BreakOut/Label

@onready var breakout_gates : Array[Node2D] = [
    $"../../Objects/Destructibles/Door1_H",
    $"../../Objects/Destructibles/Door1_H2",
    $"../../Objects/Destructibles/Door1_H3",
    $"../../Objects/Destructibles/Door1_H4",
    $"../../Objects/Destructibles/Door1_V",
    $"../../Objects/Destructibles/Door1_V2",
    $"../../Objects/Destructibles/Door1_V3",
    $"../../Objects/Destructibles/Door1_V4",
    $"../../Objects/Destructibles/Main_Gate"
]

func _ready():
    for gate in breakout_gates:
        gate.get_node(^"DestructiblesBody").destroyed.connect(hint_breakout_clear)

    for marker in $BreakOut.get_children():
        if marker is Marker2D:
            marker.get_node(^"Area2D").body_entered.\
                connect(hint_breakout.bind(marker))

func hint_breakout(body : Node2D, source : Marker2D) -> void:
    if body == Global.player_physics_head:
        label_breakout.position = source.position
        label_breakout.global_rotation = source.global_rotation

func hint_breakout_clear() -> void:
    for gate in breakout_gates:
        gate.get_node(^"DestructiblesBody").destroyed.disconnect(hint_breakout_clear)
    $BreakOut.queue_free()
