class_name DreamGrid

extends Control

@export var dream_name = "Dream"

@export var is_nightmare = false

@export_group("Keys")
@export var dream_keys: Array[String] = []

@export_group("Dream Grid Textures")
@export var use_custom_textures = false
@export var dream_texture : Texture2D
@export var nightmare_texture : Texture2D
@export var player_texture : Texture2D
@export var start_texture : Texture2D
@export var goal_texture : Texture2D
@export var key_texture : Texture2D

var grid_size = Vector2i.ZERO
var grid = []
var player_position = Vector2i.ZERO
var start_cell = null
var goal_position : Vector2i = -Vector2i.ONE

# :^)
var letter_array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n","o","p", "q", "r", "s", "t", "u", "v", "w","x", "y", "z"]

func initialize_grid():
	populate_grid_array()
	hide()
			
func populate_grid_array():
	grid_size.x = $GridContainer.columns
	grid_size.y = $GridContainer.get_child_count() / grid_size.x
	for x in grid_size.x:
		grid.append([])
		for y in grid_size.y:
			grid[x].append($GridContainer.get_child(y*grid_size.x + x))
			grid[x][y].grid_position = Vector2i(x,y)
	print("populated grid of size: " + str(grid_size))
	
	for x in grid_size.x:
		for y in grid_size.y:
			if grid[x][y].is_start:
				start_cell = grid[x][y]
				player_position = Vector2i(x,y)
			if grid[x][y].is_goal:
				goal_position = Vector2i(x,y)

func move_in_direction (direction: Vector2i):
	print("DreamGrid: Direction moved: " + str(direction))
	player_position.x = wrap(player_position.x + direction.x, 0, grid_size.x)
	player_position.y = wrap(player_position.y + direction.y, 0, grid_size.y)
	update_player_icon()

func update_player_icon():
	for x in grid_size.x:
		for y in grid_size.y:
			grid[x][y].UpdateTexture(player_position == Vector2i(x,y))

func get_current_cell() -> DreamCell:
	return grid[player_position.x][player_position.y]

func get_start_cell() -> DreamCell:
	return start_cell

func get_cell_relative(dir : Vector2i) -> DreamCell:
	var actual_pos = player_position
	actual_pos.x = wrap(actual_pos.x + dir.x, 0, grid_size.x)
	actual_pos.y = wrap(actual_pos.y + dir.y, 0, grid_size.y)
	return grid[actual_pos.x][actual_pos.y]
	

func get_scene_from_position ():
	return grid[player_position.x][player_position.y].scene_name

func get_current_cell_name (include_coordinate : bool = true) -> String:
	var coord_string = ""
	if (include_coordinate and not is_nightmare):
		coord_string = str(letter_array[player_position.x]).to_upper() + str(grid_size.y - player_position.y)
	return dream_name + " " + coord_string
