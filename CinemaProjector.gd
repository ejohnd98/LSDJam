extends Node3D

@export var is_spinning = true
@export var spin_speed = 8.0

@export var direction = Vector2i.UP

func _ready():
	set_spinning(is_spinning)

func _process(delta):
	if is_spinning:
		$FilmPlayer/Reel1.rotation.z += delta * spin_speed
		$FilmPlayer/Reel2.rotation.z += delta * spin_speed
		$FilmPlayer/FilmThing.rotation.x += delta * spin_speed

func set_spinning(spin : bool):
	is_spinning = spin
	if spin:
		$FilmPlayer/FilmThing.show()
		$AnimationPlayer.play("Light")
		$AnimationPlayer.speed_scale = 10.0
		$AudioStreamPlayer3D.play()
		$InteractionObject.show()
		$InteractionObject/Collider.disabled = false
		
	else:
		$AnimationPlayer.stop()
		$FilmPlayer/FilmThing.hide()
		$AudioStreamPlayer3D.stop()
		$InteractionObject.hide()
		$InteractionObject/Collider.disabled = true


func _on_interaction_object_on_interact():
	GameManager.move_in_direction(direction)
