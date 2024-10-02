extends Node2D

@export var level_name : StringName
@export var current_area_name : StringName

@onready var pause_menu : CanvasLayer = $PauseMenu

@onready var top_1 : CanvasLayer = $TopLayer
@onready var top_2 : CanvasLayer = $"TopLayer+1"

@onready var area_container : Node2D =  $Areas

signal level_loaded

func _input(event : InputEvent) -> void:
    if event.is_action_pressed(&"Debug - hide groups"):
        Global.scene_tree.call_group(&"hide", &"hide")
        Global.scene_tree.set_group(&"hide", "visible", false)

func _enter_tree() -> void:

    Global.current_scene = self
    Global.update_layers()

    Camera.copy_camera_reset()
    level_loaded.connect(Camera.start_fade_out)

func _ready() -> void:
    if Global.current_difficulty == Global.Difficulty.NORMAL:
        Global.scene_tree.call_group(&"difficulty_hard", &"queue_free")
    elif Global.current_difficulty == Global.Difficulty.HARD:
        Global.scene_tree.call_group(&"difficulty_hard_rem", &"queue_free")

    for i : Node in get_children():
        if i is CanvasItem:
            i.visible = true

    for layer : NodePath in Global.LAYER:
        for inst : Node in get_node(layer).get_children():
            if inst is CharacterBody2D:
                Global.current_objects.append(inst)

    Global.scene_tree.call_group_flags(SceneTree.GROUP_CALL_DEFERRED, &"free", &"queue_free")
    Global.scene_tree.call_group_flags(SceneTree.GROUP_CALL_DEFERRED, &"show", &"show")

    Camera.initialize_level()
    level_loaded.emit()

    Audio.connect_audio()
    Audio.init_bg()

    for area in Global.scene_tree.get_nodes_in_group(&"area_entrance"):
        if area is Area2D:
            area.body_entered.connect(
                area_entered.bind("%s" % area.get_parent().name)
            )

    Global.scene_tree.call_group(&"lights_kill", &"kill")

    move_top_items()

    Global.scene_tree.call_group(&"entity", &"init_raycast_exceptions")

    await Camera.faded_out
    Notifications.level_label_displayed.connect(
        Notifications.set_level_label_sub.bind(current_area_name),
        Object.CONNECT_ONE_SHOT
    )
    Notifications.set_level_label(level_name, 4.25)

func area_entered(body : Node2D, area_name : String) -> void:
    if body.name == Global.PLAYER_HEAD_NAME and area_name != current_area_name:
        current_area_name = area_name
        Notifications.set_level_label_sub(current_area_name)

func move_top_items() -> void:
    for top_layer : StringName in [&"top_1", &"top_2"]:
        for node : Node in Global.scene_tree.get_nodes_in_group(top_layer):
            node.call_deferred(&"reparent", get(top_layer))
            get(top_layer).call_deferred(&"move_child", node, 0)

func call_group(groupname : StringName, method : StringName) -> void:
    Global.scene_tree.call_group_flags(SceneTree.GROUP_CALL_DEFERRED, groupname, method)
