extends Sprite2D
var tracked: Node2D
@export var parallax_scale: float = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tracked = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	material.set_shader_parameter("offset", tracked.global_position * parallax_scale)
