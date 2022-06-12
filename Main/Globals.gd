"""
Stores global constants and variables used throughout the game.
"""

extends Node

# Cave Generation
const CAVE_SIZE = 50 # cells
const CAVE_CELL_SIZE = 32 # pixels
const START_ALIVE_CHANCE = 40 # 40%
const MIN_ALIVE = 3 # cells
const MIN_BIRTH = 5 # cells

var cave_seed: int

# HUD
const MAP_CELL_SIZE = 1 # pixels
const MAP_PADDING = 16 # pixels
