extends Area3D

@onready var audio_player : AudioStreamPlayer3D = $UI/AudioStreamPlayer3D

var player_in_theater = false

var unit_size_inside = 20
var unit_size_outside = 14

var db_inside = -14
var db_outside = -32

var counter = 0.0

func _process(delta):
	if player_in_theater and counter < 1.0:
		counter += delta * 0.5
	elif not player_in_theater and counter > 0.0:
		counter -= delta * 0.5
	
	audio_player.unit_size = lerpf(unit_size_outside, unit_size_inside, clampf(counter, 0.0, 1.0))
	audio_player.volume_db = lerpf(db_outside, db_inside, clampf(counter, 0.0, 1.0))

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_theater = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_theater = false
