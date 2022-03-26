extends Node2D

func _ready():
	for area in $Melee.get_children():
		area.connect("body_entered", self, "body_enter_melee")
		
	for area in $Mine.get_children():
		area.connect("body_entered", self, "body_enter_mine")

func disable_hurt_boxes():
	for area in $Melee.get_children():
		area.get_node("CollisionShape").disabled = true
		
	for area in $Mine.get_children():
		area.get_node("CollisionShape").disabled = true

func enable_hurt_box(name):
	if "Melee" in name:
		$Melee.get_node(name).get_node("CollisionShape").disabled = false
	if "Mine" in name:
		$Mine.get_node(name).get_node("CollisionShape").disabled = false

func body_enter_melee(other):
	if other.name != "Player" and other.name != "TileMap":
		print("Melee: " + other.name)
	
func body_enter_mine(other):
	if other.name == "TileMap":
		var tile
