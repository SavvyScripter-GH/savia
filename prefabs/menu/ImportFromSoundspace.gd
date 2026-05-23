extends Button

var has_been_pressed: bool = false

func _pressed():
	Globals.confirm_prompt.open(
		"Do you want to import settings and maps from Sound Space Plus to your Profile?",
		"Import All Content",
		[
			{ text = "Cancel" },
			{ text = "OK" }
		]
	)
	Globals.confirm_prompt.s_alert.play()
	var response: int = yield(Globals.confirm_prompt, "option_selected")
	Globals.confirm_prompt.close()
	
	if response == 1:
		Globals.confirm_prompt.s_next.play()
		
		var ssp_path = OS.get_environment("APPDATA") + "\\SoundSpacePlus"
		var profile_dir_path = "user://profiles"
		var dir = Directory.new()
		var file = File.new()
		
		if !dir.dir_exists(profile_dir_path):
			dir.make_dir(profile_dir_path)
		
		if dir.dir_exists(ssp_path):
			if dir.open(ssp_path) == OK:
				dir.list_dir_begin(true, true)
				var file_name = dir.get_next()
				while file_name != "":
					if not dir.current_is_dir():
						var lower_name = file_name.to_lower()
						var dest_path = profile_dir_path + "/" + file_name
						
						if lower_name in ["colors.txt", "favorites.txt"]:
							copy_file(ssp_path + "\\" + file_name, dest_path)
						elif lower_name.ends_with(".json"):
							if not ("mapdb" in lower_name or "cache" in lower_name):
								copy_file(ssp_path + "\\" + file_name, dest_path)
					file_name = dir.get_next()
				dir.list_dir_end()
			
			import_folder_recursive(
				ssp_path + "\\maps",
				"user://maps",
				["sspm"]
			)

			import_folder_recursive(
				ssp_path + "\\bests",
				"user://bests",
				["json", "txt"]
			)

			import_folder_recursive(
				ssp_path + "\\meshes",
				"user://meshes",
				["mesh", "obj", "txt"]
			)

			# Color Sets
			import_folder_recursive(
				ssp_path + "\\colorsets",
				"user://colorsets",
				["json", "txt", "colorset"]
			)
		else:
			print("Sound Space Plus directory not found.")
		
		yield(Globals.confirm_prompt, "done_closing")
		get_viewport().get_node("Menu").black_fade_target = true
		yield(get_tree().create_timer(0.35), "timeout")
		Rhythia.is_init = true
		get_tree().change_scene("res://scenes/init.tscn")
	else:
		Globals.confirm_prompt.s_back.play()

func import_folder_recursive(source_path:String, dest_path:String, allowed_extensions:Array):
	var dir = Directory.new()
	
	if !dir.dir_exists(source_path):
		return
	
	var make_dir = Directory.new()
	if !make_dir.dir_exists(dest_path):
		make_dir.make_dir_recursive(dest_path)
	
	if dir.open(source_path) != OK:
		return
	
	dir.list_dir_begin(true, true)
	var name = dir.get_next()
	
	while name != "":
		var src = source_path + "\\" + name
		var dst = dest_path + "/" + name
		if dir.current_is_dir():
			var subdir = Directory.new()
			if !subdir.dir_exists(dst):
				subdir.make_dir_recursive(dst)
			import_folder_recursive(src, dst, allowed_extensions)
		else:
			var ext = name.get_extension().to_lower()
			if ext in allowed_extensions:
				print("Importing: ", src)
				dir.copy(src, dst)
		name = dir.get_next()
	dir.list_dir_end()

func copy_file(src:String, dst:String):
	var in_file = File.new()
	var out_file = File.new()
	
	if in_file.open(src, File.READ) != OK:
		print("Failed to open source: ", src)
		return
	
	var data = in_file.get_buffer(in_file.get_len())
	in_file.close()
	
	var dir = Directory.new()
	dir.make_dir_recursive(dst.get_base_dir())
	
	if out_file.open(dst, File.WRITE) != OK:
		print("Failed to open destination: ", dst)
		return
	
	out_file.store_buffer(data)
	out_file.close()
	
	print("Copied file: ", src, " -> ", dst)
