extends TileMap

onready var cave = get_parent()

func on_player_mine(pos):
	var cell_pos = world_to_map(pos)
	if get_cell(cell_pos.x, cell_pos.y) == cave.ROCK:
		set_cell(cell_pos.x, cell_pos.y, cave.EMPTY)
		
		cave.update_walls()
		update_bitmask_region(cell_pos-Vector2(1,1), cell_pos+Vector2(1,1))
