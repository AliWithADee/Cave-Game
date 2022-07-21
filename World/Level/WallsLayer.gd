extends TileMap

onready var rock_layer = get_parent().get_node("RockLayer")

const TOP = {
	"single": 0,
	"left": 1,
	"middle": 2,
	"right": 3,
}
const BOTTOM = {
	"single": 4,
	"left": 5,
	"middle": 6,
	"right": 7,
}
const CORNER_LEFT = 8
const CORNER_MIDDLE = 9
const CORNER_RIGHT = 10
const EDGE_CORNER_LEFT = 11
const EDGE_CORNER_RIGHT = 12

func clear_walls():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			set_cell(x, y, -1)

func place_wall_if_empty(x, y, tile):
	if get_cell(x, y) != -1: return false
	set_cell(x, y, tile)
	return true

# Method used to place a bottom half wall.
# If the wall should instead be a corner, then it is set to the correct corner piece
func place_wall_or_corner(x, y, variant):
	var down = rock_layer.get_cell(x, y+1) == rock_layer.ROCK
	var up_left = rock_layer.get_cell(x-1, y-1) == rock_layer.ROCK
	var up_right = rock_layer.get_cell(x+1, y-1) == rock_layer.ROCK
	var left = rock_layer.get_cell(x-1, y) == rock_layer.ROCK
	var right = rock_layer.get_cell(x+1, y) == rock_layer.ROCK
	
	# If there is rock beneath this tile
	# AND there is rock down and to the left OR down and to the right of this tile,
	# then place the original bottom and top walls varients
	if down:
		# If there is no rock on either side, always place a middle wall
		# Else, place whatever variant it was originally
		if not (left or right) and (up_left and up_right):
			set_cell(x, y, BOTTOM["middle"])
			place_wall_if_empty(x, y-1, TOP["middle"])
		else:
			set_cell(x, y, BOTTOM[variant])
			place_wall_if_empty(x, y-1, TOP[variant])
		return true
		
	# If both neighbours are empty
	if not (left or right):
		# Check tiles above neighbours
		var left_top = rock_layer.get_cell(x-1, y-1) == rock_layer.ROCK
		var right_top = rock_layer.get_cell(x+1, y-1) == rock_layer.ROCK
		
		# If both tiles above neighbours are rock,
		# Set to middle corner, etc
		if left_top and right_top:
			set_cell(x, y, CORNER_MIDDLE)
			place_wall_if_empty(x, y-1, TOP["middle"])
		elif left_top:
			set_cell(x, y, EDGE_CORNER_LEFT)
			place_wall_if_empty(x, y-1, TOP["right"])
		elif right_top:
			set_cell(x, y, EDGE_CORNER_RIGHT)
			place_wall_if_empty(x, y-1, TOP["left"])
	elif left:
		set_cell(x, y, CORNER_RIGHT)
		place_wall_if_empty(x, y-1, TOP["left"])
	else:
		set_cell(x, y, CORNER_LEFT)
		place_wall_if_empty(x, y-1, TOP["right"])
		
	return false

func update_walls(top_left = Vector2(0,0), bottom_right = Vector2(Globals.CAVE_SIZE-1, Globals.CAVE_SIZE-1)):
	# Clear tilemap
	clear_walls()
	
	# Place wall tiles
	for x in range(top_left.x, bottom_right.x+1):
		for y in range(top_left.y, bottom_right.y+1):
			
			# Loop through and check all the rock tiles that have an empty tile below them.
			if rock_layer.get_cell(x, y) == rock_layer.ROCK and rock_layer.get_cell(x, y+1) == -1:
				
				# Store whether their neighbouring tiles are also rock
				var left = rock_layer.get_cell(x-1, y) == rock_layer.ROCK
				var right = rock_layer.get_cell(x+1, y) == rock_layer.ROCK
				
				# Place a bottom wall below this tile in the correct orientation
				if left and right: # Rock either side
					set_cell(x, y+1, BOTTOM["middle"])
					place_wall_if_empty(x, y, TOP["middle"])
				elif left: # Rock left
					set_cell(x, y+1, BOTTOM["right"])
					place_wall_if_empty(x, y, TOP["right"])
				elif right: # Rock right
					set_cell(x, y+1, BOTTOM["left"])
					place_wall_if_empty(x, y, TOP["left"])
				else: # Empty either side
					set_cell(x, y+1, BOTTOM["single"])
					place_wall_if_empty(x, y, TOP["single"])
					
				# If left neighbour is rock and the tile below it is also rock
				# Place a pair of top and bottom walls INSIDE the wall to connect tiles together.
				# If the wall should be a corner instead, then set to the correct corner.
				# Repeat for the right side.
				if left and rock_layer.get_cell(x-1, y+1) == rock_layer.ROCK:
					place_wall_or_corner(x-1, y+1, "left")
				if right and rock_layer.get_cell(x+1, y+1) == rock_layer.ROCK:
					place_wall_or_corner(x+1, y+1, "right")
					
