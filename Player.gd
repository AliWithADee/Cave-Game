extends KinematicBody2D

export var speed = 100

onready var anim: AnimationPlayer = $AnimationPlayer
onready var hurt_boxes = $HurtBoxes

onready var facing = Vector2.DOWN
onready var velocity = Vector2.ZERO

var attacking = false

func _ready():
	anim.connect("animation_finished", self, "on_animation_finished")

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
	
	if not attacking:
		if velocity.x > 0: anim.play("Walk_Right")
		elif velocity.x < 0: anim.play("Walk_Left")
		elif velocity.y > 0: anim.play("Walk_Down")
		elif velocity.y < 0: anim.play("Walk_Up")
		else:
			if facing.x > 0: anim.play("Idle_Right")
			elif facing.x < 0: anim.play("Idle_Left")
			elif facing.y < 0: anim.play("Idle_Up")
			else: anim.play("Idle_Down")
	
	# Move the player using velocity vector, then set velocity to the result of us attempting to move.
	velocity = move_and_slide(velocity)
	
func melee_attack():
	if facing.x > 0:
		anim.play("Melee_Right")
		hurt_boxes.enable_hurt_box("MeleeRight")
		hurt_boxes.enable_hurt_box("MineRight")
	elif facing.x < 0:
		anim.play("Melee_Left")
		hurt_boxes.enable_hurt_box("MeleeLeft")
		hurt_boxes.enable_hurt_box("MineLeft")
	elif facing.y < 0:
		anim.play("Melee_Up")
		hurt_boxes.enable_hurt_box("MeleeUp")
		hurt_boxes.enable_hurt_box("MineUp")
	else:
		anim.play("Melee_Down")
		hurt_boxes.enable_hurt_box("MeleeDown")
		hurt_boxes.enable_hurt_box("MineDown")
	attacking = true

func on_animation_finished(animation):
	if "Melee" in animation or "Revolver" in animation or "Dynamite" in animation:
		$HurtBoxes.disable_hurt_boxes()
		attacking = false
