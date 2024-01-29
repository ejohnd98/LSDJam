extends Node3D

@export var direction = Vector2i.UP
@export var max_range = 3

var is_active = false

var has_swung = false
var swing_power = 0.0
var increasing = true
@onready var power_bar : ProgressBar = $SubViewport/Control/PowerBarContainer/ProgressBar

var golf_ball_start_pos : Vector3
var golf_ball_dist = 100

@export var power_bar_curve : Curve
@export var power_bar_speed = 4.0

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
	$UI.hide()

func _process(delta):
	if not is_active:
		return
	
	if not has_swung:
		if increasing:
			swing_power += delta * power_bar_speed * power_bar_curve.sample(swing_power)
		else:
			swing_power -= delta * power_bar_speed * power_bar_curve.sample(swing_power)
		
		if swing_power >= 1.0:
			increasing = false
		elif swing_power <= 0.0:
			increasing = true
		
		power_bar.value = swing_power * power_bar.max_value
	else:
		if not $GolfInteraction/GolfBallArcTime.is_stopped():
			animate_golf_ball(1.0 - ($GolfInteraction/GolfBallArcTime.time_left / $GolfInteraction/GolfBallArcTime.wait_time))

func swing_club():
	has_swung = true
	$GolfInteraction/GolfBallArcTime.wait_time = 2 + (1 * swing_power)
	golf_ball_dist = 50.0 + 150.0 * swing_power
	$GolfInteraction/AnimationPlayer.speed_scale = 0.6 + (0.6 * swing_power)
	$GolfInteraction/AnimationPlayer.play("swing")
	
	CameraManagerObject.set_camera_lookat($GolfInteraction/GolfBall, true)

	await $GolfInteraction/GolfBallArcTime.timeout
	
	var move_amount = 0
	if swing_power < 0.333:
		move_amount = 1
	elif swing_power < 0.666:
		move_amount = 2
	else:
		move_amount = 3
	
	GameManager.move_in_direction(direction * move_amount)
	
	#TODO:
	#have camera look at golf ball
	#have golf ball shoot off (can scale distance with swing_power)

func start_golf():
	$GolfInteraction/AlternateCamera.set_active()
	GameManager.set_crosshair(false)
	await CameraManagerObject.fixed_lerp_done
	$"GolfInteraction/Golf Club".show()
	$UI.show()
	is_active = true
	golf_ball_start_pos = $GolfInteraction/GolfBall.position

func end_golf():
	is_active = false
	GameManager.set_crosshair(true)
	$UI.hide()
	$"GolfInteraction/Golf Club".hide()
	
	CameraManagerObject.lerp_back_to_player()
	await CameraManagerObject.fixed_lerp_done 
	CameraManagerObject.reset_camera()
	$GolfInteraction/GolfBall.position = golf_ball_start_pos

func _on_golf_interaction_on_interact():
	start_golf()

func animate_golf_ball (time : float):
	var position_offset = Vector3.ZERO
	position_offset.z = golf_ball_dist * time
	position_offset.y = sin(time * PI) * golf_ball_dist / 4.0
	
	$GolfInteraction/GolfBall.position = golf_ball_start_pos + position_offset
