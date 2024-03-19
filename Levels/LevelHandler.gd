extends Node2D

@export var level_name : StringName
@export var current_area_name : StringName
@export_node_path("Node2D") var pseudo_3d_generator : NodePath

@onready var top_1 : CanvasLayer = $TopLayer
@onready var top_2 : CanvasLayer = $"TopLayer+1"

@onready var area_container : Node2D =  $Areas

signal level_loaded

func _enter_tree() -> void:
    Global.current_scene = self
    Global.update_layers()
    level_loaded.connect(Camera.start_fade_out)

func _ready() -> void:
    get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, &"free", &"queue_free")

    for top_layer : StringName in [&"top_1", &"top_2"]:
        for node : Node in get_tree().get_nodes_in_group(top_layer):
            node.call_deferred(&"reparent", get(top_layer))
            get(top_layer).call_deferred(&"move_child", node, 0)

    call_deferred(&"add_child", Global.environment.instantiate())
    call_deferred(&"add_child", Global.canvas_modulate.instantiate())
    top_2.call_deferred(&"add_child", preload("res://Shaders/Particles/AmbientParticle.tscn"))

    $TopLayer.visible = true
    $"TopLayer+1".visible = true
    for i : Node in get_children():
        if i is CanvasItem:
            i.visible = true

    for layer : NodePath in Global.layer:
        for inst : Node in get_node(layer).get_children():
            if inst is CharacterBody2D:
                Global.current_objects.append(inst)

    Camera.init_visual_loading()
    level_loaded.emit()

    Audio.connect_audio()
    Audio.init_bg()

    for area in get_tree().get_nodes_in_group(&"AreaEntrance"):
        if area is Area2D:
            area.body_entered.connect(
                area_entered.bind(String(area.get_parent().get_name()))
            )

    await Camera.faded_out

    Notifications.level_label_displayed.connect(
        Notifications.set_level_label_sub.bind(current_area_name),
        Object.CONNECT_ONE_SHOT
    )
    Notifications.set_level_label(level_name, 4.25)

func area_entered(body : Node2D, area_name : String) -> void:
    if body.get_name() == &"Head" and area_name != current_area_name:
        current_area_name = area_name
        Notifications.set_level_label_sub(current_area_name)
