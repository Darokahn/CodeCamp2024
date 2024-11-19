extends RigidBody2D

var timer: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GPUParticles2D.emitting = true # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
