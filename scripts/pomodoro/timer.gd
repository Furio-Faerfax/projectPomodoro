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
extends Timer

@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var time_visuals: Control = %time_visuals
@onready var audio: AudioStreamPlayer = %audio
@onready var btn_start: Button = %Start
@onready var pause: Button = %Pause
@onready var state_label: Label = %state_label
@onready var round_label: Label = %round_label

@export var working_time := 25
@export var mini_break_time := 5
@export var main_break_time := 20

enum STATES {
	IDLE,
	WORK,
	MINI_BREAK,
	MAIN_BREAK,
}

var hours := 0
var minutes := 0
var seconds := 0

var timer_step := 1
var time_in_minutes: int = 1
var time_in_seconds :int = 0
var time_in_seconds_left := time_in_seconds
var time_counting :int = 0

var state: STATES = STATES.WORK

var max_rounds := 4
var _round := 1
var cycle := 1

var autoplay := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_in_minutes = working_time
	time_in_seconds = time_in_minutes*60
	time_in_seconds_left = time_in_seconds
	time_visuals.update_visuals()
	progress_bar.max_value = time_in_seconds
	progress_bar.value = time_in_seconds

func _on_timeout() -> void:
	if time_in_seconds_left > 0:
		time_counting += 1
		time_in_seconds_left -= 1
		progress_bar.value -= 1
		start()
		time_visuals.update_visuals()
	else:
		if !autoplay:
			btn_start.show()
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

func setting_up_timer(force_start):
	time_in_seconds = time_in_minutes*60
	time_in_seconds_left = time_in_seconds
	progress_bar.max_value = time_in_seconds
	progress_bar.value = time_in_seconds
	time_visuals.update_visuals()
	
	if autoplay or force_start:
		start(timer_step)

func choose_next_time():
	match state:
		STATES.IDLE:
			state = STATES.WORK
		STATES.WORK:
			if _round < max_rounds:
				state = STATES.MINI_BREAK

					
				time_in_minutes = mini_break_time
				setting_up_timer(false)
				state_label.text = time_visuals.state_labels[1]
				_round += 1
			else:
				_round = 1
				cycle += 1
				state = STATES.MAIN_BREAK
				time_in_minutes = main_break_time
				state_label.text = time_visuals.state_labels[2]
				setting_up_timer(false)
		STATES.MINI_BREAK:
				state = STATES.WORK
				time_in_minutes = working_time
				state_label.text = time_visuals.state_labels[0]
				setting_up_timer(false)
				round_label.text = str(_round)+" / "+str(max_rounds)+" in cycle: "+str(cycle)
		STATES.MAIN_BREAK:
				state = STATES.WORK
				time_in_minutes = working_time
				state_label.text = time_visuals.state_labels[0]
				setting_up_timer(false)
				round_label.text = str(_round)+" / "+str(max_rounds)+" in cycle: "+str(cycle)
