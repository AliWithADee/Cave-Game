extends Node2D

# Node references
onready var ground_layer = $Ground
onready var walls_layer = $Walls
onready var rock_layer = $Rock

# Tile IDs
const GROUND = 0
const ROCK = 0
const WALL_TOP = {
	"single": 0,
	"left": 1,
	"middle": 2,
	"right": 3,
}
const WALL_BOTTOM = {
	"single": 4,
	"left": 5,
	"middle": 6,
	"right": 7,
}
const WALL_CORNER_LEFT = 8
const WALL_CORNER_MIDDLE = 9
const WALL_CORNER_RIGHT = 10
const WALL_CORNER_LEFT_EDGE = 11
const WALL_CORNER_RIGHT_EDGE = 12

func generate_cave(simulate: bool):
	randomize()
	initialize_cave()
	if simulate:
		var finished = simulate_rock_generation()
		while not finished:
			finished = simulate_rock_generation()

func initialize_cave():
	for x in range(Globals.MAP_SIZE):
		for y in range(Globals.MAP_SIZE):
			ground_layer.set_cell(x, y, GROUND)
			walls_layer.set_cell(x, y, -1)
			
			var tile = ROCK if (randi() % 100) < Globals.START_ALIVE_CHANCE else -1
			if x < 3 or x > Globals.MAP_SIZE-4 or y < 3 or y > Globals.MAP_SIZE-4: # Border of 3
				tile = ROCK
				
			rock_layer.set_cell(x, y, tile)
	
	update_walls()
	rock_layer.update_bitmask_region(Vector2.ZERO, Vector2(Globals.MAP_SIZE-1,Globals.MAP_SIZE-1))
	
func num_rock_neighbours(cell_x, cell_y):
	var count = 0
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			if not (i == 0 and j == 0):
				var x = cell_x+i
				var y = cell_y+j
				if rock_layer.get_cell(x, y) == ROCK:
					count += 1
	return count
	
func simulate_rock_generation():
	var changed_cells = []
	
	var cells_changed = false # Whether the simulation is finished or not
	for x in range(Globals.MAP_SIZE):
		for y in range(Globals.MAP_SIZE):
			var tile = rock_layer.get_cell(x, y)
			if tile == ROCK:
				if num_rock_neighbours(x, y) < Globals.MIN_ALIVE:
					changed_cells.append({"x": x, "y": y, "value": -1})
					cells_changed = true # If cell changed, then simulation is not complete
			elif tile != ROCK:
				if num_rock_neighbours(x, y) >= Globals.MIN_BIRTH:
					changed_cells.append({"x": x, "y": y, "value": ROCK})
					cells_changed = true # If cell changed, then simulation is not complete
					
	for cell in changed_cells:
		rock_layer.set_cell(cell["x"], cell["y"], cell["value"])
		
	update_walls()
	rock_layer.update_bitmask_region(Vector2.ZERO, Vector2(Globals.MAP_SIZE-1,Globals.MAP_SIZE-1))
	
	return not cells_changed

func place_wall_if_empty(x, y, cell):
	if walls_layer.get_cell(x, y) != -1: return false
	walls_layer.set_cell(x, y, cell)
	return true

# Function used to place a bottom half wall.
# If the wall should instead be a corner, then it is set to the correct corner piece
func place_wall_or_corner(x, y, wall_varient):
	var down = rock_layer.get_cell(x, y+1) == ROCK
	var down_left = rock_layer.get_cell(x-1, y+1) == ROCK
	var down_right = rock_layer.get_cell(x+1, y+1) == ROCK
	
	# If there is rock_layer beneath this tile
	# AND there is rock_layer down and to the left OR down and to the right of this tile,
	# then place the original bottom and top walls_layer varients
	if down and (down_left or down_right):
		walls_layer.set_cell(x, y, WALL_BOTTOM[wall_varient])
		place_wall_if_empty(x, y-1, WALL_TOP[wall_varient])
		return true
		
	var left = rock_layer.get_cell(x-1, y) == ROCK
	var right = rock_layer.get_cell(x+1, y) == ROCK
	
	# If both neighbours are empty
	if not (left or right):
		# Check tiles above neighbours
		var left_top = rock_layer.get_cell(x-1, y-1) == ROCK
		var right_top = rock_layer.get_cell(x+1, y-1) == ROCK
		
		# If both tiles above neighbours are rock_layer,
		# Set to middle corner, etc
		if left_top and right_top:
			walls_layer.set_cell(x, y, WALL_CORNER_MIDDLE)
			place_wall_if_empty(x, y-1, WALL_TOP["middle"])
		elif left_top:
			walls_layer.set_cell(x, y, WALL_CORNER_LEFT_EDGE)
			place_wall_if_empty(x, y-1, WALL_TOP["right"])
		elif right_top:
			walls_layer.set_cell(x, y, WALL_CORNER_RIGHT_EDGE)
			place_wall_if_empty(x, y-1, WALL_TOP["left"])
	elif left:
		walls_layer.set_cell(x, y, WALL_CORNER_RIGHT)
		place_wall_if_empty(x, y-1, WALL_TOP["left"])
	else:
		walls_layer.set_cell(x, y, WALL_CORNER_LEFT)
		place_wall_if_empty(x, y-1, WALL_TOP["right"])
		
	return false

func update_walls(top_left = Vector2(0,0), bottom_right = Vector2(Globals.MAP_SIZE-1, Globals.MAP_SIZE-1)):
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
			walls_layer.set_cell(x, y, -1)
	
	# Place walls_layer
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
		
			# Loop through and check all the "rock_layer" tiles that have an empty tile below them.
			if rock_layer.get_cell(x, y) == ROCK and rock_layer.get_cell(x, y+1) == -1:
				
				# Store whether their neighbouring tiles are also rock_layer
				var left = rock_layer.get_cell(x-1, y) == ROCK
				var right = rock_layer.get_cell(x+1, y) == ROCK
				
				# Place a bottom wall below this tile in the correct orientation
				if left and right: # Rock either side
					walls_layer.set_cell(x, y+1, WALL_BOTTOM["middle"])
					place_wall_if_empty(x, y, WALL_TOP["middle"])
				elif left: # Rock left
					walls_layer.set_cell(x, y+1, WALL_BOTTOM["right"])
					place_wall_if_empty(x, y, WALL_TOP["right"])
				elif right: # Rock right
					walls_layer.set_cell(x, y+1, WALL_BOTTOM["left"])
					place_wall_if_empty(x, y, WALL_TOP["left"])
				else: # Empty either side
					walls_layer.set_cell(x, y+1, WALL_BOTTOM["single"])
					place_wall_if_empty(x, y, WALL_TOP["single"])
					
				# If left neighbour is rock_layer and the tile below it is also rock_layer
				# Place a pair of top and bottom walls_layer INSIDE the wall to connect tiles together.
				# If the wall should be a corner instead, then set to the correct corner.
				# Repeat for the right side.
				if left and rock_layer.get_cell(x-1, y+1) == ROCK:
					place_wall_or_corner(x-1, y+1, "left")
				if right and rock_layer.get_cell(x+1, y+1) == ROCK:
					place_wall_or_corner(x+1, y+1, "right")
					
