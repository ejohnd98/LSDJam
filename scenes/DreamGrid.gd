extends Control

var grid_size = Vector2i.ZERO
var grid = []
var player_position = Vector2i.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_grid_array()
			
func populate_grid_array():
	grid_size.x = $GridContainer.columns
	grid_size.y = $GridContainer.get_child_count() / grid_size.x
	for x in grid_size.x:
		grid.append([])
		for y in grid_size.y:
			grid[x].append($GridContainer.get_child(y*grid_size.x + x))
	print("populated grid of size: " + str(grid_size))
	
	for x in grid_size.x:
		for y in grid_size.y:
			if grid[x][y].is_start:
				player_position = Vector2i(x,y)
	

func move_in_direction (direction: Vector2i):
	player_position.x = wrap(player_position.x + direction.x, 0, grid_size.x)
	player_position.y = wrap(player_position.y - direction.y, 0, grid_size.y)
	for x in grid_size.x:
		for y in grid_size.y:
			grid[x][y].UpdateTexture(player_position == Vector2i(x,y))

func get_scene_from_position ():
	return grid[player_position.x][player_position.y].scene_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
