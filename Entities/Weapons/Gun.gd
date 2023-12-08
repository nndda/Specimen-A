extends Node2D

## Base script for ALL gun/projectile addon
# NOTE : Require `FireFunction` Node with variable `animation_player`, containing animation named "Firing"

@export var damage_min : float = 2.25
@export var damage_max : float = 4.5
var firing := false

@onready var fire_function := $FireFunction
@onready var fire_function_anim : AnimationPlayer = $FireFunction.animation_player

@export_node_path("Area2D", "RayCast2D") var line_of_sight_; var line_of_sight : Node2D
@export_node_path("Area2D", "RayCast2D") var friendly_sight_; var friendly_sight : Node2D

var parent : Node
var trigger_area : NodePath
var on_line := false

var player_bodies : Array[Node2D] = []

func set_on_line(object) -> void:
    on_line = player_bodies.has(object)
func set_off_line(object) -> void:
    on_line = !player_bodies.has(object)

func _enter_tree():
    parent = get_parent()
    player_bodies = [Global.player_physics_head, Global.player_physics_body]
    player_bodies.make_read_only()

func _ready() -> void:
    line_of_sight = get_node_or_null(line_of_sight_)
    friendly_sight = get_node_or_null(friendly_sight_)

    trigger_area = NodePath(^"../TriggerArea" if parent.custom_trigger == null else parent.custom_trigger_)

    if  line_of_sight != null and\
        line_of_sight is CollisionObject2D:

        if line_of_sight is RayCast2D:
            line_of_sight.add_exception(get_node(trigger_area))

        elif line_of_sight is Area2D:

            line_of_sight.body_entered.connect(set_on_line)
            line_of_sight.body_exited.connect(set_off_line)

            line_of_sight.area_entered.connect(set_on_line)
            line_of_sight.area_exited.connect(set_off_line)

    fire_function_anim.animation_finished.connect(parent.Weapon_AnimationFinished)
    #fire_function_anim.connect(
        #&"animation_finished", Callable(parent, &"Weapon_AnimationFinished"))

func _process(_delta) -> void:
    parent.firing = firing

func _physics_process(_delta) -> void:
    if parent.triggered:
        if line_of_sight is RayCast2D:
            on_line = line_of_sight.is_colliding() and !friendly_sight.is_colliding()

func fire() -> void:
    $FireFunction.animation_player.play(&"Firing")
