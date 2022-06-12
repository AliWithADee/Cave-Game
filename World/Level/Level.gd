extends Node2D

export(bool) var generate_on_load = true # DEBUG

onready var ground_layer = $World/GroundLayer
onready var walls_layer = $World/WallsLayer
onready var rock_layer = $World/RockLayer
onready var objects = $Objects

onready var map = $CanvasLayer/Map

func _ready():
	randomize()
	# DEBUG
	if generate_on_load:
		generate_level()
	else:
		walls_layer.update_walls()
		map.update_map(rock_layer)

# DEBUG KEYBINDS
func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("generate_level"):
			generate_level()

func _process(delta):
	var player = get_node("Objects/Player")
	if player:
		var player_pos = ground_layer.world_to_map(player.position)
		map.set_player_pos(player_pos)

func generate_level():
	rock_layer.initialise_rock_layer()
	var finished = rock_layer.simulate_rock_generation()
	while not finished:
		finished = rock_layer.simulate_rock_generation()
	rock_layer.initialise_border()
	
	walls_layer.update_walls()
	
	objects.clear_objects()
	objects.spawn_stalagmites()
	objects.spawn_player_and_exit()
	
	ground_layer.initialise_ground_layer()
	ground_layer.initialise_pathfinding()
	
	map.update_map(rock_layer)

func on_player_exit_level():
	print("Player has exited the level!")
