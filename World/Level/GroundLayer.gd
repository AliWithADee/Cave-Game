extends TileMap

const NAVABLE = 0
const NON_NAVABLE = 1

func update_ground_layer(rock_layer: TileMap):
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			if rock_layer.get_cell(x, y) == -1: # not (Vector2(x, y) in objects.occupied) and 
				set_cell(x, y, NAVABLE)
			else:
				set_cell(x, y, NON_NAVABLE)
