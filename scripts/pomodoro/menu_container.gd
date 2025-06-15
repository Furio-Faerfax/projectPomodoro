extends Control

@onready var timer: Timer = %Timer
@onready var time_settings: AcceptDialog = %time_settings
@onready var menu: Button = %menu
@onready var audio: AudioStreamPlayer = %audio
@onready var about_dialog: AcceptDialog = %about_dialog
@onready var menu_bg: ColorRect = %menu_bg

const MENU_SVG = preload("res://assets/menu.svg")
const MENU_OPEN_SVG = preload("res://assets/menu_open.svg")

var sounds := true

var menu_shown := false
#
func _ready() -> void:
	if !Settings.web_export:
		about_dialog.initial_position =Window.WINDOW_INITIAL_POSITION_ABSOLUTE
		time_settings.initial_position =Window.WINDOW_INITIAL_POSITION_ABSOLUTE
		reposition_dialogs()
	
func reposition_dialogs():
	var window_center  = get_window().position as Vector2i + get_window().size/2
	about_dialog.position = window_center - about_dialog.size/2
	time_settings.position = window_center as Vector2i - time_settings.size/2

func _on_autoplay_button_toggled(toggled_on: bool) -> void:
	timer.autoplay = toggled_on
	close_menu()


func _on_undock_todo_pressed() -> void:
	pass # Replace with function body.
	
func _on_set_time_pressed() -> void:
	if !Settings.web_export:
		reposition_dialogs()
	time_settings.popup()
	close_menu()


func _on_undock_todo_toggled(toggled_on: bool) -> void:
	#print(menu.icon.get_height())
	if toggled_on:
		get_tree().get_first_node_in_group("app").undocking_todo()
	else:
		get_tree().get_first_node_in_group("app").docking_todo()
	close_menu()


func close_menu():
	menu.icon = MENU_SVG
	menu_bg.hide()
	menu_shown = false
	
func _on_about_pressed() -> void:
	if !Settings.web_export:
		reposition_dialogs()
	about_dialog.popup()
	close_menu()

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
	close_menu()


func _on_sounds_toggled(toggled_on: bool) -> void:
	sounds = toggled_on
	if !toggled_on:
		audio.volume_db = -100.0
	else:
		audio.volume_db = 0.0
