extends Camera3D

func set_active():
	GameManager.hide_interact_text()
	CameraManagerObject.set_camera_override(self, true)

func reset_camera():
	CameraManagerObject.reset_camera()
