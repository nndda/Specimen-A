extends CanvasLayer

@onready var head : CharacterBody2D = $"../Head"

@onready var health_bar : ColorRect = $HealthBar
@onready var health_bar_anim : AnimationPlayer = $HealthBar/AnimationPlayer
@onready var health_low_overlay : TextureRect = $HealthLowOverlay
@onready var health_ticker : Timer = $HealthBar/HealthTicker

func _ready():
    health_bar.modulate = Color.TRANSPARENT
    #$"../DBG".queue_free()

func _process(_delta : float):
    health_bar.scale.x = remap(head.health, 100.0, 0.0, 1.0, 0.0)
    health_low_overlay.modulate.a = absf(health_bar.scale.x - 1)

func _on_HealthTicker_timeout():
    if head.health < 100.0:
        head.health += head.health_regen
    else:
        health_ticker.stop()
        health_bar_anim.play(&"FadeOut")
