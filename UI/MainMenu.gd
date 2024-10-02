extends Node2D

@export_category("Main Buttons")
@export var btn_start : Button
@export var btn_config : Button
@export var btn_credits : Button
@export var btn_achievement : Button
@export var btn_exit : Button

@export_category("Pop Up Windows")
@export var config_menu : Control
@export var exit_confirm : ConfirmationDialog
@export var goto_url_confirm : ConfirmationDialog
var goto_url_dest : String

@export_category("Bottom Menu")
@export var version_label : Label
@export var source_code_button : Button

func _ready() -> void:
    Global.current_scene = self
    Camera.enabled = false
    Camera.start_fade_out()

    $Camera2D.enabled = true
    config_menu.sync_config()

    Audio.set_dialogue_window(exit_confirm)
    Audio.set_dialogue_window(goto_url_confirm)
    Audio.connect_audio()
    
    version_label.text = "v%s" % ProjectSettings\
        .get_setting("application/config/version")

func _on_start_pressed() -> void:
    pass # Replace with function body.

func _on_config_pressed() -> void:
    config_menu.visible = true

func _on_credits_pressed() -> void:
    pass # Replace with function body.

func _on_achievements_pressed() -> void:
    pass # Replace with function body.

func _on_exit_pressed() -> void:
    exit_confirm.popup_centered()

func _on_exit_confirmation_dialog_confirmed() -> void:
    Global.scene_tree.quit()

func goto_url(url : String) -> void:
    goto_url_dest = url
    url = url.trim_prefix("https://")
    goto_url_confirm.dialog_text = "Go to '%s'?" % url
    goto_url_confirm.popup_centered()

func _on_goto_url_confirmed() -> void:
    print(goto_url_dest)
