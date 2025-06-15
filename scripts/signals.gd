extends Node
signal todo_entry_checked(boo)
signal todo_deleted(was_checked)
signal move_entry(dir, entry)


func _ready() -> void:
	todo_entry_checked.connect(_into_void)
	todo_deleted.connect(_into_void)
	move_entry.connect(_into_void_2)


func _into_void(_var1):
	pass
func _into_void_2(_var1, _var2):
	pass
