extends CanvasLayer

var paused := false
var allow_pause := false

@onready var level_root : Node = $".."
@onready var level_name : Label = $Control/Area/LevelName
@onready var level_sub : Label = $Control/Area/LevelName/Sub

@onready var config_menu : Control = $Control/ConfigMenu

signal pause_menu_closed

func toggle_pause() -> void:
    paused = !paused
    visible = paused
    Camera.paused = paused
    #ProjectSettings.set_setting("display/mouse_cursor/custom_image",
        #"" if paused else\
        #"res://UI/Cursors/Dot.png"
    #)
    level_root.call_deferred(&"set_process_mode",
        Node.PROCESS_MODE_DISABLED if paused else\
        Node.PROCESS_MODE_INHERIT
    )
    Input.mouse_mode =\
        Input.MOUSE_MODE_VISIBLE if paused else\
        Input.MOUSE_MODE_CONFINED

    if !paused:
        pause_menu_closed.emit()

func _enter_tree() -> void:
    visible = false
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _ready() -> void:
    level_name.text = level_root.level_name
    level_root.level_loaded.connect(func(): allow_pause = true)
    Audio.set_dialogue_window(restart_confirm)
    Audio.set_dialogue_window(mainmenu_confirm)

func _input(event : InputEvent) -> void:
    if event.is_action_pressed(&"Pause") and\
        !config_menu.visible and\
        allow_pause:
        toggle_pause()

func set_area_name() -> void:
    level_name.text = level_root.level_name
func set_area_sub_name(area_name : StringName) -> void:
    level_sub.text = area_name

# Main buttons

func _resume_pressed() -> void:
    toggle_pause()

@onready var restart_confirm : ConfirmationDialog = $Control/Menu/Restart/ConfirmationDialog
func _restart_pressed() -> void:
    restart_confirm.popup_centered()
func _restart_confirmed() -> void:
    paused = false
    Camera.paused = false
    Camera.copy_camera_reset()
    level_root.get_tree().call_deferred(&"reload_current_scene")

func _achievements_pressed() -> void:
    pass

func _config_pressed() -> void:
    config_menu.visible = true

@onready var mainmenu_confirm : ConfirmationDialog = $Control/Menu/MainMenu/ConfirmationDialog
func _mainmenu_pressed() -> void:
    mainmenu_confirm.popup_centered()
func _mainmenu_confirmed() -> void:
    Camera.paused = false
    Camera.copy_camera_reset()
    level_root.get_tree().call_deferred(&"change_scene_to_file", "res://UI/MainMenu.tscn")
