extends Node3D

signal on_grid_updated

func refresh_dream_grid(grid : DreamGrid):
	$SubViewport/Control.create_dream_grid_visuals(grid)
	on_grid_updated.emit()

func get_dream_grid_texture() -> ViewportTexture:
	return $SubViewport2/TextureRect.get_texture()
