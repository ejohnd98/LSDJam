extends Node3D

@export var direction = Vector2i.UP
@export var max_range = 3

var is_active = false

var has_swung = false
var swing_power = 0.0
var increasing = true
@onready var power_bar : ProgressBar = $SubViewport/Control/PowerBarContainer/ProgressBar

func _unhandled_input(event):
	if not is_active:
		return
	
	if event.is_action_pressed("Escape"):
		end_golf()
	
	if event.is_action_pressed("Jump"):
		swing_club()

func _ready():
	$"GolfInteraction/Golf Club".hide()
	$UI.hide()

func _process(delta):
	if not is_active:
		return
	
	if not has_swung:
		if increasing:
			swing_power += delta
		else:
			swing_power -= delta
		
		if swing_power >= 1.0:
			increasing = false
		elif swing_power <= 0.0:
			increasing = true
		
		power_bar.value = swing_power * power_bar.max_value
		#$"GolfInteraction/Golf Club".rotation.x = deg_to_rad(swing_power * 80)

func swing_club():
	has_swung = true
	$GolfInteraction/AnimationPlayer.play("swing")
	
	await $GolfInteraction/AnimationPlayer.animation_finished
	
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
	await CameraManagerObject.fixed_lerp_done
	$"GolfInteraction/Golf Club".show()
	$UI.show()
	is_active = true

func end_golf():
	is_active = false
	$UI.hide()
	$"GolfInteraction/Golf Club".hide()
	
	CameraManagerObject.lerp_back_to_player()
	await CameraManagerObject.fixed_lerp_done 
	CameraManagerObject.reset_camera()

func _on_golf_interaction_on_interact():
	start_golf()
