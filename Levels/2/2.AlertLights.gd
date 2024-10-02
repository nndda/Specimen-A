extends Node2D

var root_scene : Node2D
var decor_light : TileMapLayer

var scene_passed := false

func _enter_tree() -> void:
    scene_passed = Global.user_data["level_stats"]["lv2_emergency_light"]

    if is_in_group(&"free"):
        queue_free()
    else:
        root_scene = get_parent()
        root_scene.ready.connect(_on_root_scene_ready)

func _ready() -> void:
    if !scene_passed:
        Global.player_physics_head.allow_attack = false

func _on_pseudo_3d_generator_layers_generated() -> void:
    decor_light = $"../Tiles/Pseudo3DGenerator".decor_light_generated

func _on_root_scene_ready() -> void:
    Global.scene_tree.call_group(&"alert_lights_on", &"disable")

var decor_light_tween : Tween
func initiate_alert_lights() -> void:
    if !scene_passed:
        await Global.scene_tree.create_timer(0.25).timeout
        Global.player_physics_head.allow_control = false
        Global.player_physics_head.fade_out_light()

    await Global.scene_tree.create_timer(1.2).timeout
    Global.scene_tree.call_group(&"lights", &"lights_out")

    decor_light_tween = create_tween().bind_node(self)
    decor_light_tween.tween_property(
        decor_light, ^"modulate:a", 0.0, 1.1
    )\
    .set_ease(Tween.EASE_OUT)\
    .set_trans(Tween.TRANS_EXPO)

    await Global.scene_tree.create_timer(3.0).timeout

    Global.scene_tree.call_group_flags(SceneTree.GROUP_CALL_DEFERRED,
        &"alert_lights_out", &"queue_free"
    )

    decor_light_tween = create_tween().bind_node(self)
    decor_light_tween.tween_property(
        decor_light, ^"modulate:a", 1.0, 2.2
    )\
    .set_ease(Tween.EASE_OUT)\
    .set_trans(Tween.TRANS_EXPO)

    Global.scene_tree.call_group(&"alert_lights_on", &"enable")
    Global.scene_tree.call_group(&"lights", &"lights_on")
 
    Global.scene_tree.set_group(&"alert_lights_set", "light:color", Color("#ff0f13"))

    if !scene_passed:
        Global.player_physics_head.fade_in_light()
        Global.player_physics_head.allow_control = true
        Global.player_physics_head.allow_attack = true

        Global.user_data["level_stats"]["lv2_emergency_light"] = true
        Global.update_user_data()

func _on_trigger_area_body_entered(body: Node2D) -> void:
    if body.name == Global.PLAYER_HEAD_NAME:
        initiate_alert_lights()
        $TriggerArea.queue_free()
