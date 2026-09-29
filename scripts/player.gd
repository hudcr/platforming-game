extends CharacterBody2D

@export var speed := 300.0
@export var sneak_speed := 120.0
@export var sprint_speed := 550.0
@export var jump_velocity := -1000.0
@export var fall_limit := 1500.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var win_label: Label = $Camera2D/Label
@onready var timer: Timer = $Camera2D/Timer

var finished := false
var fireball_scene = preload("res://scenes/fireball.tscn")
var fall_speed = 0.0


func _ready():
	if not Music.playing:
		Music.play()


func _physics_process(delta: float) -> void:
	if finished and timer.is_stopped():
		Music.stop()
		get_tree().change_scene_to_file("res://scenes/GodotCredits.tscn")
		return

	var gravity = get_gravity() * 2
	if velocity.y > 0:
		gravity *= 1.5
	velocity += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var crouching := Input.is_action_pressed("ui_down") and is_on_floor()
	var direction := Input.get_axis("ui_left", "ui_right")
	var max_speed := sneak_speed if crouching else speed
	if Input.is_key_pressed(KEY_SHIFT) and not crouching:
		max_speed = sprint_speed

	if direction:
		velocity.x = direction * max_speed
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	fall_speed = velocity.y
	move_and_slide()

	if global_position.y > fall_limit:
		die()
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


func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		var fireball = fireball_scene.instantiate()
		fireball.position = global_position + Vector2(0, 36)
		if sprite.flip_h:
			fireball.direction = -1
		get_parent().add_child(fireball)


func die():
	get_tree().call_deferred("reload_current_scene")
