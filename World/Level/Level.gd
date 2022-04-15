extends Node2D

export(bool) var generate_on_load = true # DEBUG

onready var cave = $Cave
onready var objects = $Objects

func _ready():
	# DEBUG
	if generate_on_load:
		generate_level()
	else:
		cave.update_walls()
	
# DEBUG KEYBINDS
func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("generate_level"):
			generate_level()
		elif event.is_action_pressed("initialize_cave"):
			cave.generate_cave(false)
			objects.spawn_player()
		elif event.is_action_pressed("step"):
			cave.simulate_rock_generation()

func generate_level():
	cave.generate_cave(true)
	objects.clear_objects()
	objects.spawn_stalagmites()
	objects.spawn_player_and_exit()

func on_player_exit_level():
	print("Player has exited the level!")
