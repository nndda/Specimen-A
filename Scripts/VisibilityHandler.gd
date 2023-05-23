extends VisibleOnScreenEnabler2D

var visibility_query : Array[ CanvasItem ]

func _on_tree_entered() -> void:
    for c in get_parent().get_children(): if (
        c != self and c is CanvasItem ): visibility_query.append( c )
#	get_parent().connect( "child_entered_tree",
#	Callable( self, "append_visibility_query" ) )
    get_parent().connect( "child_exiting_tree",
    Callable( self, "remove_visibility_query" ) )

#func append_visibility_query( c ) -> void:
#	if c != self and c is CanvasItem: visibility_query.append( c )
func remove_visibility_query( c ) -> void:
    if c is CanvasItem: if visibility_query.has( c ):
        visibility_query.erase( c )

func _on_screen_entered():	for c in visibility_query: c.show()
func _on_screen_exited():	for c in visibility_query: c.hide()
