extends Node3D

var is_active = false
var is_on_screen = false
var player_within_radius = false

var los_lost = false

var player_control_limit_mod = 0.0

@export var chase_speed = 1.0
@export var direction_threshold = 0.45
@export var activation_direction_threshold = 0.75
@export var nightmare_progress_dist_threshold = 15.0

@export var check_los = true
@export var escape_distance = 9.0

@export var progress_curve : Curve

const chase_speed_to_anim_speed = 2.5

var player_node : LSDPlayer
var player_dist

var speed_increase = 0.0

func _ready():
	player_node = GameManager.player
	move_to_ground()

func move_to_ground():
	#Snap to ground
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, global_position + Vector3.DOWN * 4.0)
	query.exclude= [self, $Area3D/CollisionShape3D]
	var result = space_state.intersect_ray(query)
	
	if result:
		global_position = result["position"]

func start_chase():
	is_active = true
	$AnimationPlayer.play("WalkAnim")
	$AudioStreamPlayer.play()
	$AudioStreamPlayer3D.play()
	
	$StartAnim.play("start_chase")
	
	player_node.get_camera_shake().start(0.5)
	
	GameManager.adjust_nightmare_progress(0.25)

	player_control_limit_mod = 0.95

func end_chase():
	is_active = false
	$AnimationPlayer.stop()
	$AudioStreamPlayer.fade_out(true)
	$AudioStreamPlayer.detach_from_parent()
	player_node.limit_controls(1.0)
	queue_free()

func chase_player(delta):
	move_to_ground()
	var player_pos = player_node.global_position

	var direction = (player_node.global_position - global_position).normalized()
	var direction_flattened : Vector2 = Vector2(direction.x, direction.z)
	
	rotation.y = (PI/2.0) - direction_flattened.angle()
	
	var nightmare_progress_amount = progress_curve.sample(1.0 - clampf(player_dist/nightmare_progress_dist_threshold, 0.0, 1.0))
	
	speed_increase += delta * 0.025
	
	var speed = speed_increase + chase_speed * (0.75 + 0.25 * (1.0 - nightmare_progress_amount))
	$AnimationPlayer.speed_scale = chase_speed_to_anim_speed * speed
	
	var nightmare_amount = (0.025 + (nightmare_progress_amount*0.15)) * delta
	
	if (player_dist > 1.0):
		global_position += direction * delta * speed
	else:
		nightmare_amount += (1.0 - player_dist) * delta
	
	if is_on_screen:
		nightmare_amount += (nightmare_progress_amount * 0.1 * delta)
	
	GameManager.adjust_nightmare_progress(nightmare_amount)
	
	if player_control_limit_mod > 0.0:
		player_control_limit_mod -= 0.2 * delta
	
	player_node.limit_controls(1.0 - (nightmare_progress_amount * 0.5) - player_control_limit_mod)

func check_on_screen() -> bool:	
	var direction = (player_node.global_position - global_position).normalized()
	
	var direction_dot = -direction.dot(player_node.get_forward_vector())
	if is_active:
		if (direction_dot < direction_threshold):
			return false
	else:
		if (direction_dot < activation_direction_threshold):
			return false
	
	if check_los and not player_node.can_see_point(global_position):
		#in this frame, we do not have LoS
		if los_lost and $OffscreenTimer.is_stopped():
			return false
		elif not los_lost:
			los_lost = true
			$OffscreenTimer.start()
		return is_on_screen
	else:
		los_lost = false
		$OffscreenTimer.stop()
	
	return true
	
func _process(delta):
	if player_within_radius or is_active:
		is_on_screen = check_on_screen()
	
	if is_active:
		player_dist = player_node.global_position.distance_to(global_position)
		
		if (player_dist > escape_distance) and not is_on_screen:
			end_chase()
			
		else:
			chase_player(delta)
			
	elif player_within_radius and is_on_screen:
		start_chase()

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player_within_radius = true


func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		player_within_radius = false
