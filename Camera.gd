"""
DEBUG script for changing camera zoom
"""

extends Camera2D

const ZOOM_FACTOR = Vector2(0.1,0.1)

func _ready():
	if GameManager.camera_zoom:
		zoom = GameManager.camera_zoom

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		zoom -= ZOOM_FACTOR * zoom
		GameManager.camera_zoom = zoom
		print(zoom)
	elif event.is_action_pressed("zoom_out"):
		zoom += ZOOM_FACTOR * zoom
		GameManager.camera_zoom = zoom
		print(zoom)
