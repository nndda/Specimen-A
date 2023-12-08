extends Control

func sync_config() -> void:
    #fullscreen_toggle.toggled.emit(Global.user_data["fullscreen"])
    fullscreen_toggle.button_pressed = Global.user_data["config"]["fullscreen"]
    if !Global.user_data["config"]["fullscreen"]:
        resolution_button.select(Global.user_data["config"]["resolution_idx"])
    audio_master.value = Global.user_data["config"]["master"]
    _on_master_changed(audio_master.value)
    audio_sfx.value = Global.user_data["config"]["sfx"]
    _on_sfx_changed(audio_sfx.value)
    audio_bgm.value = Global.user_data["config"]["bgm"]
    _on_bgm_changed(audio_bgm.value)

func _on_visibility_changed() -> void:
    if visible == true:
        $Menu/Buttons/Back.grab_focus()

func _enter_tree() -> void:
    visible = false

func _input(event : InputEvent) -> void:
    if event.is_action_pressed(&"Pause"):
        if visible: visible = false

#### DISPLAY

### FULLSCREEN
@onready var fullscreen_toggle := $Menu/Tab/Display/Items/Fullscreen/CheckButton
func _on_fullscreen_toggled(toggled_on : bool) -> void:
    DisplayServer.window_set_mode(
        DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if toggled_on else\
        DisplayServer.WINDOW_MODE_WINDOWED
    )
    resolution_button.disabled = toggled_on
    Global.user_data["config"]["fullscreen"] = toggled_on

### SCREEN/DISPLAY RESOLUTION
@onready var resolution_button := $Menu/Tab/Display/Items/Resolution/OptionButton
func _on_resolution_selected(index : int) -> void:
    var res_string : PackedStringArray =\
        resolution_button.get_item_text(index).split(" x ")
    DisplayServer.window_set_size(Vector2i(
        res_string[0].to_int(),
        res_string[1].to_int()
    ))
    Global.user_data["config"]["resolution_idx"] = index

func adjust_brightness(value : float) -> void:
    environment.adjustment_brightness = value
    Global.user_data["config"]["brightness"] = value
func adjust_contrast(value : float) -> void:
    environment.adjustment_contrast = value
    Global.user_data["config"]["contrast"] = value

var environment := load("res://Worlds/GlobalEnviroment.tres")


#### AUDIO
func display_volume(value : float, label : Label) -> void:
    # -80 <-> 2
    label.text = str(
        int(remap(value, -80.0, 2.0, 0.0, 100.0))
    ) + "%"

@onready var audio_master := $Menu/Tab/Sound/Items/Master/HSlider
@onready var audio_master_label := $Menu/Tab/Sound/Items/Master/Labels/Value
func _on_master_changed(value : float) -> void:
    AudioServer.set_bus_volume_db(0, value)
    display_volume(value, audio_master_label)
    Global.user_data["config"]["master"] = value

@onready var audio_sfx := $Menu/Tab/Sound/Items/SFX/HSlider
@onready var audio_sfx_label := $Menu/Tab/Sound/Items/SFX/Labels/Value
func _on_sfx_changed(value : float) -> void:
    AudioServer.set_bus_volume_db(1, value)
    display_volume(value, audio_sfx_label)
    Global.user_data["config"]["sfx"] = value

@onready var audio_bgm := $Menu/Tab/Sound/Items/BGM/HSlider
@onready var audio_bgm_label := $Menu/Tab/Sound/Items/BGM/Labels/Value
func _on_bgm_changed(value : float) -> void:
    AudioServer.set_bus_volume_db(2, value)
    display_volume(value, audio_bgm_label)
    Global.user_data["config"]["bgm"] = value


func _back_pressed() -> void:
    if visible:
        visible = false
        Global.update_user_data()

@onready var reset_confirm := $Menu/Buttons/Reset/ConfirmationDialog
func _reset_pressed() -> void:
    reset_confirm.popup_centered()
func _reset_confirmed() -> void:
    Global.user_data["config"] = Global["config"].user_data_default
    Global.update_user_data()
    sync_config()

@onready var reset_progress_confirm := $Menu/Buttons/Right/ResetProgress/ConfirmationDialog
func _reset_progress_pressed() -> void:
    reset_progress_confirm.popup_centered()
func _reset_progress_confirmed() -> void:
    Global.user_data["progress"] = Global["progress"].user_data_default
    Global.user_data["achievements"] = Global["achievements"].user_data_default
    Global.update_user_data()
    sync_config()
