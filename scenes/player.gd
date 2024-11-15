extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bodies: Array[Node2D] = $onGround.get_overlapping_bodies()
	if Input.is_action_just_pressed("move_up") and bodies.size() > 1:
		apply_central_impulse(Vector2(0, -200))
	
func _physics_process(delta: float) -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass
