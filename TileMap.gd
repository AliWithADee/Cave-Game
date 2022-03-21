extends TileMap

const MAP_SIZE = 100
const CELL_SIZE = 32
const START_ALIVE_CHANCE = 40 # 40%
const MIN_ALIVE = 3
const MIN_BIRTH = 5
const STEPS = 15

const ALIVE = 3 # Solid tile
const DEAD = 0 # Walkable tiles
const WALL = 2 # Transition from walkable tile to solid tile

var step = 0

func generate_cave(simulate: bool):
	print("Generating Cave...")
	randomize()
	step = 0
	
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			set_cell(x, y, -1)
			
	initialize_cave()
	if simulate:
		for s in range(STEPS):
			simulate()
			
	print("Cave generation complete!")

func initialize_cave():
	print("Initializing cave...")
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var tile = ALIVE if (randi() % 100) < START_ALIVE_CHANCE else DEAD
			if x < 3 or x > MAP_SIZE-4 or y < 3 or y > MAP_SIZE-4: # Border of 3
				tile = ALIVE
			set_cell(x, y, tile)
	
	set_walls()
	update_bitmask_region(Vector2(0,0), Vector2(MAP_SIZE-1,MAP_SIZE-1))
	print("Initialization complete!")

func num_neighbours(cell_x, cell_y):
	var count = 0
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			if not (i == 0 and j == 0):
				var x = cell_x+i
				var y = cell_y+j
				if get_cell(x, y) == ALIVE:
					count += 1
	return count
	
func simulate():
	step += 1
	print("Simulating step " + str(step) + "...")
	
	var changed_cells = []
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var tile = get_cell(x, y)
			if tile == ALIVE:
				if num_neighbours(x, y) < MIN_ALIVE:
					changed_cells.append({"x": x, "y": y, "value": DEAD})
			elif tile != ALIVE:
				if num_neighbours(x, y) >= MIN_BIRTH:
					changed_cells.append({"x": x, "y": y, "value": ALIVE})
					
	for cell in changed_cells:
		set_cell(cell["x"], cell["y"], cell["value"])
	
	set_walls()
	update_bitmask_region(Vector2(0,0), Vector2(MAP_SIZE-1,MAP_SIZE-1))
	print("Step " + str(step) + " complete!")

func set_walls():
	print("Generating walls...")
	
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			if get_cell(x, y) == WALL:
				set_cell(x, y, DEAD)
			
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			if get_cell(x, y) != ALIVE and get_cell(x, y-1) == ALIVE:
				set_cell(x, y, WALL)
	print("Generated walls!")
