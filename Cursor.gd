extends Sprite

onready var animation: AnimationPlayer = $CursorAnimation

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	animation.play("Idle")

func _process(delta):
	position = get_parent().get_local_mouse_position()
