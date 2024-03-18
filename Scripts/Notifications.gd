extends CanvasLayer

@export_node_path("Label") var notification_title_ : NodePath
var notification_title : Label
@export_node_path("RichTextLabel") var notification_desc_ : NodePath
var notification_desc : RichTextLabel
@export_node_path("TextureRect") var notification_img_ : NodePath
var notification_img : TextureRect

@onready var level_label : Label = $Control/SceneLabels/LevelLabels
@onready var level_label_sub : Label = $Control/SceneLabels/LevelLabels/Sub

@onready var level_label_anim : AnimationPlayer = $Control/SceneLabels/LevelLabels/AnimationPlayer
@onready var level_label_anim_sub : AnimationPlayer = $Control/SceneLabels/LevelLabels/AnimationPlayer/Sub

var queue : Array[Dictionary] = []

signal notification_fired(item : Dictionary)

func _ready() -> void:
    notification_title = get_node(notification_title_)
    notification_desc =  get_node(notification_desc_)


func fire_notif(item : Dictionary) -> void:
    notification_title.text = item["title"]
    notification_desc.text = item["desc"]
    notification_img.texture = load(item["img_res"])

signal level_label_displayed
signal level_label_sub_displayed

func set_level_label(string : String, duration : float = 3.5) -> void:
    level_label.text = string
    level_label_anim.play(&"Display")

    await get_tree().create_timer(duration).timeout
    level_label_anim.play_backwards(&"Display")

func set_level_label_sub(string : String, duration : float = 3.5) -> void:
    level_label_sub.text = string
    level_label_anim_sub.play(&"Display")

    await get_tree().create_timer(duration).timeout
    level_label_anim_sub.play_backwards(&"Display")

func _on_level_label_anim_finished(_anim_name : StringName) -> void:
    level_label_displayed.emit()

func _on_level_label_anim_sub_finished(_anim_name : StringName) -> void:
    level_label_sub_displayed.emit()
