extends Control

@onready var player_node = $"../../../Player"

@export var lerp_speed = 5.0

var current_rotation
var target_rotation
var is_frozen = false

func _ready():
	current_rotation = $Needle.rotation

func set_frozen(frozen):
	is_frozen = frozen

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_frozen:
		return
	
	target_rotation = player_node.get_player_rotation() + PI
	var diff = angle_to_angle(current_rotation, target_rotation)
	current_rotation = lerp_angle(current_rotation, target_rotation, delta * lerp_speed)
	
	$Needle.rotation = current_rotation

static func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI
