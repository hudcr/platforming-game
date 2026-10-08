extends CharacterBody2D

var speed = 80
var jump_timer = 0
var player

@onready var hitbox: Area2D = $Hitbox

func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_collision_exception_with(player)

func _physics_process(delta):
	velocity += get_gravity() * delta

	if abs(player.global_position.x - global_position.x) > 800:
		velocity.x = 0
	elif player.global_position.x < global_position.x:
		velocity.x = -speed
	else:
		velocity.x = speed

	jump_timer += delta
	if jump_timer >= 1.5 and is_on_floor():
		velocity.y = -450
		jump_timer = 0

	move_and_slide()

	if hitbox.overlaps_body(player):
		_touch_player()

func _touch_player():
	if player.fall_speed > 100 or player.global_position.y < global_position.y - 60:
		player.velocity.y = -700
		queue_free()
	else:
		player.take_damage()
