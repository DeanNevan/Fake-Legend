extends Camera2D

func _process(delta):
	Camera2D.global_position = get_global_mouse_position()
