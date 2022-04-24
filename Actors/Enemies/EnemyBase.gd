extends KinematicBody2D

export(int) var move_speed = 2500

onready var navigation = get_parent().get_parent().get_node("World")
onready var sprite = $Sprite
onready var search_box = $SearchBox
onready var search_timer = $SearchTimer
onready var path_timer = $PathTimer
onready var soft_collision = $SoftCollision
onready var line = $NavigationLine

var velocity = Vector2.ZERO
var path: Array = []
var has_aggro = false
var stunned = false
var health = 5

var colliding = false

func _ready():
	search_timer.connect("timeout", self, "search_for_player")
	path_timer.connect("timeout", self, "get_path_to_player")

func search_for_player():
	print("searching")
	for area in search_box.get_overlapping_areas():
		if area.get_parent().name == "Player":
			has_aggro = true

func get_path_to_player():
	var player = get_parent().get_node("Player")
	if player:
		path = navigation.get_simple_path(position, player.position, false)
		line.points = path

func determine_velocity():
	if path.size() > 0 and not stunned and not colliding:
		velocity = position.direction_to(path[1])
		
		if position == path[0]:
			path.pop_front()
			
func _process(delta):
	line.global_position = Vector2.ZERO
	velocity = Vector2.ZERO
	if has_aggro and path_timer.is_stopped():
		get_path_to_player()
	elif search_timer.is_stopped():
		search_timer.start()
	determine_velocity()
	
	if soft_collision.is_colliding():
		print("soft colliding")
		velocity = soft_collision.get_push_vector()
		colliding = true
	else:
		colliding = false
	
	velocity = velocity * delta * move_speed 
	velocity = move_and_slide(velocity)

func take_damage(damage):
	health -= damage
	if health <= 0:
		queue_free()

func on_player_hit():
	sprite.modulate = Color.red
	stunned = true
	take_damage(1)
	yield(Utils.create_timer(0.1), "timeout")
	sprite.modulate = Color.white
	yield(Utils.create_timer(0.4), "timeout")
	stunned = false
