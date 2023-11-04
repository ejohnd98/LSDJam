extends RigidBody3D

const RAY_LENGTH = 10
const WALK_SPEED = 1.8
const JUMP_VELOCITY = 3.0
const SENSITIVITY = 0.003

@export var ground_snap =  0.05
@export_flags_3d_physics var ground_collision_mask

var is_grounded = false
var vertical_velocity = 0
var velocity = Vector3.ZERO

var is_frozen = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if is_frozen:
		return
	if event.is_action_pressed("Escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		$CameraPivot.rotate_y(-event.relative.x * SENSITIVITY)
		$CameraPivot/Camera3D.rotate_x(-event.relative.y * SENSITIVITY)
		$CameraPivot/Camera3D.rotation.x = clamp($CameraPivot/Camera3D.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	if is_frozen:
		return
	# Perform ground raycast:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position + Vector3.UP, position + Vector3.DOWN * RAY_LENGTH)
	query.exclude= [self, $CollisionShape3D]
	var result = space_state.intersect_ray(query)
	
	if result:
		var is_flat_surface = result["normal"].dot(Vector3.UP) > 0.4
		if is_flat_surface:
			var ground_dist = position.y - result["position"].y
			if ground_dist < ground_snap and $JumpTimer.is_stopped():
				position = result["position"]
				is_grounded = true
				vertical_velocity = 0
			else:
				is_grounded = false
	
	if Input.is_action_pressed("Jump") and is_grounded and $JumpTimer.is_stopped():
		is_grounded = false
		vertical_velocity = JUMP_VELOCITY
		$JumpTimer.start()
	
	if not is_grounded:
		vertical_velocity -= delta * 9
		position.y += vertical_velocity*delta
	
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = ($CameraPivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	else:
		velocity.x = lerp(velocity.x, direction.x * WALK_SPEED, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * WALK_SPEED, delta * 7.0)
	
	position += velocity * delta

func set_frozen (frozen):
	$CollisionShape3D.disabled = frozen
	is_frozen = frozen
