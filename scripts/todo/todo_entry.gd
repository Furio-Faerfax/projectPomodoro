extends Panel
@onready var select: CheckBox = $select
@onready var task: LineEdit = $task
@onready var done: CheckBox = $done
@onready var line: ColorRect = $line

@export var tex := ""


func _ready() -> void:
	task.text = tex

func _on_done_toggled(toggled_on: bool) -> void:
	if toggled_on:
		task.editable = false
		line.show()
		Signals.todo_entry_checked.emit(true)
	else:
		task.editable = true
		line.hide()
		Signals.todo_entry_checked.emit(false)

func _on_delete_pressed() -> void:
	Signals.todo_deleted.emit(done.button_pressed)
	queue_free()

func _on_pos_up_pressed() -> void:
	Signals.move_entry.emit(-1, self)

func _on_pos_down_pressed() -> void:
	Signals.move_entry.emit(1, self)
