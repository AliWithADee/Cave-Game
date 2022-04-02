extends KinematicBody2D

# Constants
export var move_speed = 100
enum Equipables { PICKAXE, REVOLVER, DYNAMITE }
onready var pickaxe_texture = preload("res://Assets/Miner/Pickaxe.png")
onready var revolver_texture = preload("res://Assets/Miner/Revolver.png")
onready var dynamite_texture = preload("res://Assets/Miner/Dynamite.png")

# Node References
onready var item_sprite: Sprite = $ItemSprite
onready var player_anim: AnimationPlayer = $PlayerAnimation
onready var item_anim: AnimationPlayer = $ItemAnimation
onready var melee_box: Area2D = $MeleeHurtBox
onready var mine_box: Area2D = $MineHurtBox
onready var cursor: Sprite = $Cursor

# Runtime variables
onready var facing = Vector2.DOWN # Facing should never be 0 so set to DOWN by default
onready var velocity = Vector2.ZERO
export(Equipables) var equiped = Equipables.PICKAXE

func _ready():
	item_anim.connect("animation_finished", self, "on_item_animation_finished")
	melee_box.connect("body_entered", self, "body_enter_melee")
	mine_box.connect("body_exit", self, "body_exit_mine_box")
	update_item()

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		attack()
	elif event.is_action_pressed("pickaxe"):
		equiped = Equipables.PICKAXE
		update_item()
	elif event.is_action_pressed("revolver"):
		equiped = Equipables.REVOLVER
		update_item()
	elif event.is_action_pressed("dynamite"):
		equiped = Equipables.DYNAMITE
		update_item()
	elif event.is_action_pressed("show_collisions"): # DEBUG
		get_tree().set_debug_collisions_hint(!get_tree().is_debugging_collisions_hint())

func determine_velocity():
	velocity = Vector2.ZERO # Reset velocity to 0 before inputs
	
	# Alter velocity vector based on player input
	if Input.is_action_pressed("left"): velocity.x -= 1
	if Input.is_action_pressed("right"): velocity.x += 1
	if Input.is_action_pressed("up"): velocity.y -= 1
	if Input.is_action_pressed("down"): velocity.y += 1
	
	# Normalize and scale velocity with speed value
	velocity = velocity.normalized() * move_speed

func determine_facing():
	var mouse_pos = get_local_mouse_position()
	
	if -abs(mouse_pos.y) > mouse_pos.x: # Left
		facing = Vector2.LEFT
	elif abs(mouse_pos.y) < mouse_pos.x: # Right
		facing = Vector2.RIGHT
	elif -abs(mouse_pos.x) > mouse_pos.y: # Up
		facing = Vector2.UP
	else: # Down
		facing = Vector2.DOWN
	
func _process(delta):
	# Update vectors
	determine_velocity()
	determine_facing()
	
	if velocity != Vector2.ZERO:
		if facing.x > 0: player_anim.play("Walk_Right")
		elif facing.x < 0: player_anim.play("Walk_Left")
		elif facing.y < 0: player_anim.play("Walk_Up")
		else: player_anim.play("Walk_Down")
	else:
		if facing.x > 0: player_anim.play("Idle_Right")
		elif facing.x < 0: player_anim.play("Idle_Left")
		elif facing.y < 0: player_anim.play("Idle_Up")
		else: player_anim.play("Idle_Down")
	
	# Rotate hurt boxes to face the mouse
	var mouse_pos = get_global_mouse_position()
	melee_box.look_at(mouse_pos)
	mine_box.look_at(mouse_pos)
	
	# Move the player using velocity vector, then set velocity to the result of us attempting to move.
	velocity = move_and_slide(velocity)

func update_item():
	match equiped:
		Equipables.REVOLVER: item_sprite.texture = revolver_texture
		Equipables.DYNAMITE: item_sprite.texture = dynamite_texture
		_: item_sprite.texture = pickaxe_texture

func attack():
	if equiped == Equipables.PICKAXE:
		if facing.x > 0: item_anim.play("Melee_Right")
		elif facing.x < 0: item_anim.play("Melee_Left")
		elif facing.y < 0: item_anim.play("Melee_Up")
		else: item_anim.play("Melee_Down")
		
		damage_enemies()
		damage_tiles()

func damage_enemies():
	pass

func damage_tiles():
	for other in mine_box.get_overlapping_bodies():
		if other.has_method("on_player_mine"):
			other.on_player_mine(mine_box.get_node("CollisionShape").global_position)
