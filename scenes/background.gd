extends ParallaxBackground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child: ParallaxLayer in get_children():
		var sprite = child.get_node("Sprite2D")
		var sprite_dimensions: Rect2 = sprite.get_rect()
		child.motion_mirroring = sprite_dimensions.size * sprite.scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
