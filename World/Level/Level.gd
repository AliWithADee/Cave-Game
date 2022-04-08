extends Node2D

const PLAYER = preload("res://Actors/Player/Player.tscn")

onready var cave = $Cave

func _ready():
	cave.generate_cave(true)
	spawn_player()
	
# DEBUG KEYBINDS
func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("generate_cave"):
			cave.generate_cave(true)
			spawn_player()
		elif event.is_action_pressed("initialize_cave"):
			cave.generate_cave(false)
			spawn_player()
		elif event.is_action_pressed("step"):
			cave.simulate_rock_generation()#
		elif event.is_action_pressed("clear_walls"):
			cave.clear_walls()
		elif event.is_action_pressed("update_walls"):
			cave.update_walls()

func spawn_player():
	if has_node("Player"):
		remove_child(get_node("Player"))
	
	while true:
		var x = randi() % Globals.MAP_SIZE
		var y = randi() % Globals.MAP_SIZE
		if cave.rock_layer.get_cell(x, y) == -1:
			var pos = cave.rock_layer.map_to_world(Vector2(x, y)) + Vector2(Globals.CELL_SIZE/2, Globals.CELL_SIZE/2)
			var player = PLAYER.instance()
			var camera: Camera2D = player.get_node("Camera")
			camera.limit_right = Globals.MAP_SIZE * Globals.CELL_SIZE - 2 # TODO: weird
			camera.limit_bottom = Globals.MAP_SIZE * Globals.CELL_SIZE
			player.position = pos
			add_child(player)
			break
