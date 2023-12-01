extends click_interaction

@export var grid_direction: Vector2i = Vector2i.ZERO

func _ready():
	var angle = atan2(float(grid_direction.y), float(grid_direction.x))
	var rot_matrix = Basis(Vector3.UP, angle).get_euler()
	$ArrowPivot.rotation = rot_matrix
	
	connect("on_interact", trigger_direction) 

func trigger_direction():
	get_tree().get_root().get_node("SubViewportContainer/SubViewport/Game").move_in_direction(grid_direction)
