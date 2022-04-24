extends TileMap

onready var walls_layer = get_parent().get_node("WallsLayer")

const ROCK = 0
	
func initialise_rock_layer():
	for x in range(Globals.MAP_SIZE):
		for y in range(Globals.MAP_SIZE):
			
			var tile = ROCK if (randi() % 100) < Globals.START_ALIVE_CHANCE else -1
			
			if x < 3 or x > Globals.MAP_SIZE-4 or y < 3 or y > Globals.MAP_SIZE-4: # Border of 3
				tile = ROCK
				
			set_cell(x, y, tile)
		
	update_bitmask_region(Vector2.ZERO, Vector2(Globals.MAP_SIZE-1,Globals.MAP_SIZE-1))
	
func num_rock_neighbours(cell_x, cell_y):
	var count = 0
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			if not (i == 0 and j == 0):
				var x = cell_x+i
				var y = cell_y+j
				if get_cell(x, y) == ROCK:
					count += 1
	return count
	
func simulate_rock_generation():
	var changed_cells = []
	
	var cells_changed = false # Whether the simulation is finished or not
	for x in range(Globals.MAP_SIZE):
		for y in range(Globals.MAP_SIZE):
			var tile = get_cell(x, y)
			if tile == ROCK:
				if num_rock_neighbours(x, y) < Globals.MIN_ALIVE:
					changed_cells.append({"x": x, "y": y, "value": -1})
					cells_changed = true # If cell changed, then simulation is not complete
			elif tile != ROCK:
				if num_rock_neighbours(x, y) >= Globals.MIN_BIRTH:
					changed_cells.append({"x": x, "y": y, "value": ROCK})
					cells_changed = true # If cell changed, then simulation is not complete
					
	for cell in changed_cells:
		set_cell(cell["x"], cell["y"], cell["value"])
		
	update_bitmask_region(Vector2.ZERO, Vector2(Globals.MAP_SIZE-1,Globals.MAP_SIZE-1))
	
	return not cells_changed

func initialise_border():
	for x in range(-1, Globals.MAP_SIZE+1):
		set_cell(x, -1, ROCK)
		set_cell(x, Globals.MAP_SIZE, ROCK)
	
	for y in range(-1, Globals.MAP_SIZE+1):
		set_cell(-1, y, ROCK)
		set_cell(Globals.MAP_SIZE, y, ROCK)
	
	update_bitmask_region(Vector2.ZERO, Vector2(Globals.MAP_SIZE-1,Globals.MAP_SIZE-1))
	
func on_player_mine(pos) -> bool:
	var cell_pos = world_to_map(pos)
	var x = cell_pos.x
	var y = cell_pos.y
	
	if get_cell(x, y) != ROCK: return false
	if x <= 0 or x >= Globals.MAP_SIZE-1 or y <= 0 or y >= Globals.MAP_SIZE-1: return false
		
	set_cell(x, y, -1)
	walls_layer.update_walls()
	update_bitmask_region(cell_pos-Vector2(1,1), cell_pos+Vector2(1,1))
	return true
