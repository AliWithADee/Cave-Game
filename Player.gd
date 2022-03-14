extends KinematicBody2D

export var speed = 50

onready var melee_area = $MeleeArea
onready var velocity = Vector2.ZERO

func get_movement_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_just_pressed("melee"):
		melee_attack()
	
	velocity = velocity.normalized() * speed

func _process(delta):
	get_movement_input()
	velocity = move_and_slide(velocity)
	
	var mouse_pos = get_global_mouse_position()
	melee_area.look_at(mouse_pos)

# Damage all enemies inside the melee attack area
func melee_attack():
	print("Enemies:")
	for enemy_area in melee_area.get_overlapping_areas():
		var enemy = enemy_area.get_parent()
		print(enemy.name + ": " + str(enemy))
	
