extends Node

const APP_NAME = "projectPomodoro"
const VERSION: String = "v0.1.0"
const AUTHOR = "Furio Faerfax"
const user_dir: String = "user://"
const setting_file: String = "settings.txt"

var test = 0

var settings: Dictionary = {
	"first_start": true,
	"move_right": KEY_D,
	"move_left": KEY_A,
	"move_up": KEY_W,
	"move_down": KEY_S,
	"attack": KEY_SPACE,
	"dash": KEY_SHIFT,
	}


var key_map: Dictionary = {"f1": KEY_F1, "f2": KEY_F2}

var _file: file_handler = file_handler.new()


func _ready() -> void:
	_load_settings()
	
	if settings["first_start"] == true:

		change_setting("first_start", false)
		_load_settings()
	
	_load_key_map()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event.is_action_pressed("f1"):
		_open_user_directory()
		
				
	if event.is_action_pressed("move_down"):
		Global.pr("TEST: "+str(test))
		test+=1
	#Example of changing the keymapping
	if event.is_action_pressed("move_up"):
		change_or_add_key_binding("f1", KEY_Z, false)
	

func _open_user_directory():
	OS.shell_open(OS.get_user_data_dir())


func change_setting(setting, boo):
	## When a setting is changed, the dictionary gets updated
	match setting:
		"first_start":
			settings["first_start"] = boo
		_:
			pass
	_save_settings()

func _save_settings():
	var settings_str = ""
	for settings_count in settings.size():
		var key = settings.keys()[settings_count]
		var value = settings[key]
		settings_str += str(key)+"|"+str(value)+"\n"
	_file.save(str(user_dir)+str(setting_file), settings_str)

func _load_settings():
	var arr = _file.loading(str(user_dir)+str(setting_file), "|")
	for line in arr:
		match line[0]:
			"first_start":
				var boo = true if line[1] == "true" else false
				settings["first_start"] = boo
			"move_right":
				settings["move_right"] = line[1]
				key_map["move_right"] = line[1]
			"move_left":
				settings["move_left"] = line[1]
				key_map["move_left"] = line[1]
			"move_up":
				settings["move_up"] = line[1]
				key_map["move_up"] = line[1]
			"move_down":
				settings["move_down"] = line[1]
				key_map["move_down"] = line[1]
			"attack":
				settings["attack"] = line[1]
				key_map["attack"] = line[1]
			"dash":
				settings["dash"] = line[1]
				key_map["dash"] = line[1]
			_:
				pass

func change_or_add_key_binding(action: String, new_key: Key, add: bool):
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)
	else:
		InputMap.add_action(action)
		
	var ev = InputEventKey.new()
	ev.keycode = new_key
	InputMap.action_add_event(action, ev)
	
	if not add:
		settings[action] = new_key
		key_map[action] = new_key
		_save_settings()


func _load_key_map():
	for key in key_map.size():
		change_or_add_key_binding(key_map.keys()[key], key_map[key_map.keys()[key]] as Key, true)
