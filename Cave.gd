extends Node2D

onready var ground = $Ground
onready var walls = $Walls
onready var rock = $Rock

const MAP_SIZE = 100
const CELL_SIZE = 32
const START_ALIVE_CHANCE = 40 # 40%
const MIN_ALIVE = 3
const MIN_BIRTH = 5

const GROUND = 0
const ROCK = 0
const EMPTY = -1

func generate_cave(simulate: bool):
	randomize()
	initialize_cave()
	if simulate:
		var finished = simulate_rock_generation()
		while not finished:
			finished = simulate_rock_generation()

func initialize_cave():
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			ground.set_cell(x, y, GROUND)
			walls.set_cell(x, y, EMPTY)
			
			var tile = ROCK if (randi() % 100) < START_ALIVE_CHANCE else EMPTY
			if x < 3 or x > MAP_SIZE-4 or y < 3 or y > MAP_SIZE-4: # Border of 3
				tile = ROCK
				
			rock.set_cell(x, y, tile)
	
	update_walls()
	rock.update_bitmask_region(Vector2.ZERO, Vector2(MAP_SIZE-1,MAP_SIZE-1))
	
func num_rock_neighbours(cell_x, cell_y):
	var count = 0
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			if not (i == 0 and j == 0):
				var x = cell_x+i
				var y = cell_y+j
				if rock.get_cell(x, y) == ROCK:
					count += 1
	return count
	
func simulate_rock_generation():
	var changed_cells = []
	
	var cells_changed = false # Whether the simulation is finished or not
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var tile = rock.get_cell(x, y)
			if tile == ROCK:
				if num_rock_neighbours(x, y) < MIN_ALIVE:
					changed_cells.append({"x": x, "y": y, "value": EMPTY})
					cells_changed = true # If cell changed, then simulation is not complete
			elif tile != ROCK:
				if num_rock_neighbours(x, y) >= MIN_BIRTH:
					changed_cells.append({"x": x, "y": y, "value": ROCK})
					cells_changed = true # If cell changed, then simulation is not complete
					
	for cell in changed_cells:
		rock.set_cell(cell["x"], cell["y"], cell["value"])
		
	update_walls()
	rock.update_bitmask_region(Vector2.ZERO, Vector2(MAP_SIZE-1,MAP_SIZE-1))
	
	return not cells_changed

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

func clear_walls(top_left = Vector2(0,0), bottom_right = Vector2(MAP_SIZE-1, MAP_SIZE-1)):
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
			walls.set_cell(x, y, EMPTY)

func place_wall_if_empty(x, y, cell):
	if walls.get_cell(x, y) != EMPTY: return false
	walls.set_cell(x, y, cell)
	return true

# Function used to place a bottom half wall.
# If the wall should instead be a corner, then it is set to the correct corner piece
func place_wall_or_corner(x, y, wall_varient):
	var down = rock.get_cell(x, y+1) == ROCK
	var down_left = rock.get_cell(x-1, y+1) == ROCK
	var down_right = rock.get_cell(x+1, y+1) == ROCK
	
	# If there is rock beneath this tile
	# AND there is rock down and to the left OR down and to the right of this tile,
	# then place the original bottom and top walls varients
	if down and (down_left or down_right):
		walls.set_cell(x, y, WALL_BOTTOM[wall_varient])
		place_wall_if_empty(x, y-1, WALL_TOP[wall_varient])
		return true
		
	var left = rock.get_cell(x-1, y) == ROCK
	var right = rock.get_cell(x+1, y) == ROCK
	
	# If both neighbours are empty
	if not (left or right):
		# Check tiles above neighbours
		var left_top = rock.get_cell(x-1, y-1) == ROCK
		var right_top = rock.get_cell(x+1, y-1) == ROCK
		
		# If both tiles above neighbours are rock,
		# Set to middle corner, etc
		if left_top and right_top:
			walls.set_cell(x, y, WALL_CORNER_MIDDLE)
			place_wall_if_empty(x, y-1, WALL_TOP["middle"])
		elif left_top:
			walls.set_cell(x, y, WALL_CORNER_LEFT_EDGE)
			place_wall_if_empty(x, y-1, WALL_TOP["right"])
		elif right_top:
			walls.set_cell(x, y, WALL_CORNER_RIGHT_EDGE)
			place_wall_if_empty(x, y-1, WALL_TOP["left"])
	elif left:
		walls.set_cell(x, y, WALL_CORNER_RIGHT)
		place_wall_if_empty(x, y-1, WALL_TOP["left"])
	else:
		walls.set_cell(x, y, WALL_CORNER_LEFT)
		place_wall_if_empty(x, y-1, WALL_TOP["right"])
		
	return false

func update_walls(top_left = Vector2(0,0), bottom_right = Vector2(MAP_SIZE-1, MAP_SIZE-1)):
	clear_walls()
	
	# Place walls
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
		
			# Loop through and check all the "rock" tiles that have an empty tile below them.
			if rock.get_cell(x, y) == ROCK and rock.get_cell(x, y+1) == EMPTY:
				
				# Store whether their neighbouring tiles are also rock
				var left = rock.get_cell(x-1, y) == ROCK
				var right = rock.get_cell(x+1, y) == ROCK
				
				# Place a bottom wall below this tile in the correct orientation
				if left and right: # Rock either side
					walls.set_cell(x, y+1, WALL_BOTTOM["middle"])
					place_wall_if_empty(x, y, WALL_TOP["middle"])
				elif left: # Rock left
					walls.set_cell(x, y+1, WALL_BOTTOM["right"])
					place_wall_if_empty(x, y, WALL_TOP["right"])
				elif right: # Rock right
					walls.set_cell(x, y+1, WALL_BOTTOM["left"])
					place_wall_if_empty(x, y, WALL_TOP["left"])
				else: # Empty either side
					walls.set_cell(x, y+1, WALL_BOTTOM["single"])
					place_wall_if_empty(x, y, WALL_TOP["single"])
				
				# If left neighbour is rock and the tile below it is also rock
				# Place a pair of top and bottom walls INSIDE the wall to connect tiles together.
				# If the wall should be a corner instead, then set to the correct corner.
				# Repeat for the right side.
				if left and rock.get_cell(x-1, y+1) == ROCK:
					place_wall_or_corner(x-1, y+1, "left")
				if right and rock.get_cell(x+1, y+1) == ROCK:
					place_wall_or_corner(x+1, y+1, "right")
					
