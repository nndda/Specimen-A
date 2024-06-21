extends Node2D

@export var level_name : StringName
@export var current_area_name : StringName

@onready var pause_menu : CanvasLayer = $PauseMenu

@onready var top_1 : CanvasLayer = $TopLayer
@onready var top_2 : CanvasLayer = $"TopLayer+1"

@onready var area_container : Node2D =  $Areas

var tree : SceneTree

signal level_loaded

func _input(event : InputEvent) -> void:
    if event.is_action_pressed(&"Debug - hide groups"):
        tree.call_group(&"hide", &"hide")
        tree.set_group(&"hide", "visible", false)

func _enter_tree() -> void:    
    tree = get_tree()

    Global.current_scene = self
    Global.update_layers()

    Camera.copy_camera_reset()
    level_loaded.connect(Camera.start_fade_out)

func _ready() -> void:
    for i : Node in get_children():
        if i is CanvasItem:
            i.visible = true

    for layer : NodePath in Global.layer:
        for inst : Node in get_node(layer).get_children():
            if inst is CharacterBody2D:
                Global.current_objects.append(inst)

    tree.call_group_flags(SceneTree.GROUP_CALL_DEFERRED, &"free", &"queue_free")
    tree.call_group_flags(SceneTree.GROUP_CALL_DEFERRED, &"show", &"show")

    Camera.init_visual_loading()
    level_loaded.emit()

    Audio.connect_audio()
    Audio.init_bg()

    for area in tree.get_nodes_in_group(&"area_entrance"):
        if area is Area2D:
            area.body_entered.connect(
                area_entered.bind("%s" % area.get_parent().name)
            )

    tree.call_group(&"lights_kill", &"kill")

    move_top_items()

    await Camera.faded_out
    Notifications.level_label_displayed.connect(
        Notifications.set_level_label_sub.bind(current_area_name),
        Object.CONNECT_ONE_SHOT
    )
    Notifications.set_level_label(level_name, 4.25)

func area_entered(body : Node2D, area_name : String) -> void:
    if body.name == &"Head" and area_name != current_area_name:
        current_area_name = area_name
        Notifications.set_level_label_sub(current_area_name)

func move_top_items() -> void:
    for top_layer : StringName in [&"top_1", &"top_2"]:
        for node : Node in tree.get_nodes_in_group(top_layer):
            node.call_deferred(&"reparent", get(top_layer))
            get(top_layer).call_deferred(&"move_child", node, 0)

func call_group(groupname : StringName, method : StringName) -> void:
    tree.call_group_flags(SceneTree.GROUP_CALL_DEFERRED, groupname, method)
