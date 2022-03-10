extends Camera2D

onready var MAP: TileMap = get_parent().get_node("TileMap")
const ZOOM_FACTOR = Vector2(0.1,0.1)

var panning

func _ready():
	global_position = Vector2(MAP.cell_size * (MAP.MAP_SIZE/2))
	print(position)

func _process(delta):
	panning = Input.is_action_pressed("mouse_pan")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				zoom -= ZOOM_FACTOR * zoom
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoom += ZOOM_FACTOR * zoom
	if event is InputEventMouseMotion:
		if panning:
			global_position -= event.relative * zoom
