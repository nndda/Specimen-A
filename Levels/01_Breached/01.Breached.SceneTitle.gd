extends Camera2D

func _on_pre_body_entered(body : Node2D) -> void:
    if body == Global.player_physics_head:
        Camera.copy_camera($"../SceneTitlePre", false)
        $"../SceneTitlePre/Area2D".queue_free()
        print("uwu")

func _on_body_entered(body : Node2D) -> void:
    if body == Global.player_physics_head:
        Camera.copy_camera_reset()
        Camera.copy_camera(self, false)
        $Area2D.queue_free()

func _on_ExitGate_destroyed():
    Camera.copy_camera_reset()
