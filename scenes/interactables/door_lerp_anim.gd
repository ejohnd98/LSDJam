extends Node3D

@export var lerp_speed : float = 1.0
@export var lerp_curve : Curve
var lerp_progress = 0.0

var open_transform_a
var open_transform_b
var closed_transform_a
var closed_transform_b

var is_open = false

func _ready():
	open_transform_a = $DoorAOpen.transform
	open_transform_b = $DoorBOpen.transform
	closed_transform_a = $DoorA.transform
	closed_transform_b = $DoorB.transform

func set_open():
	is_open = true

func set_closed():
	is_open = false

func _physics_process(delta):
	if is_open and lerp_progress < 1.0:
		lerp_progress = clamp(lerp_progress+delta*lerp_speed, 0.0, 1.0)
	if not is_open and lerp_progress > 0.0:
		lerp_progress = clamp(lerp_progress-delta*lerp_speed, 0.0, 1.0)
	
	var lerp_value = lerp_curve.sample(lerp_progress)
	$DoorA.transform = closed_transform_a.interpolate_with(open_transform_a, lerp_value)
	$DoorB.transform = closed_transform_b.interpolate_with(open_transform_b, lerp_value)
