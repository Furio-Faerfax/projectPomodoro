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

@onready var timer: Timer = %Timer
@onready var time_label: Label = %time_label
@onready var state_label: Label = %state_label
@onready var round_label: Label = %round_label

@export var state_labels = ["WORK", "MINIBREAK", "MAINBREAK"]

func _ready() -> void:
	state_label.text = state_labels[0]
	round_label.text = str(timer._round)+" / "+str(timer.max_rounds)+" in cycle: "+str(timer.cycle)

func update_visuals():
	timer.seconds = timer.time_in_seconds_left % 60
	timer.minutes = int(timer.time_in_seconds_left/60.0)
	timer.hours = int((timer.time_in_seconds_left/60.0)/60.0)
	
	if timer.minutes > 60:
		timer.minutes -= timer.hours*60
		
	var second_str = str(timer.seconds) if timer.seconds > 9 else "0"+str(timer.seconds)
	var minute_str = "00" if timer.minutes == 60 else str(timer.minutes) if timer.minutes > 9 else "0"+str(timer.minutes)
	var hour_str = str(timer.hours) if timer.hours > 9 else "0"+str(timer.hours)
	time_label.text = hour_str+":"+minute_str+":"+second_str if timer.hours > 0 else minute_str+":"+second_str
