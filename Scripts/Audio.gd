extends Node

@onready var sfx_button_hover : AudioStreamPlayer = $SFX/UI/ButtonHover
@onready var sfx_button_click : AudioStreamPlayer = $SFX/UI/ButtonClick

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

func connect_audio() -> void:
    for group : StringName in sound_groups.keys():
        for node : Node in get_tree().get_nodes_in_group(group):
            for signal_node : Array in sound_groups[group]:
                node.connect(signal_node[0], signal_node[1])

func set_dialogue_window(node : AcceptDialog) -> void:
    node.get_ok_button().add_to_group(&"ui_button")
    if node is ConfirmationDialog:
        node.get_cancel_button().add_to_group(&"ui_button")
