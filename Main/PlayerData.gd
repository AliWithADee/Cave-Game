"""
To allow player stats, such as player inventory and player health, to persists
across different levels of the cave.
"""

extends Node

enum ITEMS { REVOLVER_AMMO, DYNAMITE, GEM }
var player_inventory: Array

func inventory_contains_item(item: int, amount: int = 1):
	if amount <= 0: amount = 1
	
	if amount == 1:
		print("Does the player have item " + str(item) + "?")
	else:
		print("Does the player have " + str(amount) + " of item " + str(item) + "?")

func get_amount_of_item(item: int) -> int:
	return 0
