extends Node2D

signal player_entered

func _ready():
	$TriggerArea.connect("body_entered", self, "on_body_entered")

func on_body_entered(body: Node):
	print("Body entered!")
	emit_signal("player_entered")
