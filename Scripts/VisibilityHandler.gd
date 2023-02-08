extends VisibilityNotifier2D

func _enter_tree():
	self.show()

func _ready():
	var err = connect( "ready", get_parent(), "hide" )
	if err != 0:
		push_warning(" > on : " + str( self ) + ", " + str(err))
#	print( " > on : " + str( self ) + ", " + str(err) )

func _on_VisibilityHandler_screen_entered():
	get_parent().show()
func _on_VisibilityHandler_screen_exited():
	get_parent().hide()
