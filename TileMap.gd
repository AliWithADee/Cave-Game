extends TileMap

const MAP_SIZE = 200
const START_ALIVE_CHANCE = 40 # 40%
const MIN_ALIVE = 3
const MIN_BIRTH = 5
const STEPS = 15

const ALIVE = 0
const DEAD = 1
const BORDER = 0

var step = 0
var generating = false

func _ready():
	generate_cave(true)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("generate_cave") and (not generating):
			generate_cave(true)
		elif event.is_action_pressed("initialize_cave") and (not generating):
			generate_cave(false)
		elif event.is_action_pressed("step") and (not generating):
			simulate()

func clear_cave():
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			set_cell(x, y, -1)
			
func generate_cave(simulate: bool):
	print("Generating Cave...")
	randomize()
	step = 0
	generating = true
	clear_cave()
	initialize_cave()
	if simulate:
		for s in range(STEPS):
			simulate()
	clean_up_cave() # Adds a border around the map
	generating = false
	print("Cave generation complete!")

func initialize_cave():
	print("Initializing cave...")
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var tile = ALIVE if (randi() % 100) < START_ALIVE_CHANCE else DEAD # 0 - 99
			if x < 3 or x > MAP_SIZE-4 or y < 3 or y > MAP_SIZE-4:
				tile = ALIVE
			set_cell(x, y, tile)
	print("Initialization complete!")

func numNeighbours(cell_x, cell_y):
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
				if numNeighbours(x, y) < MIN_ALIVE:
					changed_cells.append({"x": x, "y": y, "value": DEAD})
			elif tile == DEAD:
				if numNeighbours(x, y) >= MIN_BIRTH:
					changed_cells.append({"x": x, "y": y, "value": ALIVE})
	
	for cell in changed_cells:
		set_cell(cell["x"], cell["y"], cell["value"])
	
	print("Step " + str(step) + " complete!")
	
func clean_up_cave():
	print("Cleaning up cave...")
	var border_width = MAP_SIZE * 2
	for x in range(-border_width+1, MAP_SIZE+border_width-1):
		for y in range(border_width):
			set_cell(x, -y, BORDER)
			set_cell(x, MAP_SIZE-1+y, BORDER)
	
	for y in range(-border_width+1, MAP_SIZE+border_width-1):
		for x in range(border_width):
			set_cell(-x, y, BORDER)
			set_cell(MAP_SIZE-1+x, y, BORDER)
	print("Finished cleaning up cave!")
