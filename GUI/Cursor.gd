extends Sprite

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$CursorAnimation.play("Idle")

func _process(delta):
	position = get_viewport().get_mouse_position()
