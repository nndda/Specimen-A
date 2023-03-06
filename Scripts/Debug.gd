extends Node

func quote(text:String) -> String:
	return "\"" + text + "\""

func err_unexpected_value(variable:String,value:String) -> void:
	push_error(quote(variable) + " is " + value)

# debug stuff
func header(at_str, on_str) -> String:
	return str(
		" ================ at: "
		+ str(at_str)
		+ ", on: "
		+ str(on_str)
		)
func print_header(at_str, on_str) -> void:
	print_rich(
		" [color=cyan]"		+ " ================ at: "		+ "[/color]" +
		" [color=white]"	+ str(at_str)					+ "[/color]" +
		" [color=cyan]"		+ ", on: "						+ "[/color]" +
		" [color=white]"	+ str(on_str)					+ "[/color]"
		)

func print_table(header_ : Array, content : Array) -> void:

	if content.size() % 2 != 0:
		push_error(" array size % 2 != 0 ")

	else:
		printt( "|" , header_[0], header_[1] )
		for n in content.size() / 2:
			printt( "|" , content[n*2], content[n*2+1] )
