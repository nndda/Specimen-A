extends Node

@onready var sfx_button_hover : AudioStreamPlayer = $SFX/UI/ButtonHover
@onready var sfx_button_click : AudioStreamPlayer = $SFX/UI/ButtonClick

@onready var bg_ease : Timer = $BGM/Ease
@onready var ambience : AudioStreamPlayer = $"BGM/Ambience/0"
@onready var bgm : AudioStreamPlayer = $"BGM/0"

@onready var sound_groups : Dictionary = {
    #&"node group name" : [
        #[&"signal", callable],
    #],
    &"ui_button" : [
        [&"mouse_entered", sfx_button_hover.play],
        [&"pressed", sfx_button_click.play],
    ],
    &"ui_tab" : [
        [&"tab_hovered", sfx_button_hover.play],
        [&"tab_clicked", sfx_button_click.play],
    ],
    &"ui_slider" : [
        [&"mouse_entered", sfx_button_hover.play],
    ],
}

func init_bg() -> void:
    ambience.volume_db = -80.0
    bgm.volume_db = -80.0
    bg_ease.start(8.0)
    ambience.play()
    bgm.play()

func _process(_delta) -> void:
    for bg_aud : AudioStreamPlayer in [bgm, ambience]:
        bg_aud.volume_db = remap(
            bg_ease.time_left, 8.0, 0.0, -80.0, 0.0
        )

func connect_audio() -> void:
    for group : StringName in sound_groups.keys():
        for node : Node in Global.scene_tree.get_nodes_in_group(group):
            for signal_node : Array in sound_groups[group]:
                node.connect(signal_node[0], signal_node[1])

func set_dialogue_window(node : AcceptDialog) -> void:
    node.get_ok_button().add_to_group(&"ui_button")
    if node is ConfirmationDialog:
        node.get_cancel_button().add_to_group(&"ui_button")
