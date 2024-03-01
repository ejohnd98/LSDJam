class_name DreamGridViewControl
extends Control

@export var dream_texture : Texture2D
@export var nightmare_texture : Texture2D
@export var player_texture : Texture2D
@export var start_texture : Texture2D
@export var goal_texture : Texture2D
@export var key_texture : Texture2D

@export var viewport_size : Vector2

@onready var grid_parent = $CenterContainer/GridContainer

func create_dream_grid_visuals(dream_grid : DreamGrid):
	
	for tile in grid_parent.get_children():
		tile.queue_free()
	
	var grid_size = dream_grid.grid_size
	var texture_size = Vector2(viewport_size.x / float(dream_grid.grid_size.x), viewport_size.y / float(dream_grid.grid_size.y))
	
	texture_size -= Vector2(grid_size) * 3.0
	
	grid_parent.columns = grid_size.x
	
	for y in grid_size.y:
		for x in grid_size.x:
			var dream_cell : DreamCell = dream_grid.grid[x][y]
			var chosen_texture = null
			
			var cell_bg = TextureRect.new()
			var cell = TextureRect.new()
			
			if dream_grid.use_custom_textures:
				cell_bg.texture = dream_grid.dream_texture
				if dream_cell.is_nightmare or dream_cell.is_dream_transition:
					chosen_texture = dream_grid.nightmare_texture
				if dream_cell.is_goal:
					chosen_texture = dream_grid.goal_texture
				if dream_cell.is_start:
					chosen_texture = dream_grid.start_texture
				if dream_cell.ShowKey():
					chosen_texture = dream_grid.key_texture
				if dream_grid.player_position == Vector2i(x,y):
					chosen_texture = dream_grid.player_texture
			else:
				cell_bg.texture = dream_texture
				if dream_cell.is_nightmare or dream_cell.is_dream_transition:
					chosen_texture = nightmare_texture
				if dream_cell.is_goal:
					chosen_texture = goal_texture
				if dream_cell.is_start:
					chosen_texture = start_texture
				if dream_cell.ShowKey():
					chosen_texture = key_texture
				if dream_grid.player_position == Vector2i(x,y):
					chosen_texture = player_texture
			
			cell_bg.self_modulate = dream_grid.modulate_color
			cell.self_modulate = dream_grid.modulate_color
			
			
			cell.texture = chosen_texture
			
			cell_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cell_bg.stretch_mode = TextureRect.STRETCH_SCALE
			cell.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cell.stretch_mode = TextureRect.STRETCH_SCALE
			
			cell_bg.custom_minimum_size = texture_size
			cell.size = texture_size
			
			grid_parent.add_child(cell_bg)
			cell_bg.add_child(cell)
