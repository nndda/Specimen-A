extends CanvasLayer

@export_node_path("Label") var notification_title_ : NodePath
var notification_title : Label
@export_node_path("RichTextLabel") var notification_desc_ : NodePath
var notification_desc : RichTextLabel
@export_node_path("TextureRect") var notification_img_ : NodePath
var notification_img : TextureRect

var queue : Array = []

signal notification_fired(item : Item)

class Item extends Object:
    var title := ""
    var desc := ""
    var img_res := ""

    func _init(
        title_ : String,
        desc_ : String,
        img_res_ : String
        ):
        title = title_
        desc = desc_
        img_res = img_res_

func _ready() -> void:
    notification_title = get_node(notification_title_)
    notification_desc =  get_node(notification_desc_)

func fire_notif(item : Item) -> void:
    notification_title.text = item.title
    notification_desc.text = item.desc
    notification_img.texture = load(item.img_res)
