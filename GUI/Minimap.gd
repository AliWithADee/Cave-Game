extends TileMap

const MAP_TILE_SIZE = 1 # pixels
const MAP_PADDING = 16 # pixels

const ROCK = 1
const GROUND = 0
const PLAYER = 2

var player_pos: Vector2

func _ready():
	position.x = get_viewport_rect().size.x - ((Globals.CAVE_SIZE + 1) * MAP_TILE_SIZE * scale.x) - MAP_PADDING
	position.y = (MAP_TILE_SIZE * scale.y) + MAP_PADDING

func set_player_pos(new_pos):
	if player_pos: set_cell(player_pos.x, player_pos.y, GROUND)
	set_cell(new_pos.x, new_pos.y, PLAYER)
	player_pos = new_pos

func update_minimap(rock_layer: TileMap):
	for x in range(-1, Globals.CAVE_SIZE+1):
		for y in range(-1, Globals.CAVE_SIZE+1):
			var tile = GROUND if rock_layer.get_cell(x, y) == -1 else ROCK
			
			if x < 0 or x > Globals.CAVE_SIZE-1 or y < 0 or y > Globals.CAVE_SIZE-1: tile = GROUND
			
			set_cell(x, y, tile)
