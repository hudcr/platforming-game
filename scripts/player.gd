extends CharacterBody2D

signal health_changed(amount: int)

@export var speed := 450.0
@export var sneak_speed := 120.0
@export var sprint_speed := 600.0
@export var jump_velocity := -1000.0
@export var fall_limit := 1500.0
@export var starting_health := 3
@export var boost_duration := 15.0
@export var boost_speed_multiplier := 1.5
@export var boost_jump_multiplier := 1.3
@export var invincibility_time := 1.0
@export var hurt_bounce_velocity := -500.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var win_label: Label = $Camera2D/Label
@onready var timer: Timer = $Camera2D/Timer
@onready var hud = $HUD

var finished := false
var dead := false
var fireball_scene = preload("res://scenes/fireball.tscn")
var fall_speed = 0.0
var health := 0
var boost_time_left := 0.0
var invincible_time_left := 0.0

func _ready():
	if not Music.playing:
		Music.play()
	if GameState.has_checkpoint:
		global_position = GameState.checkpoint_position
		camera.reset_smoothing()
	health_changed.connect(hud.set_health)
	set_health(starting_health)

func _physics_process(delta: float) -> void:
	if finished and timer.is_stopped():
		Music.stop()
		GameState.reset()
		get_tree().change_scene_to_file("res://scenes/GodotCredits.tscn")
		return

	_update_timers(delta)

	var boost := boost_time_left > 0.0
	var gravity = get_gravity() * 2
	if velocity.y > 0:
		gravity *= 1.5
	velocity += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity * (boost_jump_multiplier if boost else 1.0)

	var crouching := Input.is_action_pressed("ui_down") and is_on_floor()
	var direction := Input.get_axis("ui_left", "ui_right")
	var max_speed := sneak_speed if crouching else speed
	if Input.is_key_pressed(KEY_SHIFT) and not crouching:
		max_speed = sprint_speed
	if boost:
		max_speed *= boost_speed_multiplier

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


func _update_timers(delta: float) -> void:
	if boost_time_left > 0.0:
		boost_time_left = max(boost_time_left - delta, 0.0)
		sprite.modulate = Color(1.0, 0.85, 0.4) if boost_time_left > 0.0 else Color.WHITE

	if invincible_time_left > 0.0:
		invincible_time_left = max(invincible_time_left - delta, 0.0)
		sprite.visible = invincible_time_left == 0.0 or int(invincible_time_left * 15) % 2 == 0


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


func set_health(amount: int) -> void:
	health = amount
	health_changed.emit(health)


func heal() -> void:
	set_health(health + 1)


func apply_boost() -> void:
	boost_time_left = boost_duration


func take_damage() -> void:
	if dead or finished or invincible_time_left > 0.0:
		return
	set_health(health - 1)
	if health <= 0:
		die()
		return
	invincible_time_left = invincibility_time
	velocity.y = hurt_bounce_velocity


func die():
	if dead or finished:
		return
	dead = true
	GameState.on_player_died()
	get_tree().call_deferred("reload_current_scene")
