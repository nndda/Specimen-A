extends Node2D

@export var level_name : StringName
@export_node_path("Node2D") var pseudo_3d_generator : NodePath

@onready var top_light_layer := $TopLayer/Lights

signal level_loaded

func _enter_tree() -> void:
    Global.current_scene = self
    Global.update_layers()
    level_loaded.connect(Camera.start_fade_out)

func _ready() -> void:
    for top_light in get_tree().get_nodes_in_group(&"top_light"):
        top_light.call_deferred(&"reparent", top_light_layer)

    get_node(pseudo_3d_generator).call_deferred(&"generate_layers")
    call_deferred(&"add_child", preload("res://Worlds/GlobalEnvironment.tscn").instantiate())
    call_deferred(&"add_child", preload("res://Worlds/GlobalModulate.tscn").instantiate())

    $TopLayer.visible = true
    $"TopLayer+1".visible = true
    for i in get_children():
        if i is CanvasItem:
            i.visible = true

    for layer in Global.layer:
        for inst in get_node(layer).get_children():
            if inst is CharacterBody2D:
                Global.current_objects.append(inst)

    Camera.init_visual_loading()
    level_loaded.emit()

