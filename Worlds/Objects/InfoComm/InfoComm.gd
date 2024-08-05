extends Control

@export_file("*.dlg") var dialogue_file : String
var dlg : Dialogue
var dlg_length : int

@export_group("Setup")
@export var stage : Stage
@export var main_container : PanelContainer
@export var container : VBoxContainer
@export var container_scroll : ScrollContainer
@export var progress_bar : ProgressBar
@export var end_label : Label

@export var button_trigger : Button
@export var detect_area : Area2D
@export var camera_copy : Camera2D

var button_trigger_init_pos : Vector2

var lines_displays : Array[Dictionary] = []

func _ready() -> void:
    dlg = Dialogue.load(dialogue_file)
    dlg_length = dlg.get_length()

    stage.progressed.connect(_on_stage_progressed)

    for n in dlg.get_length():
        var line_cont := VBoxContainer.new()
        var line_label := Label.new()
        var line_dlg := DialogueLabel.new()
        line_dlg.bbcode_enabled = true
        line_dlg.fit_content = true
        line_dlg.text_rendered.connect(_on_dlglabel_rendered)
        line_dlg.set_stage(stage)

        line_cont.call_deferred(&"add_child", line_label)
        line_cont.call_deferred(&"add_child", line_dlg)

        container.call_deferred(
            &"add_child", line_cont
        )

        lines_displays.append({
            "actor": line_label,
            "dlg": line_dlg,
        })

    stage.actor_label = lines_displays[0]["actor"]
    stage.dialogue_label = lines_displays[0]["dlg"]

    button_trigger.pivot_offset = button_trigger.size * 0.5
    progress_bar.max_value = dlg_length

    tween_indicator(false)
    tween_main_ui(false)

var current_line : int = 0
var current_line_wrapped : int = 0

func stage_clear() -> void:
    for n in lines_displays:
        n["actor"].text = ""
        n["dlg"].clear_render()
        n["dlg"].text = ""
    current_line_wrapped = 0
    current_line = 0
    stage.actor_label = lines_displays[0]["actor"]
    stage.dialogue_label = lines_displays[0]["dlg"]

func _on_stage_progressed() -> void:
    current_line = stage.get_line()
    progress_bar.value = current_line + 1
    end_label.visible = progress_bar.value == dlg_length

func _on_dlglabel_rendered(_string : String) -> void:
    current_line_wrapped = wrapi(current_line + 1, 0, dlg_length)
    stage.actor_label = lines_displays[current_line_wrapped]["actor"]
    stage.dialogue_label = lines_displays[current_line_wrapped]["dlg"]



func switch_state(start : bool) -> void:
    stage_clear()
    tween_main_ui(start)

    detect_area.monitoring = !start
    Global.player_physics_head.allow_control = !start
    tween_indicator(!start)

    if start:
        Camera.copy_camera(camera_copy, false)
        stage.start(dlg)
    else:
        Camera.copy_camera_reset()
        stage.cancel(true)



func _on_start_pressed() -> void:
    switch_state(true)

func _on_abort_pressed() -> void:
    switch_state(false)

func _on_progress_pressed() -> void:
    if !stage.dialogue_label.is_rendering() and\
        current_line >= dlg_length - 1:
        stage_clear()
        stage.restart()
    else:
        stage.progress()



var tween_enter : Tween
const TWEEN_PROP_SCALE := Vector2.ONE * 1.3
func tween_indicator(entering : bool) -> void:
    tween_enter = create_tween()\
        .set_trans(Tween.TRANS_QUINT)\
        .set_ease(Tween.EASE_OUT)\
        .set_parallel(true)

    tween_enter.tween_property(
        button_trigger, ^"modulate:a",
        1.0 if entering else 0.0, 0.5
    ).from_current()

    tween_enter.tween_property(
        button_trigger, ^"scale",
        TWEEN_PROP_SCALE if entering else Vector2.ONE, 0.5
    ).from_current()

var tween_enter_ui : Tween
func tween_main_ui(entering : bool) -> void:
    tween_enter_ui = create_tween()\
        .set_trans(Tween.TRANS_QUINT)\
        .set_ease(Tween.EASE_OUT)\
        .set_parallel(true)

    tween_enter_ui.tween_property(
        main_container, ^"modulate:a",
        1.0 if entering else 0.0, 0.5
    ).from_current()



func _on_area_2d_body_entered(body: Node2D) -> void:
    if body.name == Global.PLAYER_HEAD_NAME:
        tween_indicator(true)

func _on_area_2d_body_exited(body: Node2D) -> void:
    if body.name == Global.PLAYER_HEAD_NAME:
        tween_indicator(false)
