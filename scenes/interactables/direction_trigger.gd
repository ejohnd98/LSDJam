extends click_interaction

@export var grid_direction: Vector2i = Vector2i.ZERO
@export var proximity_trigger : bool = false

@export var show_mesh : bool = true
@export var show_arrow : bool = true

func _ready():
	var angle = atan2(float(grid_direction.y), float(grid_direction.x))
	var rot_matrix = Basis(Vector3.UP, angle).get_euler()
	$ArrowPivot.rotation = rot_matrix
	
	if show_mesh:
		$MeshInstance3D.show()
	else:
		$MeshInstance3D.hide()
		
	if show_arrow:
		$ArrowPivot.show()
	else:
		$ArrowPivot.hide()
	
	if not proximity_trigger:
		$ProximityTrigger/CollisionShape3D.disabled = true
	
	connect("on_interact", trigger_direction)

func _process(delta):
	if not proximity_trigger or not set_transition_amount or player_body == null:
		return
	
	var player_pos = player_body.position
	player_pos.y = position.y
	
	var dist = position.distance_to(player_pos)
	if (dist < 3):
		var alpha : float = clampf(1.0 - (dist/3.0), 0.0, 1.0)
		GameManager.set_transition_alpha(alpha)
		
		if (alpha >= 0.8):
			pass
			trigger_direction()

func trigger_direction():
	GameManager.move_in_direction(grid_direction)

var set_transition_amount = false
var player_body

func _on_area_3d_body_entered(body):
	if proximity_trigger and body.is_in_group("player"):
		set_transition_amount = true;
		player_body = body

func _on_area_3d_body_exited(body):
	if proximity_trigger and body.is_in_group("player"):
		player_body = null
		set_transition_amount = false;
		GameManager.set_transition_alpha(0.0)


func _on_proximity_trigger_body_entered(body):
	if proximity_trigger and body.is_in_group("player"):
		set_transition_amount = true;
		player_body = body
		trigger_direction()
