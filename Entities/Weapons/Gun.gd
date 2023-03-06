extends Node2D

var damage	: float = 4.25
var firing	: bool = false

@export_node_path("Area2D","RayCast2D")		var line_of_sight
@export_node_path("AnimationPlayer")		var firing_animation_player = NodePath("FireFunction/AnimationPlayer")

@onready var trigger_area	: NodePath	= NodePath(get_parent().custom_trigger)
@onready var on_line		: bool		= false


func _on_line(object) -> void:
	if (
		object.get_name() == "Head" or
		object.get_name() == "DamageCollision" ):
		on_line = true
func _off_line(object) -> void:
	if (
		object.get_name() == "Head" or
		object.get_name() == "DamageCollision" ):
		on_line = false


func _ready():

	if get_node(line_of_sight) != null:

		if line_of_sight is RayCast2D:
			line_of_sight.add_exception(get_node(trigger_area))

		elif line_of_sight is Area2D:

			for signal_on in [
				"body_entered", "area_exited" ]:
				get_node(line_of_sight).connect( signal_on, Callable(self,"_on_line") )

			for signal_off in [
				"body_exited", "area_exited" ]:
				get_node(line_of_sight).connect( signal_off, Callable(self,"_off_line") )

	else:
		dbg.err_unexpected_value("weapon_node","null")

	if get_node_or_null(firing_animation_player) != null:
		get_node(firing_animation_player).connect(
			"animation_finished",
			Callable(get_parent(),"Weapon_AnimationFinished"))
	else:
		dbg.err_unexpected_value("firing_animation_player","null")


func _process(_delta):

	get_parent().firing = firing


func _physics_process(_delta):

	if get_parent().triggered:

		if get_node(line_of_sight) is RayCast2D:
			on_line = get_node(line_of_sight).is_colliding()

func Fire() -> void:
	firing_animation_player.play("Firing")
