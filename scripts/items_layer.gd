extends TileMapLayer


func _ready() -> void:
	for cell in get_used_cells():
		var data := get_cell_tile_data(cell)
		var path: String = data.get_custom_data("scene") if data else ""
		if path.is_empty():
			continue
		var instance: Node2D = load(path).instantiate()
		instance.position = get_parent().to_local(to_global(map_to_local(cell)))
		get_parent().add_child.call_deferred(instance)
		erase_cell(cell)
