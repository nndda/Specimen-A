extends Node2D

## Base script for ALL gun/projectile addon
# NOTE : Require `FireFunction` Node with variable `animation_player`, containing animation named "Firing"

@export var damage_min : float = 2.25
@export var damage_max : float = 4.5
var firing := false

@onready var fire_function := $FireFunction
@onready var fire_function_anim : AnimationPlayer = $FireFunction.animation_player

@export_node_path("Area2D", "RayCast2D") var line_of_sight_; var line_of_sight : Node2D
@export_node_path("Area2D", "RayCast2D") var obstacle_sight_; var obstacle_sight : Node2D

var parent : Node
var trigger_area : NodePath
var on_line := false

const player_bodies : Array[StringName] = [&"Head", &"DamageCollision"]

func set_on_line(object : Node2D) -> void:
    if player_bodies.has(object.get_name()):
        on_line = true
func set_off_line(object : Node2D) -> void:
    if !player_bodies.has(object.get_name()):
        on_line = false

func _enter_tree() -> void:
    parent = get_parent()

func _on_line_of_fire_tree_entered() -> void:
    $LineOfSight/LineOfFire.enabled = false

func _ready() -> void:

    line_of_sight = get_node_or_null(line_of_sight_)
    obstacle_sight = get_node_or_null(obstacle_sight_)

    trigger_area =\
        ^"../TriggerArea" if parent.custom_trigger == null else\
        parent.custom_trigger_

    if  line_of_sight != null and\
        line_of_sight is CollisionObject2D:

        if line_of_sight is RayCast2D:
            line_of_sight.add_exception(get_node(trigger_area))
            line_of_sight.add_exception(Global.player_destroy_through)

        elif line_of_sight is Area2D:

            line_of_sight.body_entered.connect(set_on_line)
            line_of_sight.body_exited.connect(set_off_line)

            line_of_sight.area_entered.connect(set_on_line)
            line_of_sight.area_exited.connect(set_off_line)

    fire_function_anim.animation_finished.connect(parent._on_weapon_animation_finished)

func _process(_delta : float) -> void:
    parent.firing = firing

func _physics_process(_delta : float) -> void:
    if parent.triggered:
        if line_of_sight is RayCast2D:
            on_line = line_of_sight.is_colliding() and !obstacle_sight.is_colliding()

func fire() -> void:
    $FireFunction.animation_player.play(&"Firing")
