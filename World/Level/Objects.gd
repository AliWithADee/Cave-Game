extends Node2D

const STALAGMITE = preload("res://World/Objects/Stalagmite.tscn")
const LEVEL_EXIT = preload("res://World/Objects/LevelExit.tscn")
const PLAYER = preload("res://Actors/Player/Player.tscn")
const ROCK_HERMIT = preload("res://Actors/Enemies/RockHermit.tscn")
const GEMSTONE = preload("res://World/Objects/Gemstone.tscn")

onready var level = get_parent().get_parent()
onready var rock_layer = level.get_node("World/RockLayer")

const CLUSTER_CHANCE = 40
const HERMIT_CHANCE = 50
const GEMSTONE_CHANCE = 0.2
var occupied_tiles = [] # List of tile positions occupied by an object
var gemstones = [] # List of gemstone objects present in the world

func clear_objects():
	for child in get_children():
		remove_child(child)
	occupied_tiles = []
	gemstones = []

func tile_pos_to_world_pos(tile_pos: Vector2) -> Vector2:
	return rock_layer.map_to_world(tile_pos) + Vector2(Globals.CAVE_TILE_SIZE/2, Globals.CAVE_TILE_SIZE/2)

func get_random_tile_pos() -> Vector2:
	return Vector2(GameManager.rng.randi_range(1, Globals.CAVE_SIZE-1), GameManager.rng.randi_range(1, Globals.CAVE_SIZE-1))

func is_rock(tile_pos: Vector2):
	return rock_layer.get_cell(tile_pos.x, tile_pos.y) == rock_layer.ROCK

func is_unoccupied(tile_pos: Vector2):
	if is_rock(tile_pos): return false
	if tile_pos in occupied_tiles: return false
	return true

func get_random_unoccupied_tile_pos() -> Vector2:
	var tile_pos = get_random_tile_pos()
	while not is_unoccupied(tile_pos):
		tile_pos = get_random_tile_pos()
	return tile_pos

func spawn_stalagmite(tile_pos: Vector2):
	var stalagmite = STALAGMITE.instance()
	stalagmite.position = tile_pos_to_world_pos(tile_pos)
	occupied_tiles.append(tile_pos)
	add_child(stalagmite)

func spawn_rock_hermit(tile_pos: Vector2):
	var hermit = ROCK_HERMIT.instance()
	hermit.position = tile_pos_to_world_pos(tile_pos)
	occupied_tiles.append(tile_pos)
	add_child(hermit)

func spawn_stalagmite_cluster():
	var hermit = GameManager.percent_chance(HERMIT_CHANCE)
	
	var origin_pos = get_random_unoccupied_tile_pos()
	if hermit: spawn_rock_hermit(origin_pos)
	else: spawn_stalagmite(origin_pos)
	
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			if not (i == 0 and j == 0):
				var tile_pos = Vector2(origin_pos.x+i, origin_pos.y+j)
				if is_unoccupied(tile_pos) and GameManager.percent_chance(CLUSTER_CHANCE):
					if hermit: spawn_rock_hermit(tile_pos)
					else: spawn_stalagmite(tile_pos)

func spawn_stalagmites():
	for i in range(int(Globals.CAVE_SIZE/2)):
		spawn_stalagmite_cluster()

func is_valid_exit_pos(tile_pos: Vector2, player_pos: Vector2):
	var occupied = is_unoccupied(tile_pos)
	var occupied_left = is_unoccupied(tile_pos+Vector2.LEFT)
	var occupied_right = is_unoccupied(tile_pos+Vector2.RIGHT)
	
	var occupied_up = is_unoccupied(tile_pos+Vector2.UP)
	var occupied_up_left = is_unoccupied(tile_pos+Vector2.LEFT+Vector2.UP)
	var occupied_up_right = is_unoccupied(tile_pos+Vector2.RIGHT+Vector2.UP)
	
	if not (occupied and occupied_left and occupied_right and occupied_up and occupied_up_left and occupied_up_right):
		return false
	
	return player_pos.distance_to(tile_pos) >= Globals.CAVE_SIZE / 2

func player_exists() -> bool:
	return has_node(Globals.PLAYER_NODE)

func get_player():
	return get_node(Globals.PLAYER_NODE)

func spawn_player_and_exit():
	if player_exists():
		remove_child(get_player())
		
	var player = PLAYER.instance()
	var player_pos = get_random_unoccupied_tile_pos()
	player.position = tile_pos_to_world_pos(player_pos)
	occupied_tiles.append(player_pos)
	
	var camera: Camera2D = player.get_camera()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = Globals.CAVE_SIZE * Globals.CAVE_TILE_SIZE
	camera.limit_bottom = Globals.CAVE_SIZE * Globals.CAVE_TILE_SIZE
	
	add_child(player)
	
	var exit = LEVEL_EXIT.instance()
	var exit_pos = get_random_unoccupied_tile_pos()
	while not is_valid_exit_pos(exit_pos, player_pos):
		exit_pos = get_random_unoccupied_tile_pos()
	exit.position = tile_pos_to_world_pos(exit_pos)
	occupied_tiles.append(exit_pos)
	occupied_tiles.append(exit_pos+Vector2.LEFT)
	occupied_tiles.append(exit_pos+Vector2.RIGHT)
	
	exit.connect("player_entered", level, "on_player_exit_level")
	
	add_child(exit)

func spawn_gemstone(tile_pos: Vector2):
	var gemstone = GEMSTONE.instance()
	gemstone.position = tile_pos_to_world_pos(tile_pos)
	gemstones.append(gemstone)
	add_child(gemstone)

func spawn_gemstones():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			var tile_pos = Vector2(x, y)
			if is_rock(tile_pos) and GameManager.percent_chance(GEMSTONE_CHANCE):
				spawn_gemstone(tile_pos)
	
	print("There are " + str(gemstones.size()) + " gemstones")

func destroy_gemstone_if_present(tile_pos: Vector2):
	for gemstone in gemstones:
		if gemstone.position == tile_pos_to_world_pos(tile_pos):
			print("give gems")
			gemstones.erase(gemstone)
			gemstone.queue_free()
