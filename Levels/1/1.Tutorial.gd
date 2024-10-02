extends Node2D

@export var strict := false
var move_tutorial_finished := false

@onready var pause_menu : CanvasLayer = $"../../PauseMenu"

@export_node_path("Label") var hint_move_a_ : NodePath; @onready var hint_move_a := get_node(hint_move_a_)
@export_node_path("Label") var hint_move_b_ : NodePath; @onready var hint_move_b := get_node(hint_move_b_)
@export_node_path("Label") var hint_attack_a_ : NodePath; @onready var hint_attack_a := get_node(hint_attack_a_)
@export_node_path("Label") var hint_attack_b_ : NodePath; @onready var hint_attack_b := get_node(hint_attack_b_)

@onready var hint_move_timer : Timer = $BasicControls/HintMove/Timer
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

func _enter_tree() -> void:
    if Global.user_data["level_stats"]["tutorial_passed"]:
        process_mode = Node.PROCESS_MODE_DISABLED
        queue_free()

func _ready():
    if process_mode != Node.PROCESS_MODE_DISABLED:
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

        await $"../..".ready
        pause_menu.pause_menu_closed.connect(pause_menu_closed)

        await Camera.faded_out
        hint_move_anim.play(&"FadeIn")

func hint_breakout(body : Node2D, source : Marker2D) -> void:
    if body == Global.player_physics_head:
        label_breakout.position = source.position
        label_breakout.global_rotation = source.global_rotation

@onready var info_stats_stage : Stage = $"../../InfoComms/Containments/DialoguePanel/Stage"
var broken : int = 0

func hint_breakout_clear() -> void:
    if broken <= 0:
        $BreakOut.queue_free()
        hint_attack_anim.play(&"FadeOut")

        var time := Time.get_datetime_dict_from_system()
        info_stats_stage.set_variable(
            "time_breached",
            "%d:%d %d/%d/%s" % [
                time["hour"],
                time["minute"],
                time["day"],
                time["month"],
                "21XX",
            ]
        )

        Global.user_data["level_stats"]["tutorial_passed"] = true
        Global.update_user_data()

    broken += 1
    info_stats_stage.set_variable("count", broken)

func _on_HintMoveRemove_body_exited(body : Node2D) -> void:
    if body.name == Global.PLAYER_HEAD_NAME:
        hint_move_timer.start()
        $HintMoveRemove.queue_free()

func _on_HintMove_timeout():
    hint_move_anim.play(&"FadeOut")
    move_tutorial_finished = true
    hint_attack_anim.play(&"FadeIn")
    if strict:
        Global.player.allow_attack = true
    if $BreakOut != null:
        $BreakOut.visible = true

func _on_HintAttack_animation_finished(anim_name : StringName) -> void:
    if anim_name == &"FadeOut":
        #queue_free()
        pass

func _on_HintRangeAttack_animation_finished(anim_name : StringName) -> void:
    if anim_name == &"FadeOut":
        #queue_free()
        pass

func pause_menu_closed() -> void:
    if !move_tutorial_finished:
        if hint_move_timer.process_mode == Node.PROCESS_MODE_DISABLED:
            hint_move_timer.process_mode = Node.PROCESS_MODE_INHERIT
        if hint_move_timer.is_stopped():
            hint_move_timer.start()
