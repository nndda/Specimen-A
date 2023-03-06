extends VBoxContainer

@export var data : Array

func _enter_tree():
	if data.size() % 2 != 0:
		push_error("\"data\" is not even")

func _process(_delta):
	set_vars()

func set_vars() -> void:

	if get_child_count() < float(data.size()) / 2:
		for varn in float(data.size()) / 2:

			var container = HBoxContainer.new()
			var label = Label.new()
			var value = Label.new()

			label.size_flags_horizontal = 3

			label.text = str( data[ varn * 2 ] )
			value.text = str( data[ varn * 2 + 1 ] )

			container.call_deferred("add_child",label)
			container.call_deferred("add_child",value)

			add_child( container )

	elif get_child_count() == float(data.size()) / 2:
		mon_vars()


func mon_vars() -> void:

	for chd in get_children():

		chd.get_child(0).text = str( data[ chd.get_index() * 2 ] )
		chd.get_child(1).text = str( data[ chd.get_index() * 2 + 1 ] )
