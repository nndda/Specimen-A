extends Node2D

var is_ready = false

#var init_pos : Vector2 = Vector2.ZERO
#@export var use_init_pos : bool = true
#@export var active = false

func FiftyFifty() -> bool:
	randomize()
	return true if randf() >= 0.5 else false

func _enter_tree():
	show()
func _ready():
#	if use_init_pos:
#		global_position = init_pos
#		look_at(glbl.head_pos)

	$Reposition.global_position = glbl.head_pos

	$BloodSplash.emitting = true
	randomize()

	$Torso.rotation_degrees += randf_range(-5,5)

	$Torso/Head.rotation_degrees = randf_range(-30,30)

	$Torso/RArm.rotation_degrees		= randf_range(-75,-30)
	$Torso/RArm/Hand.rotation_degrees	= randf_range(0,180)
	$Torso/LArm.rotation_degrees		= randf_range(-90,30)
	$Torso/LArm/Hand.rotation_degrees	= randf_range(0,180)

	$Torso/RLeg.rotation_degrees		= randf_range(30,75)
	$Torso/RLeg/Feet.rotation_degrees	= randf_range(0,-60)
	$Torso/LLeg.rotation_degrees		= randf_range(-15,30)
	$Torso/LLeg/Feet.rotation_degrees	= randf_range(0,-60)

	$Torso.region_rect = (
		Rect2(96.0,320.0,32.0,32.0) if randf() >= 0.8 else
		Rect2(128.0,320.0,32.0,32.0) )

	for limb in [
		"RArm","LArm","RLeg","LLeg" ]:
		DecapLimb(limb)

#	visible = active
	is_ready = true
	$VisibilityHandler.show()

func DecapLimb(limb:String) -> void:

	var limb_n = "Hand" if limb.ends_with("Arm") else "Feet"

#	dbg.print_header(self,"DecapLimb()")
#	printt( "|", str(limb) + ", " + str(limb_n) )

	if FiftyFifty():
#		printt( "|",	"Torso/" + limb + "/" + limb_n + "-BloodSplattersDecap")
		get_node(		"Torso/" + limb + "/" + limb_n + "-BloodSplattersDecap").show()

#		printt( "|",	"Torso/" + limb + "/" + limb_n )
		get_node(		"Torso/" + limb + "/" + limb_n ).queue_free()

		if FiftyFifty():

#			printt( "|",	"Torso/" + limb + "-Blood" )
			get_node(		"Torso/" + limb + "-Blood" ).show()
			get_node(		"Torso/" + limb + "-Blood" ).rotation_degrees = get_node( "Torso/" + limb ).rotation_degrees

#			printt( "|",	"Torso/" + limb )
			get_node(		"Torso/" + limb ).queue_free()

		else:
#			printt( "|",	"Torso/" + limb + "-Blood" )
			get_node(		"Torso/" + limb + "-Blood" ).queue_free()

	else:
#		printt( "|",	"Torso/" + limb + "/" + limb_n + "-BloodSplattersDecap" )
		get_node(		"Torso/" + limb + "/" + limb_n + "-BloodSplattersDecap" ).queue_free()

func _physics_process(_delta):
#	visible = active
	BloodTrail()

var blood_trails = false
func BloodTrail() -> void:
#	$Reposition.global_position = glbl.head_pos

	if blood_trails and visible:
		$Reposition.global_position = glbl.head_pos
		if glbl.moving or glbl.attacking:
			if $BloodTrail.points.size() <= 50:
				$BloodTrail.add_point($Reposition.position)
			else:
				blood_trails = false
				process_mode = Node.PROCESS_MODE_DISABLED



func _on_Reposition_tree_entered():
	$Reposition.global_position = glbl.head_pos
func _on_BloodTrail_tree_entered():
	BloodTrail()
func _on_BloodTrailTrigger_body_entered(body):
	if body.get_name() == "Head":
		blood_trails = true
		$BloodTrailTrigger.queue_free()

