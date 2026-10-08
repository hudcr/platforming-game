extends Control


func _ready() -> void:
	$Center/VBox/PlayButton.grab_focus()


func _on_play_button_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/level.tscn")
