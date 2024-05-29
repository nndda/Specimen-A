extends Node2D

@export_category("Main Buttons")
@export var btn_start : Button
@export var btn_config : Button
@export var btn_credits : Button
@export var btn_achievement : Button
@export var btn_exit : Button

@export_category("Pop Up Windows")
@export var config_menu : Control
@export var exit_confirm : AcceptDialog

func _ready() -> void:
    Global.current_scene = self
    Camera.enabled = false
    Camera.start_fade_out()

    $Camera2D.enabled = true
    config_menu.sync_config()

    Audio.set_dialogue_window(exit_confirm)
    Audio.connect_audio()

func _on_exit_pressed() -> void:
    exit_confirm.popup_centered()

func _config_pressed() -> void:
    config_menu.visible = true

func _on_exit_confirmation_dialog_confirmed() -> void:
    get_tree().quit()




