extends KinematicBody2D

# Constants
export(int) var move_speed = 100
enum Equipables { PICKAXE, REVOLVER, DYNAMITE }
const pickaxe_texture = preload("res://Assets/Miner/Pickaxe.png")
const revolver_texture = preload("res://Assets/Miner/Revolver.png")
const dynamite_texture = preload("res://Assets/Miner/Dynamite.png")

# Node References
onready var item_sprite: Sprite = $ItemSprite
onready var player_anim: AnimationPlayer = $PlayerAnimation
onready var melee_box: Area2D = $MeleeHurtBox
onready var mine_box: Area2D = $MineHurtBox

# Runtime variables
export(Equipables) var equiped = Equipables.PICKAXE
onready var facing = Vector2.DOWN # Facing should never be 0 so set to DOWN by default
onready var velocity = Vector2.ZERO
var attacking = false

func _ready():
	update_item()

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		attack()
	elif event.is_action_pressed("pickaxe"):
		equip(Equipables.PICKAXE)
	elif event.is_action_pressed("revolver"):
		equip(Equipables.REVOLVER)
	elif event.is_action_pressed("dynamite"):
		equip(Equipables.DYNAMITE)

func determine_velocity():
	if not attacking: velocity = Vector2.ZERO # Reset velocity to 0 before inputs
	
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
	var facing_before = facing
	determine_facing()
	
	# This handles the rendering order of the body and item sprites
	if facing != facing_before:
		match facing:
			Vector2.UP: move_child(get_node("BodySprite"), 1)
			_: move_child(get_node("BodySprite"), 0)
	
	if not attacking:
		determine_velocity()
		if velocity != Vector2.ZERO:
			if facing.x > 0: player_anim.play("WalkRight")
			elif facing.x < 0: player_anim.play("WalkLeft")
			elif facing.y < 0: player_anim.play("WalkUp")
			else: player_anim.play("WalkDown")
		else:
			if facing.x > 0: player_anim.play("IdleRight")
			elif facing.x < 0: player_anim.play("IdleLeft")
			elif facing.y < 0: player_anim.play("IdleUp")
			else: player_anim.play("IdleDown")
	
	# Rotate hurt boxes to face the mouse
	var mouse_pos = get_global_mouse_position()
	melee_box.look_at(mouse_pos)
	mine_box.look_at(mouse_pos)
	
	# Move the player using velocity vector, then set velocity to the result of us attempting to move.
	velocity = move_and_slide(velocity)

func equip(new_id: int):
	equiped = new_id
	update_item()

func update_item():
	match equiped:
		Equipables.REVOLVER: item_sprite.texture = revolver_texture
		Equipables.DYNAMITE: item_sprite.texture = dynamite_texture
		Equipables.PICKAXE: item_sprite.texture = pickaxe_texture
		_: item_sprite.texture = null

func attack():
	if not attacking and equiped == Equipables.PICKAXE:
		attacking = true
		
		if facing.x > 0: player_anim.play("MeleeRight")
		elif facing.x < 0: player_anim.play("MeleeLeft")
		elif facing.y < 0: player_anim.play("MeleeUp")
		else: player_anim.play("MeleeDown")
		
		damage_enemies()
		mine_objects()
		
		yield(player_anim, "animation_finished")
		attacking = false
	
const MAX_ENEMIES_TO_DAMAGE_MELEE = 4 # Damage up to 4 enemies in one swing
const MAX_OBJECTS_TO_MINE = 1 # By default, only mine 1 object at a time
	
func damage_enemies():
	var areas = melee_box.get_overlapping_areas()
	for a in range(min(MAX_ENEMIES_TO_DAMAGE_MELEE, areas.size())):
		var hit_box: Area2D = areas[a]
		var enemy = hit_box.get_parent()
		
		print(enemy.name)
		if enemy.has_method("on_player_hit"):
			enemy.on_player_hit()

func mine_objects():
	var bodies = mine_box.get_overlapping_bodies()
	for b in range(min(MAX_OBJECTS_TO_MINE, bodies.size())):
		var other = bodies[b]
		
		if other.has_method("on_player_mine"):
			other.on_player_mine(mine_box.get_node("CollisionShape").global_position)
