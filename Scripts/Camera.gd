extends Camera2D

@onready var animation_player := $CanvasLayer/ColorRect/AnimationPlayer

var shake_tween : Tween
var paused := false

var shaking := false
var shake_power : float = 0.0
@onready var timer_freq := $Shake/Frequency
@onready var timer_duration := $Shake/Duration

var is_copying := false
var copy_camera_tween : Tween
func copy_camera(camera_node : Camera2D, auto_disable := true) -> void:
    is_copying = true
    copy_camera_tween = create_tween()\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_LINEAR)\
        .parallel()
    if auto_disable:
        copy_camera_tween.finished.connect(copy_camera_reset)
    copy_camera_tween.tween_property(self, ^"global_position", camera_node.global_position, 0.9)
    copy_camera_tween.tween_property(self, ^"zoom", camera_node.zoom, 0.9)
    copy_camera_tween.play()

func copy_camera_reset() -> void:
    is_copying = false
    zoom = Vector2.ONE

func shake_start(
    power : float,
    time : float = 0.8,
    frequency : float = 16
    ) -> void:
    if power >= shake_power:
        shake_power = power
        shaking = true
        timer_duration.start(time)
        timer_freq.start(1 / frequency)

func shake() -> void:
    randomize()
    shake_tween = create_tween().bind_node(self)
    shake_tween.tween_property(
        self, ^"offset", Vector2(
            randf_range(-shake_power, shake_power),
            randf_range(-shake_power, shake_power)
            )
            * (timer_duration.time_left / timer_duration.wait_time),
        timer_freq.wait_time)\
    .set_trans(Tween.TRANS_SINE)\
    .set_ease(Tween.EASE_IN_OUT)
    shake_tween.play()

func _on_Frequency_timeout() -> void:
    shake()
func _on_Duration_timeout() -> void:
    shake_power = 0
    shaking = false
    timer_freq.stop()


var visload_entity          : Array
var visload_running         := true
var visload_path_follow     : PathFollow2D
var current_objects_list    : Array[Vector2]

func init_visual_loading() -> void:
    animation_player.play(&"RESET")

    visload_running = true
    following = false
    enabled = true

    var visload_path        := Path2D.new()
    var visload_path_fol    := PathFollow2D.new()
    var visload_curve       := Curve2D.new()
    var tween               := create_tween().bind_node(self)

    visload_path.add_child(visload_path_fol)
    Global.current_scene.call_deferred(&"add_child", visload_path)
    visload_path_fol.progress_ratio = 0.0

    for n in Global.current_objects:
        if !current_objects_list.has(n.global_position):
            current_objects_list.append(n.global_position)

    current_objects_list.erase(Vector2.ZERO)

    current_objects_list.sort_custom(func(a, b): return (
        a.distance_to(Global.head_pos) > b.distance_to(Global.head_pos)))

    for i in current_objects_list:
        visload_curve.add_point(i)
    for e in [visload_path, visload_path_fol]:
        visload_entity.append(e)

    print(current_objects_list)

    visload_path.curve = visload_curve
    visload_path_follow = visload_path_fol

    tween.tween_property(
        visload_path_fol, ^"progress_ratio",
        1.0, Global.current_objects.size() * 0.45)\
        .set_ease(Tween.EASE_OUT)
    tween.finished.connect(finished_visual_loading)
    tween.play()

func finished_visual_loading() -> void:

    print("finished_visual_loading()")

    for e in visload_entity:
        e.queue_free()

    Global.current_objects.clear()
    visload_entity.clear()
    current_objects_list.clear()

    following = true
    enabled = true

    animation_player.play(&"fade_out")
    visload_running = false


var mouse_pos := Vector2.ZERO
var viewport_rect_size := Vector2.ZERO

var following := false
func _process(_delta) -> void:
    if following:
        viewport_rect_size = get_viewport_rect().size

        if !paused:
            mouse_pos = get_viewport().get_mouse_position()
        if !is_copying:
            global_position = Global.head_pos

        drag_horizontal_offset = remap(
            mouse_pos.x,
            0.0, viewport_rect_size.x,
            -1.0, 1.0)
        drag_vertical_offset = remap(
            mouse_pos.y,
            0.0, viewport_rect_size.y,
            -1.0, 1.0)

    else:
        if visload_path_follow != null:
            if visload_running:
                global_position = visload_path_follow.global_position

signal fade_out
signal fade_in

func start_fade_out() -> void:
    animation_player.play(&"fade_out")
func start_fade_in() -> void:
    animation_player.play(&"fade_in")

func _on_animation_finished(anim_name : StringName)  -> void:
    if anim_name == &"fade_out":
        fade_out.emit()
    if anim_name == &"fade_in":
        fade_in.emit()
