extends click_interaction

@export var grid_direction: Vector2i = Vector2i.ZERO
@export var force_new_dream = false
@export var proximity_trigger : bool = false

@export var show_mesh : bool = true
@export var show_arrow : bool = true

@export var start_dist : float = 3.0

var has_triggered = false
var can_trigger = false

func _ready():
	var angle = atan2(float(grid_direction.x), float(grid_direction.y))
	var rot_matrix = Basis(Vector3.UP, angle - rotation.y).get_euler()
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
		$DistortionBubble.hide()
		$DistortionBubbleInteract.show()
	else:
		$DistortionBubbleInteract.hide()
	
	await GameManager.on_dream_started
	can_trigger = true
	
	connect("on_interact", trigger_direction)

func _process(delta):
	if not can_trigger:
		return
	if not proximity_trigger or not set_transition_amount or player_body == null:
		return
	
	var player_pos = player_body.position
	player_pos.y = position.y
	
	var dist = position.distance_to(player_pos)
	if (dist < start_dist):
		var alpha : float = clampf(1.0 - (dist/start_dist), 0.0, 1.0)
		GameManager.set_transition_alpha(alpha)

func trigger_direction():
	if has_triggered or not can_trigger:
		return
	
	has_triggered = true
	if force_new_dream:
		GameManager.pick_random_dream()
	else:
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
		print("body enetered: " + str(body.name))
		set_transition_amount = true;
		player_body = body
		trigger_direction()
