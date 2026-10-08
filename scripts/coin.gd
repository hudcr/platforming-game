extends Area2D


func _ready() -> void:
	if GameState.is_collected(global_position):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.add_coin()
		GameState.collect(global_position)
		queue_free()
