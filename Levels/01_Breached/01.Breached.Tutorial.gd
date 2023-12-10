extends Node2D

@export var strict := false

@export_node_path("Label") var hint_move_a_ : NodePath; @onready var hint_move_a := get_node(hint_move_a_)
@export_node_path("Label") var hint_move_b_ : NodePath; @onready var hint_move_b := get_node(hint_move_b_)
@export_node_path("Label") var hint_attack_a_ : NodePath; @onready var hint_attack_a := get_node(hint_attack_a_)
@export_node_path("Label") var hint_attack_b_ : NodePath; @onready var hint_attack_b := get_node(hint_attack_b_)

@onready var hint_move_anim := $BasicControls/HintMove/AnimationPlayer
@onready var hint_attack_anim := $BasicControls/HintAttack/AnimationPlayer

@onready var label_breakout := $BreakOut/Label
@onready var breakout_gates : Array[Node2D] = [
    $"../../Areas/Inner Cage/Gates/Door1_H",
    $"../../Areas/Inner Cage/Gates/Door1_H2",
    $"../../Areas/Inner Cage/Gates/Door1_H3",
    $"../../Areas/Inner Cage/Gates/Door1_H4",
    $"../../Areas/Inner Cage/Gates/Door1_V",
    $"../../Areas/Inner Cage/Gates/Door1_V2",
    $"../../Areas/Inner Cage/Gates/Door1_V3",
    $"../../Areas/Inner Cage/Gates/Door1_V4",
]

func action_string(input : InputEvent) -> String:
    return input.as_text().rstrip(" Button").rstrip(" (Physical)")

func _ready():
    Camera.fade_out.connect(func():\
        hint_move_anim.play(&"FadeIn"))

    #hint_attack_anim.animation_finished.connect(func(anim_name):\
        #if anim_name == &"FadeOut": queue_free())

    $BreakOut.visible = false
    if strict:
        Global.player.allow_attack = false

    hint_move_a.text = action_string(InputMap.action_get_events(&"Move")[0])
    hint_move_b.text = action_string(InputMap.action_get_events(&"Move")[1])
    hint_attack_a.text = action_string(InputMap.action_get_events(&"Attack")[0])
    hint_attack_b.text = action_string(InputMap.action_get_events(&"Attack")[1])

    for gate : Node2D in breakout_gates:
        gate.get_node(^"DestructiblesBody").destroyed.connect(hint_breakout_clear)

    for marker : Node in $BreakOut.get_children():
        if marker is Marker2D:
            marker.get_node(^"Area2D").body_entered.\
                connect(hint_breakout.bind(marker))
            print("\n",marker.get_node(^"Area2D"),marker.get_node(^"Area2D").get_signal_connection_list(&"body_entered"))

func hint_breakout(body : Node2D, source : Marker2D) -> void:
    if body == Global.player_physics_head:
        label_breakout.position = source.position
        label_breakout.global_rotation = source.global_rotation

func hint_breakout_clear() -> void:
    for gate : Node2D in breakout_gates:
        gate.get_node(^"DestructiblesBody").destroyed.disconnect(hint_breakout_clear)
    $BreakOut.queue_free()
    hint_attack_anim.play(&"FadeOut")

func _on_HintMoveRemove_body_exited(body : Node2D) -> void:
    if body.get_name() == &"Head":
        $BasicControls/HintMove/Timer.start()
        $HintMoveRemove.queue_free()

func _on_HintMove_timeout():
    hint_move_anim.play(&"FadeOut")
    hint_attack_anim.play(&"FadeIn")
    if strict:
        Global.player.allow_attack = true
    $BreakOut.visible = true


func _on_HintAttack_animation_finished(anim_name : StringName) -> void:
    if anim_name == &"FadeOut":
        #self.call_deferred(&"queue_free")
        pass
