extends Node2D

@export_category( "Main Buttons" )
@export_node_path( "BaseButton" ) var start     : NodePath
@export_node_path( "BaseButton" ) var config    : NodePath
@export_node_path( "BaseButton" ) var exit      : NodePath

@onready var config_menu := $CanvasLayer/Control/ConfigMenu

func _ready() -> void:
    Global.current_scene = self
    Camera.enabled = false
    Camera.start_fade_out()
    $Camera2D.enabled = true
    config_menu.sync_config()
#	cam.global_position = $Camera2D.global_position

func _on_exit_pressed() -> void:
    $Control/VBoxContainer/Exit/ConfirmationDialog.popup_centered()
func _config_pressed():
    config_menu.visible = true
func _on_exit_confirmation_dialog_confirmed() -> void: get_tree().quit()




