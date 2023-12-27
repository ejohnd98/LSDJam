extends click_interaction

@export var grid_direction: Vector2i = Vector2i.ZERO

func _ready():
	var angle = atan2(float(grid_direction.y), float(grid_direction.x))
	var rot_matrix = Basis(Vector3.UP, angle).get_euler()
	$ArrowPivot.rotation = rot_matrix
	
	connect("on_interact", trigger_direction)

func _process(delta):
	if not set_transition_amount or player_body == null:
		return
	
	
	
	var dist = position.distance_to(player_body.position)
	if (dist < 3):
		var alpha : float = clampf(1.0 - ((dist-1.0)/3.0), 0.0, 1.0)
		GameManager.set_transition_alpha(alpha)
		
		if (alpha >= 0.9):
			pass
			trigger_direction()

func trigger_direction():
	GameManager.move_in_direction(grid_direction)

var set_transition_amount = false
var player_body

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		set_transition_amount = true;
		player_body = body

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		player_body = null
		set_transition_amount = false;
		GameManager.set_transition_alpha(0.0)
