extends AudioStreamPlayer

const DEFAULT = preload("res://assets/default.ogg")

var soundNames := ["break_start", "main-break_over", "mini-break_over", "work_over", "work_start"]
var sound_type := ".ogg"
var sounds := {}


func _ready() -> void:
	get_sounds()

##Sets the sound if it exists, otherwise it will place the default sound
func set_sound(snd):
	if sounds.has(snd):
		stream = sounds[snd]
	else:
		stream = DEFAULT

func get_sounds():
	for sound in soundNames:
		var snd = load_sounds(sound)
		if snd != null:
			sounds[sound] = snd
		else:
			if sounds.has(sound):
				sounds.erase(sound)
	#print(sounds)

func load_sounds(fileName):
	var path = Settings.user_dir+Settings.sound_dir+fileName+sound_type
	var file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		var _sound = AudioStreamOggVorbis.load_from_file(path)
		return _sound
	else:
		return null

func load_sounds_mp3(fileName):
	var path = Settings.user_dir+Settings.sound_dir+fileName+sound_type
	var file = FileAccess.open(path, FileAccess.READ)
	var sound := AudioStreamMP3.new()
	#print(path," ",file," ", sound)
	if file != null:
		sound.data = file.get_buffer(file.get_length())
		return sound
	else:
		return null
