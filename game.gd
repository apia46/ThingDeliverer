extends Node3D

func _ready() -> void:
	$"scene".loadChunk(Vector2(0,0))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			$"camera".position -= Vector3(event.relative.x, 0, event.relative.y) * $"camera".position.y * 0.0024
	elif event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$"camera".position.y *= 0.8
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$"camera".position.y *= 1.25
