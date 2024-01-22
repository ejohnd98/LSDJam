extends Node3D

@export var radius = 10.0
@export var always_on_radius = 2.0
@export var direction_threshold = 0.4
@export var nightmare_progress_speed = 0.1

var player_node : LSDPlayer
var is_on_screen = false

var player_within_radius = false

var jumpscare_played = false

func _ready():
	player_node = GameManager.player

func _process(delta):
	if not player_within_radius:
		return false
	update_on_screen()
	
	if is_on_screen:
		GameManager.adjust_nightmare_progress(delta * nightmare_progress_speed)
		
		if not jumpscare_played:
			GameManager.adjust_nightmare_progress(0.3)
			jumpscare_played = true
			$ScareSound.play()
			$ScareCooldown.start()

func update_on_screen():
	var on_screen = calculate_on_screen()
	is_on_screen = on_screen

func calculate_on_screen() -> bool:
	if not player_within_radius:
		return false
		
	var dist = player_node.global_position.distance_to(global_position)
	if (dist > radius):
		return false
	
	if (dist < always_on_radius):
		return true
	
	var direction_dot = -global_transform.basis.z.dot(player_node.get_forward_vector())
	if (direction_dot < direction_threshold):
		return false
	
	return true

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player_within_radius = true
		print("Player entered nightmare spot: " + str(name))
		
		if jumpscare_played and $ScareCooldown.is_stopped():
			jumpscare_played = false


func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		player_within_radius = false
		print("Player left nightmare spot: " + str(name))
		is_on_screen = false
		
		if jumpscare_played:
			$ScareCooldown.start
