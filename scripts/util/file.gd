class_name file_handler

signal _file_deleted(path)

func save(path, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line(data)
	file.close()

func loading(path, split_by):
	var file = FileAccess.open(path, FileAccess.READ)
	var data_content : Array
	if file: 
		var data = file.get_as_text()
		file.close()
		var data_arr: Array = data.split("\n")
		
		if data_arr[0] == "":
			data_arr.pop_front()
		if data_arr[data_arr.size()-1] == "":
			data_arr.pop_back()
		
		if split_by != "":
			for line in data_arr:
				data_content.push_back(line.split(split_by))
		else:
			data_content = data_arr
	else:
		_file_deleted.emit()
	return data_content
