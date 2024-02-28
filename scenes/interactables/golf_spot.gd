extends Node3D

@export var max_range = 2.0

var is_active = false

var has_swung = false
var swing_power = 0.0
var increasing = true

var starting_rotation = 0
var aim_rotation = 0

var golf_ball_start_pos : Vector3
var golf_ball_dist = 100

@export var power_bar_curve : Curve
@export var power_bar_speed = 4.0

@onready var golf_ui = $UI

func _unhandled_input(event):
	if not is_active:
		return
	
	#todo, do something else here
	#if event.is_action_pressed("Escape"):
		#end_golf()
	if not has_swung and event.is_action_pressed("Jump") or event.is_action_pressed("Interact"):
		swing_club()

func _ready():
	$"GolfInteraction/Golf Club".hide()
	golf_ui.hide()
	starting_rotation = $GolfInteraction.rotation.y

func _process(delta):
	if not is_active:
		return
	
	#TODO: have a phase where the direction is chosen
	# rotate pivot in UI
	# then construct a vector2 and round x and y to get move direction
	
	if not has_swung and golf_ui.visible:
		var input_dir = Input.get_axis("Left", "Right")
		aim_rotation += input_dir * delta
		
		$GolfInteraction.rotation.y = starting_rotation - aim_rotation
		
		$SubViewport/Control.set_aim_rotation(starting_rotation + aim_rotation)
		
		if increasing:
			swing_power += delta * power_bar_speed * power_bar_curve.sample(swing_power)
		else:
			swing_power -= delta * power_bar_speed * power_bar_curve.sample(swing_power)
		
		if swing_power >= 1.0:
			increasing = false
		elif swing_power <= 0.0:
			increasing = true
		
		$SubViewport/Control/TextureProgressBar.value = swing_power * 100
		$SubViewport/Control.set_aim_strength(swing_power)
	else:
		if not $GolfInteraction/GolfBallArcTime.is_stopped():
			animate_golf_ball(1.0 - ($GolfInteraction/GolfBallArcTime.time_left / $GolfInteraction/GolfBallArcTime.wait_time))

var is_nice_shot = false
var is_out_of_bounds = false
func play_vo_line():
	if is_nice_shot:
		$NiceShot.play()
	if is_out_of_bounds:
		await get_tree().create_timer(1.5).timeout
		$OB.play()

func swing_club():
	has_swung = true
	GameManager.clear_control_prompts()
	
	var trajectory = Vector2.UP.rotated(starting_rotation + aim_rotation).normalized()
	trajectory *= (max_range * swing_power)
	var move_vector = Vector2i(roundi(trajectory.x), roundi(trajectory.y))
	
	is_nice_shot = GameManager.get_dream_grid().get_cell_relative(move_vector).is_goal
	is_out_of_bounds = GameManager.get_dream_grid().get_cell_relative(move_vector).is_dream_transition
	
	var wait_time = 1.4 + (1 * swing_power)
	if is_out_of_bounds:
		wait_time += 2.5
	if is_nice_shot:
		wait_time += 1.0
	
	$GolfInteraction/GolfBallArcTime.wait_time = wait_time
	golf_ball_dist = 40.0 + 150.0 * swing_power
	$GolfInteraction/AnimationPlayer.speed_scale = 0.9 + (0.3 * swing_power)
	$GolfInteraction/AnimationPlayer.play("swing")
	
	
	
	await $GolfInteraction/GolfBallArcTime.timeout
	
	golf_ui.hide()
	golf_ui.queue_free()
	GameManager.move_in_direction(move_vector)
	
	#TODO:
	#have camera look at golf ball
	#have golf ball shoot off (can scale distance with swing_power)

func start_golf():
	$SubViewport/Control.set_player_position(GameManager.get_dream_grid().player_position)
	golf_ui.reparent(GameManager.player.get_camera_parent())
	golf_ui.scale = Vector3.ONE * 0.279
	golf_ui.position = Vector3.MODEL_REAR
	golf_ui.rotation = Vector3.ZERO
	
	CameraManagerObject.set_camera_override_node($GolfInteraction/AlternateCamera)
	GameManager.hide_interact_text()
	
	await get_tree().create_timer(0.6).timeout
	
	$SubViewport/Control/TextureProgressBar.value = 0
	GameManager.set_crosshair(false)
	#await CameraManagerObject.fixed_lerp_done
	$"GolfInteraction/Golf Club".show()
	golf_ui.show()
	GameManager.add_control_prompt("Swing: Left Mouse/E")
	GameManager.add_control_prompt("Aim: A/D")
	
	GameManager.set_compass_visible(false)
	
	
	is_active = true
	golf_ball_start_pos = $GolfInteraction/GolfBall.position

func end_golf():
	is_active = false
	GameManager.set_crosshair(true)
	golf_ui.hide()
	GameManager.clear_control_prompts()
	$GolfInteraction.rotation.y = starting_rotation
	GameManager.set_compass_visible(true)
	$"GolfInteraction/Golf Club".hide()
	
	#CameraManagerObject.lerp_back_to_player()
	#await CameraManagerObject.fixed_lerp_done 
	CameraManagerObject.reset_camera()
	$GolfInteraction/GolfBall.position = golf_ball_start_pos

func _on_golf_interaction_on_interact():
	start_golf()

func animate_golf_ball (time : float):
	var position_offset = Vector3.ZERO
	position_offset.z = golf_ball_dist * time
	position_offset.y = sin(time * PI) * golf_ball_dist / 4.0
	
	$GolfInteraction/GolfBall.position = golf_ball_start_pos + position_offset
