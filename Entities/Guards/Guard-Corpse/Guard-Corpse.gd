extends Node2D

var is_ready : bool = false
var repos_node : Node2D
@onready var blood_trail_node : Line2D = $BloodTrail
@onready var visibility_handler : Node2D = $VisibilityHandler/VisibleOnScreenEnabler2D

func fifty2() -> bool:
    randomize(); return [true, false].pick_random()

func _enter_tree() -> void:
    visible = true

func _ready() -> void:
## Generate randomized corpse
    randomize()
    $Reposition.global_position = Global.head_pos

    $BloodSplash.emitting = true

    $Torso.rotation_degrees             += randf_range(-5,5)

    $Torso/Head.rotation_degrees        = randf_range(-30,30)

    $Torso/RArm.rotation_degrees        = randf_range(-75,-30)
    $Torso/RArm/Hand.rotation_degrees   = randf_range(0,180)
    $Torso/LArm.rotation_degrees        = randf_range(-90,30)
    $Torso/LArm/Hand.rotation_degrees   = randf_range(0,180)

    $Torso/RLeg.rotation_degrees        = randf_range(30,75)
    $Torso/RLeg/Feet.rotation_degrees   = randf_range(0,-60)
    $Torso/LLeg.rotation_degrees        = randf_range(-15,30)
    $Torso/LLeg/Feet.rotation_degrees   = randf_range(0,-60)

    $Torso.region_rect.position.x += 32 if randf() >= 0.8 else 0

    for limb : String in ["RArm", "LArm", "RLeg", "LLeg"]: decap_limb(limb)
    is_ready = true

func decap_limb(limb : String) -> void:
    var limb_n := "Hand" if limb.ends_with("Arm") else "Feet"

    if fifty2():
        get_node("Torso/%s/%s-BloodSplattersDecap" % [limb, limb_n]).queue_free()
    else:
        get_node("Torso/%s/%s-BloodSplattersDecap" % [limb, limb_n]).show()
        get_node("Torso/%s/%s" % [limb, limb_n]).queue_free()

        if fifty2():
            get_node("Torso/%s-Blood" % limb).queue_free()
        else:
            get_node("Torso/%s-Blood" % limb).show()
            get_node("Torso/%s-Blood" % limb).rotation_degrees = get_node("Torso/%s" % limb).rotation_degrees
            get_node("Torso/%s" % limb).queue_free()

func _process(_delta : float) -> void:
    visibility_handler.global_position = self.global_position

func _physics_process(_delta : float) -> void:
    if blood_trails:
        blood_trail()

var blood_trails := false
func blood_trail() -> void:
    if visible:
        repos_node.global_position = Global.head_pos
        if Global.moving_or_attacking:
            if blood_trail_node.points.size() <= 70:
                blood_trail_node.add_point(repos_node.position)
            else:
                blood_trails = false
                process_mode = Node.PROCESS_MODE_DISABLED

func _on_Reposition_tree_entered() -> void:
    repos_node = $Reposition
    repos_node.global_position = Global.head_pos

func _on_BloodTrail_tree_entered() -> void:
    blood_trail()

func _on_BloodTrailTrigger_body_entered(body) -> void:
    if body.get_name() == &"Head":
        blood_trails = true
        $BloodTrailTrigger.queue_free()

