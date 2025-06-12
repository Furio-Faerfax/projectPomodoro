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
@onready var audio: AudioStreamPlayer = $audio
@onready var timer: Timer = $Timer
@onready var time_label: Label = %time_label
@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var round_label: Label = %round_label
@onready var state_label: Label = %state_label
@onready var start: Button = %Start
@onready var pause: Button = %Pause
@onready var time_settings: AcceptDialog = $time_settings
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

const MENU_SVG = preload("res://assets/menu.svg")
const MENU_OPEN_SVG = preload("res://assets/menu_open.svg")

enum STATES {
	IDLE,
	WORK,
	MINI_BREAK,
	MAIN_BREAK,
}

@export var working_time := 25
@export var mini_break_time := 5
@export var main_break_time := 20

var timer_step := 1
var time_in_minutes: int = 1

var autoplay := false
var time_in_seconds :int = 0
var time_in_seconds_left := time_in_seconds
var time_counting :int = 0

var paused := false

var hours := 0
var minutes := 0
var seconds := 0

var state: STATES = STATES.WORK
var max_rounds := 4
var _round := 1
var cycle := 1

var state_labels = ["WORK", "MINIBREAK", "MAINBREAK"]

var menu_shown := false
var menu_offset = 5
var window_offset = 5
var initial_pomodoro_pos :Vector2 = Vector2()
var initial_todo_pos :Vector2i = Vector2()

func _ready() -> void:
	
	if undock_todo.button_pressed:
		undocking_todo()
	
	
	about_dialog.get_node("label").text = Settings.get_app_infos()
	if Settings.init:
		time_settings.popup()
	
	time_in_minutes = working_time
	time_in_seconds = time_in_minutes*60
	time_in_seconds_left = time_in_seconds
	update_visuals()
	progress_bar.max_value = time_in_seconds
	progress_bar.value = time_in_seconds
	
	state_label.text = state_labels[0]
	round_label.text = str(_round)+" / "+str(max_rounds)+" in cycle: "+str(cycle)

func _on_timer_timeout() -> void:
	if time_in_seconds_left > 0:
		time_counting += 1
		time_in_seconds_left -= 1
		progress_bar.value -= 1
		timer.start()
		update_visuals()
	else:
		if !autoplay:
			start.show()
			pause.hide()
		
		audio.stop()
		match state:
			STATES.WORK:
				audio.set_sound("work_over")
			STATES.MINI_BREAK:
				audio.set_sound("mini-break_over")
			STATES.MAIN_BREAK:
				audio.set_sound("main-break_over")
			_:
				pass
		
		audio.play(0.0)
		choose_next_time()


func _on_start_pressed() -> void:
	start.hide()
	pause.show()
	if !paused:
		audio.stop()
		match state:
			STATES.WORK:
				audio.set_sound("work_start")
			STATES.MINI_BREAK:
				audio.set_sound("break_start")
			STATES.MAIN_BREAK:
				audio.set_sound("break_start")
			_:
				pass
		audio.play(0.0)
	
	if timer.is_stopped():
		if !paused:
			setting_up_timer(true)
		else:
			timer.start()

#Curently resets the current round
func _on_stop_pressed() -> void:
	start.show()
	pause.hide()
	if paused:
		paused = false
	timer.stop()
	time_in_seconds_left = time_in_seconds
	update_visuals()
	progress_bar.value = progress_bar.max_value

func _on_pause_pressed() -> void:
	start.show()
	pause.hide()
	paused = true
	timer.stop()

func _on_skip_pressed() -> void:#Currently no sound when skipping
	_on_stop_pressed()
	if autoplay:
		start.hide()
		pause.show()
	
	choose_next_time()

func _on_autoplay_button_toggled(toggled_on: bool) -> void:
	autoplay = toggled_on


func setting_up_timer(force_start):
	time_in_seconds = time_in_minutes*60
	time_in_seconds_left = time_in_seconds
	progress_bar.max_value = time_in_seconds
	progress_bar.value = time_in_seconds
	update_visuals()
	
	if autoplay or force_start:
		timer.start(timer_step)

func update_visuals():
	
	seconds = time_in_seconds_left % 60
	minutes = int(time_in_seconds_left/60.0)
	hours = int((time_in_seconds_left/60.0)/60.0)
	
	if minutes > 60:
		minutes -= hours*60
		
	var second_str = str(seconds) if seconds > 9 else "0"+str(seconds)
	var minute_str = "00" if minutes == 60 else str(minutes) if minutes > 9 else "0"+str(minutes)
	var hour_str = str(hours) if hours > 9 else "0"+str(hours)
	time_label.text = hour_str+":"+minute_str+":"+second_str if hours > 0 else minute_str+":"+second_str

func choose_next_time():
	match state:
		STATES.IDLE:
			state = STATES.WORK
		STATES.WORK:
			if _round < max_rounds:
				state = STATES.MINI_BREAK

					
				time_in_minutes = mini_break_time
				setting_up_timer(false)
				state_label.text = state_labels[1]
				_round += 1
			else:
				_round = 1
				cycle += 1
				state = STATES.MAIN_BREAK
				time_in_minutes = main_break_time
				state_label.text = state_labels[2]
				setting_up_timer(false)
		STATES.MINI_BREAK:
				state = STATES.WORK
				time_in_minutes = working_time
				state_label.text = state_labels[0]
				setting_up_timer(false)
				round_label.text = str(_round)+" / "+str(max_rounds)+" in cycle: "+str(cycle)
		STATES.MAIN_BREAK:
				state = STATES.WORK
				time_in_minutes = working_time
				state_label.text = state_labels[0]
				setting_up_timer(false)
				round_label.text = str(_round)+" / "+str(max_rounds)+" in cycle: "+str(cycle)

func _on_accept_dialog_canceled() -> void:
	pass # Replace with function body.


func _on_accept_dialog_confirmed() -> void:
	var work_val = time_settings.get_node("container/working_time/value").text as int
	var mini_val = time_settings.get_node("container/mini_break/value").text as int
	var main_val = time_settings.get_node("container/main_break/value").text as int
	
	working_time = work_val
	mini_break_time = mini_val
	main_break_time = main_val
	
	if timer.is_stopped():
		match state:
			STATES.WORK:
				time_in_minutes = working_time
			STATES.MINI_BREAK:
				time_in_minutes = mini_break_time
			STATES.MAIN_BREAK:
				time_in_minutes = main_break_time
			_:
				pass
		setting_up_timer(false)


func _on_options_2_pressed() -> void:
	time_settings.popup()


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)


func _on_button_pressed() -> void:
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



func undocking_todo():
		print(get_screen_position())
		get_window().position.x -= todo_window.size.x/2
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
		get_window().position.x += todo_window.size.x/2
	tabs.show()
	pomodoro_container.reparent(pomodoro)
	pomodoro_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_bg.position.y = menu.get_global_transform()[2].y+menu.icon.get_height()+menu_offset
	
	todo_container.reparent(todo)
	todo_window.hide()

func _on_undock_todo_toggled(toggled_on: bool) -> void:
	print(menu.icon.get_height())
	if toggled_on:
		undocking_todo()
	else:
		docking_todo()


func _on_todo_window_close_requested() -> void:
	docking_todo()
	undock_todo.button_pressed = false
