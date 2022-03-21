extends Node2D

const PLAYER = preload("res://Player.tscn")

onready var tilemap = $TileMap

func _ready():
	tilemap.generate_cave(true)
	spawn_player()
	
# DEBUG KEYBINDS
func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("generate_cave"):
			tilemap.generate_cave(true)
			spawn_player()
		elif event.is_action_pressed("initialize_cave"):
			tilemap.generate_cave(false)
			spawn_player()
		elif event.is_action_pressed("step"):
			tilemap.simulate()

func spawn_player():
	print("Spawning player...")
	
	var existing = get_node("Player")
	if existing:
		remove_child(existing)
	
	while true:
		var x = randi() % tilemap.MAP_SIZE
		var y = randi() % tilemap.MAP_SIZE
		if tilemap.get_cell(x, y) == tilemap.DEAD:
			var pos = tilemap.map_to_world(Vector2(x, y)) + Vector2(tilemap.CELL_SIZE/2, tilemap.CELL_SIZE/2)
			var player = PLAYER.instance()
			var camera: Camera2D = player.get_node("Camera")
			camera.limit_right = tilemap.MAP_SIZE * tilemap.CELL_SIZE - 2 # TODO: weird
			camera.limit_bottom = tilemap.MAP_SIZE * tilemap.CELL_SIZE
			player.position = pos
			add_child(player)
			return
	print("Player spawned!")
