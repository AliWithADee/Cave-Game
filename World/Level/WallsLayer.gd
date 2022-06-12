extends TileMap

onready var rock_layer = get_parent().get_node("RockLayer")

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

func clear_walls():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			set_cell(x, y, -1)

func place_wall_if_empty(x, y, cell):
	if get_cell(x, y) != -1: return false
	set_cell(x, y, cell)
	return true

# Function used to place a bottom half wall.
# If the wall should instead be a corner, then it is set to the correct corner piece
func place_wall_or_corner(x, y, wall_varient):
	var down = rock_layer.get_cell(x, y+1) == rock_layer.ROCK
	var up_left = rock_layer.get_cell(x-1, y-1) == rock_layer.ROCK
	var up_right = rock_layer.get_cell(x+1, y-1) == rock_layer.ROCK
	var left = rock_layer.get_cell(x-1, y) == rock_layer.ROCK
	var right = rock_layer.get_cell(x+1, y) == rock_layer.ROCK
	
	# If there is rock beneath this tile
	# AND there is rock down and to the left OR down and to the right of this tile,
	# then place the original bottomd and top walls varients
	if down:
		# If there is no rock on either side, always place a middle wall
		# Else, place whatever varient it was originally
		if not (left or right) and (up_left and up_right):
			set_cell(x, y, WALL_BOTTOM["middle"])
			place_wall_if_empty(x, y-1, WALL_TOP["middle"])
		else:
			set_cell(x, y, WALL_BOTTOM[wall_varient])
			place_wall_if_empty(x, y-1, WALL_TOP[wall_varient])
		return true
		
	# If both neighbours are empty
	if not (left or right):
		# Check tiles above neighbours
		var left_top = rock_layer.get_cell(x-1, y-1) == rock_layer.ROCK
		var right_top = rock_layer.get_cell(x+1, y-1) == rock_layer.ROCK
		
		# If both tiles above neighbours are rock_layer,
		# Set to middle corner, etc
		if left_top and right_top:
			set_cell(x, y, WALL_CORNER_MIDDLE)
			place_wall_if_empty(x, y-1, WALL_TOP["middle"])
		elif left_top:
			set_cell(x, y, WALL_CORNER_LEFT_EDGE)
			place_wall_if_empty(x, y-1, WALL_TOP["right"])
		elif right_top:
			set_cell(x, y, WALL_CORNER_RIGHT_EDGE)
			place_wall_if_empty(x, y-1, WALL_TOP["left"])
	elif left:
		set_cell(x, y, WALL_CORNER_RIGHT)
		place_wall_if_empty(x, y-1, WALL_TOP["left"])
	else:
		set_cell(x, y, WALL_CORNER_LEFT)
		place_wall_if_empty(x, y-1, WALL_TOP["right"])
		
	return false

func update_walls(top_left = Vector2(0,0), bottom_right = Vector2(Globals.CAVE_SIZE-1, Globals.CAVE_SIZE-1)):
	# Clear tilemap
	clear_walls()
	
	# Place wall tiles
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
		
			# Loop through and check all the "rock_layer" tiles that have an empty tile below them.
			if rock_layer.get_cell(x, y) == rock_layer.ROCK and rock_layer.get_cell(x, y+1) == -1:
				
				# Store whether their neighbouring tiles are also rock_layer
				var left = rock_layer.get_cell(x-1, y) == rock_layer.ROCK
				var right = rock_layer.get_cell(x+1, y) == rock_layer.ROCK
				
				# Place a bottom wall below this tile in the correct orientation
				if left and right: # Rock either side
					set_cell(x, y+1, WALL_BOTTOM["middle"])
					place_wall_if_empty(x, y, WALL_TOP["middle"])
				elif left: # Rock left
					set_cell(x, y+1, WALL_BOTTOM["right"])
					place_wall_if_empty(x, y, WALL_TOP["right"])
				elif right: # Rock right
					set_cell(x, y+1, WALL_BOTTOM["left"])
					place_wall_if_empty(x, y, WALL_TOP["left"])
				else: # Empty either side
					set_cell(x, y+1, WALL_BOTTOM["single"])
					place_wall_if_empty(x, y, WALL_TOP["single"])
					
				# If left neighbour is rock_layer and the tile below it is also rock_layer
				# Place a pair of top and bottom walls_layer INSIDE the wall to connect tiles together.
				# If the wall should be a corner instead, then set to the correct corner.
				# Repeat for the right side.
				if left and rock_layer.get_cell(x-1, y+1) == rock_layer.ROCK:
					place_wall_or_corner(x-1, y+1, "left")
				if right and rock_layer.get_cell(x+1, y+1) == rock_layer.ROCK:
					place_wall_or_corner(x+1, y+1, "right")
					
