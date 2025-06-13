extends HBoxContainer
@onready var start: Button = %Start
@onready var pause: Button = %Pause
@onready var stop: Button = %Stop
@onready var skip: Button = %Skip
@onready var timer: Timer = %Timer
@onready var audio: AudioStreamPlayer = %audio
@onready var time_visuals: Control = %time_visuals
@onready var progress_bar: TextureProgressBar = %ProgressBar

var paused := false

func _on_start_pressed() -> void:
	start.hide()
	pause.show()
	if !paused:
		audio.stop()
		match timer.state:
			timer.STATES.WORK:
				audio.set_sound("work_start")
			timer.STATES.MINI_BREAK:
				audio.set_sound("break_start")
			timer.STATES.MAIN_BREAK:
				audio.set_sound("break_start")
			_:
				pass
		audio.play(0.0)
	
	if timer.is_stopped():
		if !paused:
			timer.setting_up_timer(true)
		else:
			timer.start()

#Curently resets the current round
func _on_stop_pressed() -> void:
	start.show()
	pause.hide()
	if paused:
		paused = false
	timer.stop()
	timer.time_in_seconds_left = timer.time_in_seconds
	time_visuals.update_visuals()
	progress_bar.value = progress_bar.max_value

func _on_pause_pressed() -> void:
	start.show()
	pause.hide()
	paused = true
	timer.stop()

func _on_skip_pressed() -> void:#Currently no sound when skipping
	_on_stop_pressed()
	if timer.autoplay:
		start.hide()
		pause.show()
	
	timer.choose_next_time()
