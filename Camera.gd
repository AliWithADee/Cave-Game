extends Camera2D

onready var player: KinematicBody2D = get_parent()
const ZOOM_FACTOR = Vector2(0.1,0.1)

func _process(delta):
	var player_pos = player.position

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		zoom -= ZOOM_FACTOR * zoom
		print(zoom)
	elif event.is_action_pressed("zoom_out"):
		zoom += ZOOM_FACTOR * zoom
		print(zoom)
