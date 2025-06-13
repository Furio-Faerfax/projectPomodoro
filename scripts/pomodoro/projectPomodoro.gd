#Copyright (c) 2025 Furio Faerfax
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
extends Control
@onready var about_dialog: AcceptDialog = $about_dialog
@onready var menu_bg: ColorRect = %menu_bg
@onready var menu: Button = %menu
@onready var pomodoro: TabBar = %pomodoro
@onready var tabs: TabContainer = %tabs
@onready var undock_todo: CheckButton = %undock_todo
@onready var pomodoro_container: Control = %pomodoro_container
@onready var todo: TabBar = %todo
@onready var todo_container: Control = %todo_container
@onready var todo_window: Window = %todo_window
@onready var time_settings: AcceptDialog = $time_settings
@onready var timer: Timer = %Timer

var menu_offset = 5
var window_offset = 5
var initial_pomodoro_pos :Vector2 = Vector2()
var initial_todo_pos :Vector2i = Vector2()

func _ready() -> void:
	if undock_todo.button_pressed:
		undocking_todo()
	
	about_dialog.get_node("about_label").text = Settings.get_app_infos()
	if Settings.init:
		time_settings.popup()

func _on_accept_dialog_canceled() -> void:
	pass # Replace with function body.

func _on_accept_dialog_confirmed() -> void:
	var work_val = time_settings.get_node("container/working_time/value").text as int
	var mini_val = time_settings.get_node("container/mini_break/value").text as int
	var main_val = time_settings.get_node("container/main_break/value").text as int
	
	timer.working_time = work_val
	timer.mini_break_time = mini_val
	timer.main_break_time = main_val
	
	if timer.is_stopped():
		match timer.state:
			timer.STATES.WORK:
				timer.time_in_minutes = timer.working_time
			timer.STATES.MINI_BREAK:
				timer.time_in_minutes = timer.mini_break_time
			timer.STATES.MAIN_BREAK:
				timer.time_in_minutes = timer.main_break_time
			_:
				pass
		timer.setting_up_timer(false)

func _on_about_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)

func undocking_todo():
		print(get_screen_position())
		get_window().position.x -= int(todo_window.size.x/2.0)
		todo_window.position = get_screen_position()
		todo_window.position.x = todo_window.position.x+get_window().size.x+window_offset
		initial_todo_pos = todo_window.position
		initial_pomodoro_pos = get_screen_position()
		
		pomodoro_container.reparent(tabs.get_parent())
		pomodoro_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tabs.hide()
		menu_bg.position.y = menu.get_global_transform()[2].y+menu.icon.get_height()+menu_offset
		
		todo_container.reparent(todo_window)
		todo_window.show()

func docking_todo():
	if initial_todo_pos == todo_window.position and initial_pomodoro_pos == get_screen_position():#just if both windows havent move, reset the main windows position
		get_window().position.x += int(todo_window.size.x/2.0)
	tabs.show()
	pomodoro_container.reparent(pomodoro)
	pomodoro_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_bg.position.y = menu.get_global_transform()[2].y+menu.icon.get_height()+menu_offset
	
	todo_container.reparent(todo)
	todo_window.hide()

func _on_todo_window_close_requested() -> void:
	docking_todo()
	undock_todo.button_pressed = false
