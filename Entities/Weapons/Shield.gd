extends Node2D

@export_node_path("Node") var root_
@onready var root : Node = get_node( root_ )
@onready var lights : Sprite2D = $Sprite2D/Glow
@onready var hit_spark : GPUParticles2D = $BulletSpark
@onready var physics_body : PhysicsBody2D = $PhysicBody2D
@onready var health : float

func _ready() -> void: if root.immune != null: root.immune = true
func _exit_tree() -> void: if root.immune != null: root.immune = false

func _on_physic_body_ready() -> void:
    health = $PhysicBody2D.health

func _on_physic_body_hit() -> void:
    hit_spark.emitting = true
    lights.modulate.a = remap(
        physics_body.health, health, 0.0, 1.0, 0.08
        )

func _on_physic_body_destroyed() -> void:
    lights.queue_free()
    $Sprite2D.reparent( Global.layer_dict[ "Objects/Corpses" ] )
