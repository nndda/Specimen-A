extends CanvasLayer

@onready var head : CharacterBody2D = $"../Head"

@onready var health_bar : ColorRect = $HealthBar
@onready var health_bar_anim : AnimationPlayer = $HealthBar/AnimationPlayer
@onready var health_low_overlay : TextureRect = $HealthLowOverlay
@onready var health_ticker : Timer = $HealthBar/HealthTicker
@onready var health_visible_timer : Timer = $HealthBar/VisibleTimer

@onready var attack_indicator : TextureProgressBar = $AttackIndicator
@onready var attack_cooldown : TextureProgressBar = $AttackCooldown

func _ready() -> void:
    health_bar.modulate = Color.TRANSPARENT
    head.damaged.connect(player_damaged)
    attack_indicator.visible = true
    attack_cooldown.visible = true
    health_low_overlay.visible = true

func _process(_delta : float) -> void:
    health_bar.scale.x = remap(head.health, head.health_max, 0.0, 1.0, 0.0)
    health_low_overlay.modulate.a = absf(health_bar.scale.x - 1.0)

    if !Camera.is_copying:
        Camera.zoom.x = remap(
            attack_indicator.value,
            attack_indicator.min_value,
            attack_indicator.max_value,
            1.0, 0.8
        )
        Camera.zoom.y = Camera.zoom.x

    if (head.attack_cooldown_timer as Timer).time_left > 0:
        attack_cooldown.modulate.a = remap(
            attack_cooldown.value,
            attack_cooldown.min_value,
            60,
            0.0, 1.0
        )

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
