extends Control

func sync_config() -> void:
    fullscreen_toggle.button_pressed = Global.user_config["fullscreen"]
    if !Global.user_config["fullscreen"]:
        resolution_button.select(Global.user_config["resolution_idx"])

    audio_master.value = Global.user_config["master"]
    audio_master.value_changed.emit(audio_master.value)

    audio_sfx.value = Global.user_config["sfx"]
    audio_sfx.value_changed.emit(audio_sfx.value)

    audio_bgm.value = Global.user_config["bgm"]
    audio_bgm.value_changed.emit(audio_bgm.value)

    display_brightness.value = Global.user_config["brightness"]
    display_brightness.value_changed.emit(display_brightness.value)

    display_contrast.value = Global.user_config["contrast"]
    display_contrast.value_changed.emit(display_contrast.value)

    for action in ["Move", "Attack"]:
        var input_event_default := InputEventKey.new()
        input_event_default.keycode = OS.find_keycode_from_string(Global.user_config_default[action])

        var input_event := InputEventKey.new()
        input_event.keycode = OS.find_keycode_from_string(Global.user_config[action])

        if rebind_target != &"":
            InputMap.action_erase_event(rebind_target, input_event_default)
            InputMap.action_add_event(rebind_target, input_event)

func _on_visibility_changed() -> void:
    if visible == true:
        back_button.grab_focus()

func _enter_tree() -> void:
    visible = false

func _input(event : InputEvent) -> void:
    if event.is_action_pressed(&"Pause"):
        if visible: visible = false

func _ready() -> void:
    reset_confirm.hide()
    reset_progress_confirm.hide()
    rebind_dialogue.hide()

    for action : StringName in [&"Attack", &"Move"]:
        rebind_buttons[action].text = Global.user_config[action]

    Audio.set_dialogue_window(reset_confirm)
    Audio.set_dialogue_window(reset_progress_confirm)

    sync_config()

## Main buttons
@onready var back_button : Button = $Menu/Buttons/Back
func back_pressed() -> void:
    if visible:
        visible = false
        Global.update_user_config()

@onready var reset_confirm : ConfirmationDialog = $Menu/Buttons/ResetSettings/ConfirmationDialog
func reset_settings_pressed() -> void:
    reset_confirm.popup_centered()
func reset_settings_confirmed() -> void:
    Global.user_config = Global.user_config_default
    Global.update_user_config()
    sync_config()

@onready var reset_progress_confirm : ConfirmationDialog = $Menu/Buttons/Right/ResetProgress/ConfirmationDialog
func reset_progress_pressed() -> void:
    reset_progress_confirm.popup_centered()
func reset_progress_confirmed() -> void:
    #Global.user_data["progress"] = Global.user_data_default["progress"]
    #Global.user_data["achievements"] = Global.user_data_default["achievements"]
    #Global.update_user_config()
    sync_config()


#### DISPLAY

### FULLSCREEN
@onready var fullscreen_toggle : CheckButton = $Menu/Tab/Display/Items/Fullscreen/CheckButton
func display_fullscreen_toggled(toggled_on : bool) -> void:
    DisplayServer.window_set_mode(
        DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if toggled_on else
        DisplayServer.WINDOW_MODE_WINDOWED
    )
    resolution_button.disabled = toggled_on
    Global.user_config["fullscreen"] = toggled_on

### SCREEN/DISPLAY RESOLUTION
var environment := preload("res://Worlds/GlobalEnviroment.tres")
@onready var resolution_button : OptionButton = $Menu/Tab/Display/Items/Resolution/OptionButton
func display_resolution_selected(index : int) -> void:
    var res_string : PackedStringArray =\
        resolution_button.get_item_text(index).split(" x ")
    DisplayServer.window_set_size(Vector2i(
        res_string[0].to_int(),
        res_string[1].to_int()
    ))
    Global.user_config["resolution_idx"] = index

@onready var display_brightness : HSlider = $Menu/Tab/Display/Items/Brightness/HSlider
func adjust_brightness(value : float) -> void:
    environment.adjustment_brightness = value
    Global.user_config["brightness"] = value
@onready var display_contrast : HSlider = $Menu/Tab/Display/Items/Contrast/HSlider
func adjust_contrast(value : float) -> void:
    environment.adjustment_contrast = value
    Global.user_config["contrast"] = value


#### AUDIO
func display_volume(value : float, label : Label) -> void:
    # -80 <-> 2
    label.text = str(
        int(remap(value, -80.0, 2.0, 0.0, 100.0))
    ) + "%"

@onready var audio_master : HSlider = $Menu/Tab/Sound/Items/Master/HSlider
@onready var audio_master_label : Label = $Menu/Tab/Sound/Items/Master/Labels/Value
func audio_master_changed(value : float) -> void:
    AudioServer.set_bus_volume_db(0, value)
    display_volume(value, audio_master_label)
    Global.user_config["master"] = value

@onready var audio_sfx : HSlider = $Menu/Tab/Sound/Items/SFX/HSlider
@onready var audio_sfx_label : Label = $Menu/Tab/Sound/Items/SFX/Labels/Value
func audio_sfx_changed(value : float) -> void:
    AudioServer.set_bus_volume_db(1, value)
    display_volume(value, audio_sfx_label)
    Global.user_config["sfx"] = value

@onready var audio_bgm : HSlider = $Menu/Tab/Sound/Items/BGM/HSlider
@onready var audio_bgm_label : Label = $Menu/Tab/Sound/Items/BGM/Labels/Value
func audio_bgm_changed(value : float) -> void:
    AudioServer.set_bus_volume_db(2, value)
    display_volume(value, audio_bgm_label)
    Global.user_config["bgm"] = value


## CONTROLS

@onready var rebind_buttons := {
    &"Move" : $Menu/Tab/Controls/Items/Move/Actions/Rebind,
    &"Attack" : $Menu/Tab/Controls/Items/Attack/Actions/Rebind,
}
@onready var rebind_dialogue : Window = $Menu/Tab/Controls/RebindDialogue
@onready var rebind_key_label : Label = $Menu/Tab/Controls/RebindDialogue/PanelContainer/Control/VBoxContainer/Key
var rebind_target := &""
var rebind_old : InputEventKey
var rebind_new : InputEventKey
const forbidden_keys : Array[Key] = [
    KEY_ESCAPE,
    KEY_F1,
    KEY_F2,
    KEY_F3,
    KEY_F4,
    KEY_F5,
    KEY_F6,
    KEY_F7,
    KEY_F8,
    KEY_F9,
    KEY_F10,
    KEY_F11,
    KEY_F12,
    KEY_PRINT,
    KEY_SCROLLLOCK,
    KEY_NUMLOCK,
    KEY_PAUSE,
    KEY_CTRL,
    KEY_ALT,
    KEY_META,
    KEY_MENU,
]

func rebind_input(event : InputEvent) -> void:
    if event is InputEventKey:
        if !forbidden_keys.has(event.keycode):
            rebind_key_label.text = "[ %s ]" % event.as_text_keycode()
            rebind_old = InputMap.action_get_events(rebind_target)[1]
            rebind_new = event

func rebind_close_requested() -> void:
    rebind_dialogue.hide()

func rebind_confirmed() -> void:
    InputMap.action_erase_event(rebind_target, rebind_old)
    InputMap.action_add_event(rebind_target, rebind_new)

    rebind_buttons[rebind_target].text = rebind_new.as_text_keycode()
    Global.user_config[rebind_target] = OS.get_keycode_string(rebind_new.keycode)

    rebind_target = &""
    rebind_old = null
    rebind_new = null
    rebind_dialogue.close_requested.emit()

func rebind_key_pressed(action : StringName) -> void:
    rebind_key_label.text = "[ Press any key ]"
    rebind_target = action
    rebind_dialogue.popup_centered()
