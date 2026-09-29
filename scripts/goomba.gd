extends CharacterBody2D

var speed = 80
var jump_timer = 0
var player


func _ready():
	player = get_parent().get_node("Player")
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


func _on_hitbox_body_entered(body):
	if body.name == "Player":
		if body.fall_speed > 100 or body.global_position.y < global_position.y - 60:
			body.velocity.y = -700
			queue_free()
		else:
			body.die()
