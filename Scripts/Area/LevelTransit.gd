extends Area2D

@export_file("*.tscn", "*.scn") var level_transition_scene : String

func _ready() -> void:
    if level_transition_scene.is_empty():
        push_error("Empty level transition.")

func _on_body_entered(body : Node2D) -> void:
    if body.name == Global.PLAYER_HEAD_NAME:
        (Global.player.ui as CanvasLayer).visible = false
        Global.current_scene.set_deferred(&"process_mode", Node.PROCESS_MODE_DISABLED)
        Camera.start_fade_in()
        await Camera.faded_in
        (Global.current_scene.tree as SceneTree).change_scene_to_file(
            level_transition_scene
        )
