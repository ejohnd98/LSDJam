extends click_interaction

@export var key : String = ""
@export var pickup_prompt : String = "Pick Up"
@export var interact_pickup = true
@export var proximity_pickup = true

var has_been_picked_up = false

signal on_pick_up

func _ready():
	$Interaction.interact_prompt = pickup_prompt

func pick_up():
	if (has_been_picked_up):
		return
		
	has_been_picked_up = true
	#GameManager.get_dream_grid().dream_keys.append(key)
	PlayerSettings.add_item(key)

	$Sprite3D.hide()
	$MeshInstance3D.hide()
	$Area3D/CollisionShape3D.disabled = true
	
	$AudioStreamPlayer.playing = true
	$PickupEffect.show()
	$PickupEffect.emitting = true
	on_pick_up.emit()
	$Interaction/Collider.disabled = true
	$CollisionShape3D.disabled = true

func _on_area_3d_body_entered(body):
	if proximity_pickup and body.is_in_group("player") and can_interact_internal():
		interact_count += 1
		pick_up()

func _on_interact():
	if interact_pickup:
		pick_up()
