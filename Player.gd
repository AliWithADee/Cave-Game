extends KinematicBody2D

export var speed = 100

onready var sprite: AnimatedSprite = $Sprite

onready var facing = Vector2.DOWN
onready var velocity = Vector2.ZERO

func _unhandled_input(event):
	if event.is_action_pressed("melee"):
		melee_attack()
			
func _process(delta):
	velocity = Vector2.ZERO # Reset velocity to 0 before inputs
	
	# Alter velocity vector based on player input
	if Input.is_action_pressed("left"): velocity.x -= 1
	if Input.is_action_pressed("right"): velocity.x += 1
	if Input.is_action_pressed("up"): velocity.y -= 1
	if Input.is_action_pressed("down"): velocity.y += 1
	
	# Normalize and scale velocity with speed value
	velocity = velocity.normalized() * speed
	
	# Set facing vector to direction of movement, IF we are moving.
	# Otherwise remain the same facing as the previous frame.
	if velocity != Vector2.ZERO:
		facing = velocity.normalized()
	
	
	
	# TODO: Switch to using animation player rather than animated sprite
	
	
	if velocity.x > 0: sprite.play("walk_right")
	elif velocity.x < 0: sprite.play("walk_left_pick")
	elif velocity.y > 0: sprite.play("walk_down")
	elif velocity.y < 0: sprite.play("walk_up")
	else:
		# TODO: Idle animation (for each direction) here
		sprite.stop()
		sprite.frame = 0
		if facing.x > 0: sprite.animation = "walk_right"
		elif facing.x < 0: sprite.animation = "walk_left_pick"
		elif facing.y < 0: sprite.animation = "walk_up"
		else: sprite.animation = "walk_down"
	
	# Move the player using velocity vector, then set velocity to the result of us attempting to move.
	velocity = move_and_slide(velocity)
	
func melee_attack():
	if facing.x > 0:
		print("attack right")
	elif facing.x < 0:
		print("attack left")
	elif facing.y < 0:
		print("attack up")
	else:
		print("attack down")
	
