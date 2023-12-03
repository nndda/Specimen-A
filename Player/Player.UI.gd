extends CanvasLayer

@onready var head := $"../Head"

@onready var health_bar := $HealthBar
@onready var health_bar_anim := $HealthBar/AnimationPlayer
@onready var health_low_overlay := $HealthLowOverlay
@onready var health_ticker := $HealthBar/HealthTicker

func _process(_delta):
    health_bar.scale.x = remap(head.health, 100.0, 0.0, 1.0, 0.0)
    health_low_overlay.modulate.a = absf(health_bar.scale.x - 1)

func _on_HealthTicker_timeout():
    if head.health < 100.0:
        head.health += head.health_regen
    else:
        health_ticker.stop()
        health_bar_anim.play(&"FadeOut")
