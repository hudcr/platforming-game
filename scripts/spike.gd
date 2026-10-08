extends StaticBody2D


func _on_hazard_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
