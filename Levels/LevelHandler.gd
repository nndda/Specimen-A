extends Node2D

@export var level_name : StringName
@export_node_path("Node2D") var pseudo_3d_generator : NodePath

@onready var top_1 : CanvasLayer = $TopLayer
@onready var top_2 : CanvasLayer = $"TopLayer+1"

signal level_loaded

func _enter_tree() -> void:
    Global.current_scene = self
    Global.update_layers()
    level_loaded.connect(Camera.start_fade_out)

func _ready() -> void:
    for top_layer : StringName in [&"top_1", &"top_2"]:
        for node : Node in get_tree().get_nodes_in_group(top_layer):
            node.call_deferred(&"reparent", get(top_layer))
            get(top_layer).call_deferred(&"move_child", node, 0)

    call_deferred(&"add_child", Global.environment.instantiate())
    call_deferred(&"add_child", Global.canvas_modulate.instantiate())

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
