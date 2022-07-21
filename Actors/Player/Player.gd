extends KinematicBody2D

enum Equipables { PICKAXE, REVOLVER, DYNAMITE }

# Constants
const MOVE_SPEED = 5000
const PICKAXE_TEXTURE = preload("res://Assets/Miner/Pickaxe.png")
const REVOLVER_TEXTURE = preload("res://Assets/Miner/Revolver.png")
const DYNAMITE_TEXTURE = preload("res://Assets/Miner/Dynamite.png")
const MAX_ENEMIES_MELEE = 4 # Damage up to 4 enemies in one swing
const MAX_OBJECTS_MINE = 1 # By default, only mine 1 object at a time

# Node References
onready var body_sprite: Sprite = $BodySprite
onready var item_sprite: Sprite = $ItemSprite
onready var player_anim: AnimationPlayer = $PlayerAnimation
onready var melee_box: Area2D = $MeleeHurtBox
onready var mine_box: Area2D = $MineHurtBox

# Runtime variables
var facing = Vector2.DOWN # Facing should never be 0 so set to DOWN by default
var velocity = Vector2.ZERO
var equipped = Equipables.PICKAXE
var attacking = false

func _ready():
	update_item()

func _unhandled_input(event):
	if event.is_action_pressed("use_tool"):
		use_tool()
	elif event.is_action_pressed("pickaxe"):
		equip(Equipables.PICKAXE)
	elif event.is_action_pressed("revolver"):
		equip(Equipables.REVOLVER)
	elif event.is_action_pressed("dynamite"):
		equip(Equipables.DYNAMITE)

func get_camera():
	return get_node("Camera")

func determine_velocity(delta):
	velocity = Vector2.ZERO # Reset velocity to 0 before inputs
	
	# Alter velocity vector based on player input
	if Input.is_action_pressed("left"): velocity.x -= 1
	if Input.is_action_pressed("right"): velocity.x += 1
	if Input.is_action_pressed("up"): velocity.y -= 1
	if Input.is_action_pressed("down"): velocity.y += 1
	
	# Normalize vector
	velocity = velocity.normalized() * MOVE_SPEED * delta

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

func _physics_process(delta):
	determine_velocity(delta)
	
	# Move the player using velocity vector, then set velocity to the result of us attempting to move.
	velocity = move_and_slide(velocity)

func _process(delta):
	var facing_before = facing
	determine_facing()
	
	# This handles the rendering order of the body and item sprites
	if facing != facing_before:
		match facing:
			Vector2.UP: move_child(body_sprite, 1)
			_: move_child(body_sprite, 0)
	
	if not attacking:
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

func equip(new_tool: int):
	equipped = new_tool
	update_item()

func update_item():
	match equipped:
		Equipables.REVOLVER: item_sprite.texture = REVOLVER_TEXTURE
		Equipables.DYNAMITE: item_sprite.texture = DYNAMITE_TEXTURE
		Equipables.PICKAXE: item_sprite.texture = PICKAXE_TEXTURE
		_: item_sprite.texture = null

func use_tool():
	if not attacking and equipped == Equipables.PICKAXE:
		attacking = true
		
		if facing.x > 0: player_anim.play("MeleeRight")
		elif facing.x < 0: player_anim.play("MeleeLeft")
		elif facing.y < 0: player_anim.play("MeleeUp")
		else: player_anim.play("MeleeDown")
		
		damage_enemies()
		mine_objects()
		
		yield(player_anim, "animation_finished")
		attacking = false
	
func damage_enemies():
	var areas = melee_box.get_overlapping_areas()
	for a in range(min(MAX_ENEMIES_MELEE, areas.size())):
		var hit_box: Area2D = areas[a]
		var enemy = hit_box.get_parent()
		
		if enemy.has_method("take_damage"):
			enemy.take_damage(1)

func mine_objects():
	var bodies = mine_box.get_overlapping_bodies()
	for b in range(bodies.size()):
		var node = bodies[b]
		if node.has_method("on_player_mine"):
			node.on_player_mine(mine_box.get_node("CollisionShape").global_position)
	
	var areas = mine_box.get_overlapping_areas()
	for a in range(areas.size()):
		var area = areas[a]
		var node = area.get_parent()
		
		if node.has_method("on_player_mine"):
			node.on_player_mine(mine_box.get_node("CollisionShape").global_position)
	
func take_damage(damage: int):
	body_sprite.modulate = Color.red
	yield(Utils.create_timer(0.1), "timeout")
	body_sprite.modulate = Color.white
