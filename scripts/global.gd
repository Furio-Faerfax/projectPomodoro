extends Node
signal send_console_message(str)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func pr(_str: String):
	send_console_message.emit(_str)
	print(_str)
	
