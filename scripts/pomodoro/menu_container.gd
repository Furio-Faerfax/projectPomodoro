extends Control

@onready var timer: Timer = %Timer
@onready var time_settings: AcceptDialog = %time_settings
@onready var menu: Button = %menu
@onready var audio: AudioStreamPlayer = %audio
@onready var about_dialog: AcceptDialog = %about_dialog
@onready var menu_bg: ColorRect = %menu_bg

const MENU_SVG = preload("res://assets/menu.svg")
const MENU_OPEN_SVG = preload("res://assets/menu_open.svg")

var menu_shown := false

func _on_autoplay_button_toggled(toggled_on: bool) -> void:
	timer.autoplay = toggled_on


func _on_undock_todo_pressed() -> void:
	pass # Replace with function body.
	
func _on_set_time_pressed() -> void:
	time_settings.popup()


func _on_undock_todo_toggled(toggled_on: bool) -> void:
	print(menu.icon.get_height())
	if toggled_on:
		get_tree().get_first_node_in_group("app").undocking_todo()
	else:
		get_tree().get_first_node_in_group("app").docking_todo()



func _on_about_pressed() -> void:
	about_dialog.popup()
	menu.icon = MENU_SVG
	menu_bg.hide()
	menu_shown = false

func _on_menu_pressed() -> void:
	menu_shown = !menu_shown
	if menu_shown:
		menu_bg.show()
		menu.icon = MENU_OPEN_SVG
	else:
		menu_bg.hide()
		menu.icon = MENU_SVG


func _on_reload_sound_pressed() -> void:
	audio.get_sounds()
