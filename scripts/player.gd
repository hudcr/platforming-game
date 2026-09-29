extends CharacterBody2D

@export var speed := 300.0
@export var sneak_speed := 120.0
@export var jump_velocity := -550.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var win_label: Label = $Camera2D/Label
@onready var timer: Timer = $Camera2D/Timer

var finished := false


func _physics_process(delta: float) -> void:
	if finished and timer.is_stopped():
		get_tree().change_scene_to_file("res://scenes/GodotCredits.tscn")
		return

	# Always apply gravity so the water Area2D can reverse it.
	velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var crouching := Input.is_action_pressed("ui_down") and is_on_floor()
	var direction := Input.get_axis("ui_left", "ui_right")
	var max_speed := sneak_speed if crouching else speed

	if direction:
		velocity.x = direction * max_speed
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	_update_animation(direction, crouching)


func _update_animation(direction: float, crouching: bool) -> void:
	var next := "idle"
	if crouching:
		next = "sneak" if direction else "crouch"
	elif direction or not is_on_floor():
		next = "walk"

	if anim.current_animation != next:
		anim.play(next)


func _on_exit_door_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		win_label.visible = true
		timer.start()
		finished = true
