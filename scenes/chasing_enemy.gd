extends Node3D

var is_active = false
var is_on_screen = false
var player_within_radius = false

var player_control_limit_mod = 0.0

@export var chase_speed = 1
@export var direction_threshold = 0.45
@export var nightmare_progress_dist_threshold = 15.0

#@export var progress_curve : Curve

const chase_speed_to_anim_speed = 2.7

#@onready var player_node : LSDPlayer = GameManager.player
#@onready var anim : AnimationPlayer = $AnimationPlayer

func start_chase():
	is_active = true
	$AnimationPlayer.play("WalkAnim")
	#$AudioStreamPlayer.play()
	#$AudioStreamPlayer3D.play()

	player_control_limit_mod = 0.9
	#player_node.set_frozen(true)
	
	#await $PlayerStunTimer.timeout
	
	#player_node.set_frozen(false)
	
	#freeze player input for a few seconds (or significantly reduce)
	#play scream-like sound (re-dead)

func end_chase():
	is_active = false
	$AnimationPlayer.stop()
	#$AudioStreamPlayer.fade_out(true)
	#$AudioStreamPlayer.detach_from_parent()
	GameManager.player.limit_controls(1.0)
	queue_free()

func chase_player(delta):
	var player_pos = GameManager.player.global_position

	var direction = (GameManager.player.global_position - global_position).normalized()
	var direction_flattened : Vector2 = Vector2(direction.x, direction.z)
	
	rotation.y = (PI/2.0) - direction_flattened.angle()
	
	var dist = GameManager.player.global_position.distance_to(global_position)
	#var nightmare_progress_amount = progress_curve.sample(1.0 - clampf(dist/nightmare_progress_dist_threshold, 0.0, 1.0))
	var nightmare_progress_amount = (1.0 - clampf(dist/nightmare_progress_dist_threshold, 0.0, 1.0))
	
	var speed = chase_speed * (0.75 + 0.25 * (1.0 - nightmare_progress_amount))
	$AnimationPlayer.speed_scale = chase_speed_to_anim_speed * speed
	
	var nightmare_amount = (nightmare_progress_amount*0.1) * delta
	
	if (dist > 1.0):
		global_position += direction * delta * speed
	elif is_on_screen:
		nightmare_amount += (0.025 * delta)
	
	if is_on_screen:
		nightmare_amount += (nightmare_progress_amount * 0.1 * delta)
	
	GameManager.adjust_nightmare_progress(nightmare_amount)
	
	#$Armature/Skeleton3D/Cube.scale.y = 0.2 + nightmare_progress_amount * 2
	
	if player_control_limit_mod > 0.0:
		player_control_limit_mod -= 0.5 * delta
	
	GameManager.player.limit_controls(1.0 - (nightmare_progress_amount * 0.5) - player_control_limit_mod)

func check_on_screen() -> bool:	
	var direction = (GameManager.player.global_position - global_position).normalized()
	
	var direction_dot = -direction.dot(GameManager.player.get_forward_vector())
	if (direction_dot < direction_threshold):
		return false
	
	if not GameManager.player.can_see_point(global_position):
		return false
	
	return true
	
func _process(delta):
	if player_within_radius or is_active:
		is_on_screen = check_on_screen()
	
	if is_active:
		if not player_within_radius and not is_on_screen:
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
