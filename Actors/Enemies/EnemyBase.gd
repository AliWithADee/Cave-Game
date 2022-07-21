extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var sprite = $Sprite
onready var search_timer = $SearchTimer
onready var search_box = $SearchBox
onready var attack_timer = $AttackTimer
onready var melee_box = $MeleeHurtbox
onready var soft_collision = $SoftCollision
onready var line = $NavigationLine

var move_speed = 2500
var damage_output = 1
var health = 5

var player: Node2D
var path: Array = []
var velocity = Vector2.ZERO
var stunned = false

func _ready():
	search_box.connect("area_entered", self, "player_entered_search_radius")
	melee_box.connect("area_entered", self, "player_entered_melee_box")
	attack_timer.connect("timeout", self, "attack_timer_finished")
	
func player_entered_search_radius(area: Area2D):
	if not player:
		var node = area.get_parent()
		if node.name == Globals.PLAYER_NODE:
			player = node

func determine_path_to_player():
	if player:
		path = world.get_simple_path(position, player.position, false)
		melee_box.look_at(player.position)
		line.points = path # DEBUG

func determine_velocity(delta):
	velocity = Vector2.ZERO
	if path.size() > 1 and not stunned:
		velocity = position.direction_to(path[1]) * move_speed * delta
		
		if position == path[0]:
			path.pop_front()
	
	if soft_collision.is_colliding():
		velocity = soft_collision.get_push_vector() * move_speed * delta

func _physics_process(delta):
	determine_velocity(delta)
	velocity = move_and_slide(velocity)

func _process(delta):
	line.global_position = Vector2.ZERO
	if player: determine_path_to_player()
	
func take_damage(damage: int):
	sprite.modulate = Color.red
	stunned = true
	health -= damage
	if health < 0: health = 0
	if health == 0:
		return queue_free()
	yield(Utils.create_timer(0.1), "timeout")
	sprite.modulate = Color.white
	yield(Utils.create_timer(0.4), "timeout")
	stunned = false

func player_entered_melee_box(area):
	attack_timer.start()

func attack_timer_finished():
	var areas = melee_box.get_overlapping_areas()
	if areas.size() > 0:
		# DEBUG
		melee_box.get_node("CollisionShape").modulate = Color.red
		yield(Utils.create_timer(0.1), "timeout")
		melee_box.get_node("CollisionShape").modulate = Color.white
		
		var hit_box: Area2D = areas[0]
		var node = hit_box.get_parent()
		
		if node.has_method("take_damage"):
			node.take_damage(damage_output)
		
		attack_timer.start()
