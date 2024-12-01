extends RigidBody2D

@export var lifetime = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GPUParticles2D.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifetime -= 1
	if lifetime <= 0:
		self.queue_free()
