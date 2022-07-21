extends Node2D

onready var rock_layer = $RockLayer
onready var level_exit = $Objects/LevelExit

onready var loading = $HUD/Loading
onready var minimap = $HUD/Minimap

func _ready():
	loading.visible = true
	level_exit.connect("player_entered", self, "on_player_exit_level")
	minimap.update_minimap(rock_layer)
	
	GameManager.levels_since_magpie = 0
	
	var anim = loading.get_node("AnimationPlayer")
	anim.play("Fade_Out")
	yield(anim, "animation_finished")

# DEBUG KEYBINDS
func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("exit_level"):
			on_player_exit_level()

func on_player_exit_level():
	var anim = loading.get_node("AnimationPlayer")
	anim.play("Fade_In")
	yield(anim, "animation_finished")
	
	get_tree().change_scene("res://World/Level/Level.tscn")
