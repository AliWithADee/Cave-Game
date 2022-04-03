extends Node2D

onready var ground = $Ground
onready var walls = $Walls
onready var rock = $Rock

const MAP_SIZE = 50
const CELL_SIZE = 32
const START_ALIVE_CHANCE = 40 # 40%
const MIN_ALIVE = 3
const MIN_BIRTH = 5

const GROUND = 0
const ROCK = 0
const EMPTY = -1

func generate_cave(simulate: bool):
	randomize()
#	for x in range(MAP_SIZE-1):
#		for y in range(MAP_SIZE-1):
#			walls.set_cell(x, y, EMPTY)

	initialize_cave()
	if simulate:
		var finished = simulate_rock_generation()
		while not finished:
			finished = simulate_rock_generation()
	
	#update_walls()

func initialize_cave():
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			ground.set_cell(x, y, GROUND)
			walls.set_cell(x, y, EMPTY)
			
			var tile = ROCK if (randi() % 100) < START_ALIVE_CHANCE else EMPTY
			if x < 3 or x > MAP_SIZE-4 or y < 3 or y > MAP_SIZE-4: # Border of 3
				tile = ROCK
				
			rock.set_cell(x, y, tile)
	
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
	
	if not cells_changed:
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

func update_walls(top_left = Vector2(0,0), bottom_right = Vector2(MAP_SIZE-1, MAP_SIZE-1)):
	# Clear map
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
			walls.set_cell(x, y, EMPTY)

	var num = 1
	
	# Place walls
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
			
		#	if num <= 0: break
			
			# Is rock and has nothing beneath it
			if rock.get_cell(x, y) == ROCK and rock.get_cell(x, y+1) == EMPTY:
				num -= 1
				
				# There is no bottom wall here already
				if not check_corner(x, y):
					
					# Place top wall and bottom wall
					
					var left_rock = rock.get_cell(x-1, y) == ROCK
					var right_rock = rock.get_cell(x+1, y) == ROCK
					
					if left_rock and right_rock:
						walls.set_cell(x, y, WALL_TOP["middle"])
						walls.set_cell(x, y+1, WALL_BOTTOM["middle"])
					elif left_rock:
						walls.set_cell(x, y, WALL_TOP["right"])
						walls.set_cell(x, y+1, WALL_BOTTOM["right"])
					elif right_rock:
						walls.set_cell(x, y, WALL_TOP["left"])
						walls.set_cell(x, y+1, WALL_BOTTOM["left"])
					else:
						walls.set_cell(x, y, WALL_TOP["single"])
						walls.set_cell(x, y+1, WALL_BOTTOM["single"])
				
				# Place bottom AND top walls to the sides if in a corner
				
				if rock.get_cell(x-1, y+1) == ROCK and rock.get_cell(x-1, y) == ROCK:
					if walls.get_cell(x-1, y+1) == EMPTY:
						walls.set_cell(x-1, y+1, WALL_BOTTOM["left"])
						if walls.get_cell(x-1, y) == EMPTY:
							walls.set_cell(x-1, y, WALL_TOP["left"])
						else:
							check_corner(x-1, y)
					else:
						walls.set_cell(x-1, y+1, WALL_BOTTOM["left"])
						if walls.get_cell(x-1, y) == EMPTY:
							walls.set_cell(x-1, y, WALL_TOP["left"])
						check_corner(x-1, y+1)
				if rock.get_cell(x+1, y+1) == ROCK and rock.get_cell(x+1, y) == ROCK:
					if walls.get_cell(x+1, y+1) == EMPTY:
						walls.set_cell(x+1, y+1, WALL_BOTTOM["right"])
						if walls.get_cell(x+1, y) == EMPTY:
							walls.set_cell(x+1, y, WALL_TOP["right"])
						else:
							check_corner(x+1, y)
					else:
						walls.set_cell(x+1, y+1, WALL_BOTTOM["right"])
						if walls.get_cell(x+1, y) == EMPTY:
							walls.set_cell(x+1, y, WALL_TOP["right"])
						check_corner(x+1, y+1)

func check_corner(x, y):
	# Has a bottom wall here already
	if walls.get_cell(x, y) in WALL_BOTTOM.values():
		var left_wall = rock.get_cell(x-1, y) == EMPTY and rock.get_cell(x-1, y-1) == ROCK
		var right_wall = rock.get_cell(x+1, y) == EMPTY and rock.get_cell(x+1, y-1) == ROCK
		
		# Left and Right are both bottom walls
		if left_wall and right_wall:
			walls.set_cell(x, y, WALL_CORNER_MIDDLE)
			walls.set_cell(x, y-1, WALL_TOP["middle"])
			if walls.get_cell(x, y+1) == EMPTY:
				walls.set_cell(x, y+1, WALL_BOTTOM["single"])
		
		# Only left is bottom wall
		elif left_wall:
			
			# Right is rock
			if rock.get_cell(x+1, y) == ROCK:
				walls.set_cell(x, y, WALL_CORNER_LEFT)
				walls.set_cell(x, y-1, WALL_TOP["right"])
				if walls.get_cell(x, y+1) == EMPTY:
					walls.set_cell(x, y+1, WALL_BOTTOM["left"])
			else:
				walls.set_cell(x, y, WALL_CORNER_LEFT_EDGE)
				walls.set_cell(x, y-1, WALL_TOP["right"])
				if walls.get_cell(x, y+1) == EMPTY:
					walls.set_cell(x, y+1, WALL_BOTTOM["single"])
		
		# Only right is bottom wall
		elif right_wall:
			
			# Left is rock
			if rock.get_cell(x-1, y) == ROCK:
				walls.set_cell(x, y, WALL_CORNER_RIGHT)
				walls.set_cell(x, y-1, WALL_TOP["left"])
				if walls.get_cell(x, y+1) == EMPTY:
					walls.set_cell(x, y+1, WALL_BOTTOM["right"])
			else:
				walls.set_cell(x, y, WALL_CORNER_RIGHT_EDGE)
				walls.set_cell(x, y-1, WALL_TOP["left"])
				if walls.get_cell(x, y+1) == EMPTY:
					walls.set_cell(x, y+1, WALL_BOTTOM["single"])
		
		# If neither left or right is bottom wall, then this shouldn't happen!
		else:
			print("This should not happen #1")
		
		return true
		
	return false
