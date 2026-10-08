extends CanvasLayer

const HEART_TEXTURE := preload("res://assets/heartsprite.png")

@onready var hearts: HBoxContainer = $Margin/VBox/Hearts
@onready var coin_label: Label = $Margin/VBox/Coins/Label


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(GameState.coins)


func set_health(amount: int) -> void:
	for child in hearts.get_children():
		child.queue_free()
	for i in amount:
		var heart := TextureRect.new()
		heart.texture = HEART_TEXTURE
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(48, 42)
		hearts.add_child(heart)


func _on_coins_changed(amount: int) -> void:
	coin_label.text = "x %d" % amount
