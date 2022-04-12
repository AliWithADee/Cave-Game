extends TileMap

onready var cave = get_parent()

func on_player_mine(pos) -> bool:
	var cell_pos = world_to_map(pos)
	var x = cell_pos.x
	var y = cell_pos.y
	
	if get_cell(x, y) != cave.ROCK: return false
	if x <= 0 or x >= Globals.MAP_SIZE-1 or y <= 0 or y >= Globals.MAP_SIZE-1: return false
		
	set_cell(x, y, -1)
	cave.update_walls()
	update_bitmask_region(cell_pos-Vector2(1,1), cell_pos+Vector2(1,1))
	return true
