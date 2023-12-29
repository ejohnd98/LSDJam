extends click_interaction

@export var key : String = ""
@export var interact_pickup = true
@export var proximity_pickup = true

func pick_up():
	GameManager.get_dream_grid().dream_keys.append(key)
	queue_free()

func _on_area_3d_body_entered(body):
	if proximity_pickup and body.is_in_group("player") and can_interact_internal():
		interact_count += 1
		pick_up()

func _on_interact():
	if interact_pickup:
		pick_up()
