extends VBoxContainer
@onready var entries: VBoxContainer = %entries
@onready var info: Label = %info

const ENTRY = preload("res://scenes/entry.tscn")

var entrie_count := 0
var entries_checked := 0

func _ready() -> void:
	entrie_count = entries.get_child_count()
	update_info()
	Signals.todo_deleted.connect(_on_todo_delete)
	Signals.todo_entry_checked.connect(_on_todo_checked)
	Signals.move_entry.connect(_on_moving_entries)

func _on_new_pressed() -> void:
	var instance = ENTRY.instantiate()
	entrie_count += 1
	entries.add_child(instance)
	update_info()

func _on_delete_selected_pressed() -> void:
	for entry in entries.get_children():
		if entry.get_node("select").button_pressed:
			entry.queue_free()

func update_info():
	info.text = str(entries_checked)+" / "+str(entrie_count)+" done!"

func _on_todo_delete(was_checked):
	if was_checked:
		entries_checked -= 1
	entrie_count -= 1
	update_info()

func _on_todo_checked(boo):
	if boo:
		entries_checked += 1
	else:
		entries_checked -= 1
	update_info()

func _on_moving_entries(dir, entry_to_move):
	var count := 0
	for entry in entries.get_children():
		if entry == entry_to_move:
			if count == 0 and dir < 0 or (count == entries.get_child_count()-1 and dir > 0):
				break
			entries.move_child(entry, count+dir)
			break
		count += 1
