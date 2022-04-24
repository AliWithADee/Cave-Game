extends TileMap

onready var rock_layer = get_parent().get_node("RockLayer")
onready var objects = get_parent().get_parent().get_node("Objects")

const GROUND = 0

func initialise_ground_layer():
	for x in range(Globals.MAP_SIZE):
		for y in range(Globals.MAP_SIZE):
			if rock_layer.get_cell(x, y) == -1: #not (Vector2(x, y) in objects.occupied) and
				set_cell(x, y, GROUND)
			else:
				set_cell(x, y, 1)

func initialise_pathfinding():
	pass
