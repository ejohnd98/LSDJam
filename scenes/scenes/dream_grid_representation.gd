extends Node3D

@export var dream_texture : Texture2D
@export var nightmare_texture : Texture2D
@export var player_texture : Texture2D
@export var start_texture : Texture2D
@export var goal_texture : Texture2D

@export var grid_scale : Vector2 = Vector2(0.75,0.75)
@export var pixel_size = 0.004
var world_size : float = 1.0

func create_representation(dream_grid : DreamGrid):
	var grid_size = dream_grid.grid_size
	var cell_separation_x : float = float(1) / float(grid_size.x-1)
	var cell_separation_y : float = float(1) / float(grid_size.y-1)
	var offset_x = (world_size - (world_size * grid_scale.x)) * 0.5
	var offset_y = (world_size - (world_size * grid_scale.y)) * 0.5
	
	for x in grid_size.x:
		for y in grid_size.y:
			var dream_cell : DreamCell = dream_grid.grid[x][y]
			var chosen_texture = dream_texture
			
			if dream_cell.is_nightmare:
				chosen_texture = nightmare_texture
			if dream_cell.is_goal:
				chosen_texture = goal_texture
			if dream_cell.is_start:
				chosen_texture = start_texture
			if dream_grid.player_position == Vector2i(x,y):
				chosen_texture = player_texture
			
			var cell = Sprite3D.new()
			
			cell.position.x = offset_x + float(x) * cell_separation_x * grid_scale.x
			cell.position.y = offset_y + float(grid_size.y - 1 - y) * cell_separation_y * grid_scale.y
			cell.position.z = -0.001
			cell.texture = chosen_texture
			cell.pixel_size = pixel_size
			
			print("added cell at " + str(cell.position.x) + ", " + str(cell.position.y))
			
			$GridParent.add_child(cell)
	pass
