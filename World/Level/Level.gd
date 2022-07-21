extends Node2D

export(bool) var generate_on_load = true # DEBUG

onready var ground_layer = $World/GroundLayer
onready var walls_layer = $World/WallsLayer
onready var rock_layer = $World/RockLayer
onready var objects = $World/Objects

onready var loading = $HUD/Loading
onready var minimap = $HUD/Minimap

func _ready():
	loading.visible = true
	# DEBUG
	if generate_on_load:
		generate_level()
	else:
		GameManager.rng.randomize()
		
		walls_layer.update_walls()
		ground_layer.update_ground_layer(rock_layer)
		minimap.update_minimap(rock_layer)
		
		GameManager.levels_since_magpie += 1

		var anim = loading.get_node("AnimationPlayer")
		anim.play("Fade_Out")
		yield(anim, "animation_finished")
		

# DEBUG KEYBINDS
func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("exit_level"):
			on_player_exit_level()

func _process(delta):
	if objects.player_exists():
		var player_pos = ground_layer.world_to_map(objects.get_player().position)
		minimap.set_player_pos(player_pos)

func generate_level():
	GameManager.rng.randomize()
	print("The level seed is " + str(GameManager.rng.get_seed()))
	
	rock_layer.initialise_rock_layer()
	var finished = rock_layer.simulate_rock_generation()
	while not finished:
		finished = rock_layer.simulate_rock_generation()
	rock_layer.initialise_outside_border()
	
	walls_layer.update_walls()
	
	objects.clear_objects()
	objects.spawn_stalagmites()
	objects.spawn_gemstones()
	objects.spawn_player_and_exit()
	
	ground_layer.update_ground_layer(rock_layer)
	
	minimap.update_minimap(rock_layer)
	
	GameManager.levels_since_magpie += 1
	
	var anim = loading.get_node("AnimationPlayer")
	anim.play("Fade_Out")
	yield(anim, "animation_finished")

func on_player_exit_level():
	var anim = loading.get_node("AnimationPlayer")
	anim.play("Fade_In")
	yield(anim, "animation_finished")
	if GameManager.load_magpie():
		get_tree().change_scene("res://World/Magpie/MagpieLevel.tscn")
	else:
		generate_level()
