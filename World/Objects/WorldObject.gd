extends StaticBody2D

func on_player_mine(pos) -> bool:
	print(name + " destroyed")
	queue_free()
	return true
