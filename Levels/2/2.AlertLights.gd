extends Node2D

var root_scene : Node2D
var tree : SceneTree
var decor_light : TileMapLayer

func _enter_tree() -> void:
    if is_in_group(&"free"):
        call_deferred(&"queue_free")
    else:
        root_scene = get_parent()
        tree = root_scene.tree

        root_scene.ready.connect(_on_root_scene_ready)

func _ready() -> void:
    if !is_in_group(&"free"):
        Global.player_physics_head.allow_attack = false

func _on_pseudo_3d_generator_layers_generated() -> void:
    decor_light = $"../Tiles/Pseudo3DGenerator".decor_light_generated

func _on_root_scene_ready() -> void:
    tree.call_group(&"alert_lights_on", &"disable")

var decor_light_tween : Tween
func initiate_alert_lights() -> void:
    await tree.create_timer(0.25).timeout
    Global.player_physics_head.allow_control = false
    Global.player_physics_head.fade_out_light()

    await tree.create_timer(1.2).timeout
    tree.call_group(&"lights", &"lights_out")

    decor_light_tween = create_tween().bind_node(self)
    decor_light_tween.tween_property(
        decor_light, ^"modulate:a", 0.0, 1.1
    )\
    .set_ease(Tween.EASE_OUT)\
    .set_trans(Tween.TRANS_EXPO)

    await tree.create_timer(3.0).timeout

    tree.call_group_flags(SceneTree.GROUP_CALL_DEFERRED,
        &"alert_lights_out", &"queue_free"
    )

    decor_light_tween = create_tween().bind_node(self)
    decor_light_tween.tween_property(
        decor_light, ^"modulate:a", 1.0, 2.2
    )\
    .set_ease(Tween.EASE_OUT)\
    .set_trans(Tween.TRANS_EXPO)

    tree.call_group(&"alert_lights_on", &"enable")
    tree.call_group(&"lights", &"lights_on")
 
    for a in tree.get_nodes_in_group(&"alert_lights_set"):
        a.light.color = Color("#ff0f13")

    Global.player_physics_head.fade_in_light()
    Global.player_physics_head.allow_control = true
    Global.player_physics_head.allow_attack = true

func _on_trigger_area_body_entered(body: Node2D) -> void:
    if body.name == Global.PLAYER_HEAD_NAME:
        initiate_alert_lights()
        $TriggerArea.queue_free()
