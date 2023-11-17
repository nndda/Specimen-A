extends Node2D

@export_node_path("Node") var root_
@onready var root : Node = get_node( root_ )
@onready var lights : Sprite2D = $Sprite2D/Sprite2D
@onready var hit_spark : GPUParticles2D = $BulletSpark
@onready var physics_body : PhysicsBody2D = $StaticBody2D
@onready var health : float

func _ready():  if root.immune != null: root.immune = true
func _exit_tree(): if root.immune != null: root.immune = false

func _on_physic_body_ready():
    health = $StaticBody2D.health

func _on_physic_body_hit():
    hit_spark.emitting = true
    lights.modulate.a = remap(
        physics_body.health, health, 0.0, 1.0, 0.08
    )
