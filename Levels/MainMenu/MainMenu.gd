extends Node2D

@export_category( "Main Buttons" )
@export_node_path( "BaseButton" ) var start     : NodePath
@export_node_path( "BaseButton" ) var config    : NodePath
@export_node_path( "BaseButton" ) var exit      : NodePath

@export_category( "Config Items" )
@export_node_path( "BaseButton", "Slider" ) var quality     : NodePath
@export_node_path( "BaseButton", "Slider" ) var resolution  : NodePath
@export_node_path( "BaseButton", "Slider" ) var fullscreen  : NodePath
@export_node_path( "BaseButton", "Slider" ) var master      : NodePath
@export_node_path( "BaseButton", "Slider" ) var sfx         : NodePath
@export_node_path( "BaseButton", "Slider" ) var bgm         : NodePath

func _ready() -> void:
    Global.current_scene = self
    Camera.enabled = false
    $Camera2D.enabled = true
#	cam.global_position = $Camera2D.global_position

func _on_exit_pressed() -> void:
    $Control/VBoxContainer/Exit/ConfirmationDialog.popup_centered()
func _on_exit_confirmation_dialog_confirmed() -> void: get_tree().quit()
