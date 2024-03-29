extends CanvasLayer

@onready var head : CharacterBody2D = $"../Head"

@onready var health_bar : ColorRect = $HealthBar
@onready var health_bar_anim : AnimationPlayer = $HealthBar/AnimationPlayer
@onready var health_low_overlay : TextureRect = $HealthLowOverlay
@onready var health_ticker : Timer = $HealthBar/HealthTicker
@onready var health_visible_timer : Timer = $HealthBar/VisibleTimer

func _ready() -> void:
    health_bar.modulate = Color.TRANSPARENT
    head.damaged.connect(player_damaged)

func _process(_delta : float) -> void:
    health_bar.scale.x = remap(head.health, head.health_max, 0.0, 1.0, 0.0)
    health_low_overlay.modulate.a = absf(health_bar.scale.x - 1.0)

func _on_health_ticker_timeout() -> void:
    if head.health < head.health_max:
        head.health += head.health_regen
    else:
        health_ticker.stop()

func player_damaged(current_health : float) -> void:
    health_bar.modulate = Color.WHITE
    health_visible_timer.start(
        remap(current_health, 0.0, head.health_max, 8.5, 3.5)
    )

func _on_health_visible_timer_timeout() -> void:
    health_bar_anim.play(&"FadeOut")
