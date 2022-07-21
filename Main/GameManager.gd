"""
Manages the state and flow of the game and can be accessed from anywhere.
"""

extends Node

var camera_zoom: Vector2

onready var rng := RandomNumberGenerator.new()
var level_seed: int

var levels_since_magpie: int
const MIN_LEVELS_BETWEEN_MAGPIE = 1
const MAX_LEVELS_BETWEEN_MAGPIE = 10
const MAGPIE_CHANCE = 10

func load_magpie() -> bool:
	if levels_since_magpie < MIN_LEVELS_BETWEEN_MAGPIE: return false
	if levels_since_magpie >= MAX_LEVELS_BETWEEN_MAGPIE: return true
	return percent_chance(MAGPIE_CHANCE)
	
func percent_chance(chance: float) -> bool:
	return rng.randf_range(0, 99) < chance
