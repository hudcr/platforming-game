extends Node

signal coins_changed(amount: int)

var coins := 0
var saved_coins := 0
var has_checkpoint := false
var checkpoint_position := Vector2.ZERO
var activated_checkpoints: Array[Vector2] = []
var collected: Array[Vector2] = []
var pending_collected: Array[Vector2] = []


func reset() -> void:
	coins = 0
	saved_coins = 0
	has_checkpoint = false
	checkpoint_position = Vector2.ZERO
	activated_checkpoints.clear()
	collected.clear()
	pending_collected.clear()


func add_coin() -> void:
	coins += 1
	coins_changed.emit(coins)


func collect(item_position: Vector2) -> void:
	pending_collected.append(item_position)


func is_collected(item_position: Vector2) -> bool:
	return collected.has(item_position)


func is_checkpoint_active(flag_position: Vector2) -> bool:
	return activated_checkpoints.has(flag_position)


func activate_checkpoint(flag_position: Vector2, spawn_position: Vector2) -> void:
	if not activated_checkpoints.has(flag_position):
		activated_checkpoints.append(flag_position)
	has_checkpoint = true
	checkpoint_position = spawn_position
	saved_coins = coins
	collected.append_array(pending_collected)
	pending_collected.clear()


func on_player_died() -> void:
	coins = saved_coins
	pending_collected.clear()
