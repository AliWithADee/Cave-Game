extends Node2D

const STALAGMITE = preload("res://World/Objects/Stalagmite.tscn")
const LEVEL_EXIT = preload("res://World/Objects/LevelExit.tscn")
const PLAYER = preload("res://Actors/Player/Player.tscn")

onready var level = get_parent()
onready var cave = level.get_node("Cave")

const CLUSTER_CHANCE = 40
var occupied = [] # List of tile positions currently occupied by an object

func clear_objects():
	for child in get_children():
		remove_child(child)

func tile_pos_to_world_pos(pos: Vector2) -> Vector2:
	return cave.rock_layer.map_to_world(pos) + Vector2(Globals.CELL_SIZE/2, Globals.CELL_SIZE/2)

func is_valid_position(pos: Vector2):
	if cave.rock_layer.get_cell(pos.x, pos.y) != -1: return false
	if pos in occupied: return false
	return true

func get_random_pos() -> Vector2:
	randomize()
	var pos = Vector2(randi() % Globals.MAP_SIZE, randi() % Globals.MAP_SIZE)
	while not is_valid_position(pos):
		pos = Vector2(randi() % Globals.MAP_SIZE, randi() % Globals.MAP_SIZE)
	return pos

func spawn_stalagmite(pos: Vector2):
	var stalagmite = STALAGMITE.instance()
	stalagmite.position = tile_pos_to_world_pos(pos)
	occupied.append(pos)
	add_child(stalagmite)

func spawn_stalagmite_cluster():
	var pos1 = get_random_pos()
	spawn_stalagmite(pos1)
	
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			if not (i == 0 and j == 0):
				var pos2 = Vector2(pos1.x+i, pos1.y+j)
				if is_valid_position(pos2) and (randi() % 100) < CLUSTER_CHANCE:
					spawn_stalagmite(pos2)

func spawn_stalagmites():
	for i in range(int(Globals.MAP_SIZE/2)):
		spawn_stalagmite_cluster()

func is_valid_level_exit_pos(exit_pos: Vector2, player_pos: Vector2):
	var valid = is_valid_position(exit_pos)
	var valid_left = is_valid_position(exit_pos+Vector2.LEFT)
	var valid_right = is_valid_position(exit_pos+Vector2.RIGHT)
	if not (valid and valid_left and valid_right): return false
	
	print(player_pos.distance_to(exit_pos))
	return player_pos.distance_to(exit_pos) >= Globals.MAP_SIZE*0.5

func spawn_player_and_exit():
	if has_node("Player"):
		remove_child(get_node("Player"))
		
	var player = PLAYER.instance()
	var player_pos = get_random_pos()
	player.position = tile_pos_to_world_pos(player_pos)
	occupied.append(player_pos)
	
	var camera: Camera2D = player.get_node("Camera")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = Globals.MAP_SIZE * Globals.CELL_SIZE
	camera.limit_bottom = Globals.MAP_SIZE * Globals.CELL_SIZE
	
	add_child(player)
	
	# Tiles either side of it must be unoccupied
	
	var exit = LEVEL_EXIT.instance()
	var exit_pos = get_random_pos()
	while not is_valid_level_exit_pos(exit_pos, player_pos):
		exit_pos = get_random_pos()
	exit.position = tile_pos_to_world_pos(exit_pos)
	occupied.append(exit_pos)
	occupied.append(exit_pos+Vector2.LEFT)
	occupied.append(exit_pos+Vector2.RIGHT)
	
	exit.connect("player_entered", level, "on_player_exit_level")
	
	add_child(exit)
