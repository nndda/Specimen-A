extends Node2D

var init_pos : Vector2

func FiftyFifty() -> bool:
	randomize()
	return true if randf() >= 0.5 else false

func _ready():
	global_position = init_pos
	$Position2D.global_position = glbl.head_pos

	$BloodSplash.emitting = true
	randomize()

	look_at(glbl.head_pos)
	$Torso.rotation_degrees += rand_range(-5,5)

	$Torso/Head.rotation_degrees = rand_range(-30,30)

#	$Torso/RArm.rotation_degrees		= rand_range(-90,30)
	$Torso/RArm.rotation_degrees		= rand_range(-75,-30)
	$Torso/RArm/Hand.rotation_degrees	= rand_range(0,180)
	$Torso/LArm.rotation_degrees		= rand_range(-90,30)
	$Torso/LArm/Hand.rotation_degrees	= rand_range(0,180)

#	$Torso/RLeg.rotation_degrees		= rand_range(-15,30)
	$Torso/RLeg.rotation_degrees		= rand_range(30,75)
	$Torso/RLeg/Feet.rotation_degrees	= rand_range(0,-60)
	$Torso/LLeg.rotation_degrees		= rand_range(-15,30)
	$Torso/LLeg/Feet.rotation_degrees	= rand_range(0,-60)

	if randf() >= 0.8:
		$Torso.region_rect = Rect2(96.0,320.0,32.0,32.0)
	else:
		$Torso.region_rect = Rect2(128.0,320.0,32.0,32.0)


	DecapLimb("RArm")
	DecapLimb("LArm")
	DecapLimb("RLeg")
	DecapLimb("LLeg")


func DecapLimb(limb:String) -> void:

	var limb_n = "Hand" if limb.ends_with("Arm") else "Feet"

	if FiftyFifty():
		get_node("Torso/" + limb + "/" + limb_n + "-BloodSplatterDecap").show()
		get_node("Torso/" + limb + "/" + limb_n ).queue_free()
		if FiftyFifty():
			get_node("Torso/" + limb + "-Blood").show()
			get_node("Torso/" + limb + "-Blood").rotation_degrees = get_node("Torso/" + limb ).rotation_degrees
			get_node("Torso/" + limb ).queue_free()
		else:
			get_node("Torso/" + limb + "-Blood").queue_free()
	else:
		get_node("Torso/" + limb + "/" + limb_n + "-BloodSplatterDecap").queue_free()

func _physics_process(_delta):
	BloodTrail()

var blood_trails = false
func BloodTrail() -> void:
	$Position2D.global_position = glbl.head_pos

	if blood_trails:
		$Position2D.global_position = glbl.head_pos
		if glbl.moving or glbl.attacking:
			if $BloodTrail.points.size() <= 30:
				$BloodTrail.add_point($Position2D.position)
			else:
				blood_trails = false



func _on_Position2D_tree_entered():
	$Position2D.global_position = glbl.head_pos
func _on_BloodTrail_tree_entered():
	BloodTrail()
func _on_BloodTrailTrigger_body_entered(body):
	if body.get_name() == "Head":
		blood_trails = true
		$BloodTrailTrigger.queue_free()
