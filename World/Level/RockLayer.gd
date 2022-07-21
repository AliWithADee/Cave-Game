extends TileMap

const START_ALIVE_CHANCE = 40 # 40%
const MIN_ALIVE = 3 # tiles
const MIN_BIRTH = 5 # tiles

onready var ground_layer = get_parent().get_node("GroundLayer")
onready var walls_layer = get_parent().get_node("WallsLayer")
onready var objects = get_parent().get_node("Objects")
onready var minimap = get_parent().get_parent().get_node("HUD/Minimap")

const ROCK = 0

func initialise_rock_layer():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			var tile = ROCK if GameManager.percent_chance(START_ALIVE_CHANCE) else -1
			
			if x < 3 or x > Globals.CAVE_SIZE-4 or y < 3 or y > Globals.CAVE_SIZE-4: # Border of 3
				tile = ROCK
				
			set_cell(x, y, tile)
		
	update_bitmask_region(Vector2.ZERO, Vector2(Globals.CAVE_SIZE-1,Globals.CAVE_SIZE-1))
	
func num_rock_neighbours(tile_x, tile_y):
	var count = 0
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			if not (i == 0 and j == 0):
				var x = tile_x+i
				var y = tile_y+j
				if get_cell(x, y) == ROCK:
					count += 1
	return count
	
func simulate_rock_generation():
	var changed_tiles = []
	
	var tiles_changed = false
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			var tile = get_cell(x, y)
			if tile == ROCK:
				if num_rock_neighbours(x, y) < MIN_ALIVE:
					changed_tiles.append({"x": x, "y": y, "value": -1})
					tiles_changed = true # If tile changed, then simulation is not complete
			elif tile != ROCK:
				if num_rock_neighbours(x, y) >= MIN_BIRTH:
					changed_tiles.append({"x": x, "y": y, "value": ROCK})
					tiles_changed = true # If tile changed, then simulation is not complete
					
	for tile in changed_tiles:
		set_cell(tile["x"], tile["y"], tile["value"])
		
	update_bitmask_region(Vector2.ZERO, Vector2(Globals.CAVE_SIZE-1,Globals.CAVE_SIZE-1))
	
	return not tiles_changed

# This is a border outside the main border, to make it seem like the rest of the world is rock tiles.
func initialise_outside_border():
	for x in range(-1, Globals.CAVE_SIZE+1):
		set_cell(x, -1, ROCK)
		set_cell(x, Globals.CAVE_SIZE, ROCK)
	
	for y in range(-1, Globals.CAVE_SIZE+1):
		set_cell(-1, y, ROCK)
		set_cell(Globals.CAVE_SIZE, y, ROCK)
	
	update_bitmask_region(Vector2.ZERO, Vector2(Globals.CAVE_SIZE-1,Globals.CAVE_SIZE-1))
	
func on_player_mine(pos) -> bool:
	var tile_pos = world_to_map(pos)
	var x = tile_pos.x
	var y = tile_pos.y
	
	if get_cell(x, y) != ROCK: return false
	if x <= 0 or x >= Globals.CAVE_SIZE-1 or y <= 0 or y >= Globals.CAVE_SIZE-1: return false
		
	set_cell(x, y, -1)
	ground_layer.set_cell(x, y, ground_layer.NAVABLE)
	minimap.set_cell(x, y, minimap.GROUND)
	walls_layer.update_walls()
	objects.destroy_gemstone_if_present(tile_pos)
	update_bitmask_region(tile_pos-Vector2(1,1), tile_pos+Vector2(1,1))
	return true
