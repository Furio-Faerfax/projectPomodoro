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

@onready var timer: Timer = $Timer
@onready var time_label: Label = $layout/time_visuals/time_label
@onready var progress_bar: TextureProgressBar = $layout/time_visuals/ProgressBar
@onready var round_label: Label = $layout/menu_container/round_label
@onready var state_label: Label = $layout/menu_container/state_label
@onready var start: Button = $layout/timer_controls/Start
@onready var pause: Button = $layout/timer_controls/Pause

enum STATES {
	IDLE,
	WORK,
	MINI_BREAK,
	MAIN_BREAK,
}

@export var working_time := 25
@export var mini_break_time := 5
@export var main_break_time := 20

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

func _ready() -> void:
	time_in_minutes = working_time
	time_in_seconds = time_in_minutes*60
	time_in_seconds_left = time_in_seconds
	update_visuals()
	progress_bar.max_value = time_in_seconds
	progress_bar.value = time_in_seconds
	
	state_label.text = state_labels[0]
	round_label.text = str(_round)+" / "+str(max_rounds)+" in cycle: "+str(cycle)
	#choose_next_time()

func _on_timer_timeout() -> void:
	if time_in_seconds_left > 0:
		time_counting += 1
		time_in_seconds_left -= 1
		progress_bar.value -= 1
		timer.start()
		update_visuals()
	else:
		choose_next_time()


func _on_start_pressed() -> void:
	start.hide()
	pause.show()
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

func _on_skip_pressed() -> void:
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
		timer.start()

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
