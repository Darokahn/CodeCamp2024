extends RigidBody2D

var reduced_gravity = 1

var default_gravity = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bodies: Array[Node2D] = $onGround.get_overlapping_bodies()
	var on_ground = bodies.size() > 1
	if Input.is_action_just_pressed("move_up"):
		if on_ground:
			apply_central_impulse(Vector2(0, -1500))
	if Input.is_action_pressed("move_up"):
		gravity_scale = reduced_gravity
		
	else:
		gravity_scale = default_gravity
	if Input.is_action_pressed("move_left"):
		if on_ground:
			apply_central_impulse(Vector2(-70, 0))
		apply_central_impulse(Vector2(-20, 0))
	if Input.is_action_pressed("move_right"):
		if on_ground:
			apply_central_impulse(Vector2(70, 0))
		apply_central_impulse(Vector2(20, 0))
	
func _physics_process(delta: float) -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass
