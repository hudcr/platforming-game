extends Area2D

const BLUE_REGION := Rect2(0, 0, 14, 39)
const RED_REGION := Rect2(16, 0, 14, 39)

@export var spawn_offset := Vector2(0, -32)

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.region_rect = RED_REGION if GameState.is_checkpoint_active(global_position) else BLUE_REGION


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not GameState.is_checkpoint_active(global_position):
		GameState.activate_checkpoint(global_position, global_position + spawn_offset)
		sprite.region_rect = RED_REGION
