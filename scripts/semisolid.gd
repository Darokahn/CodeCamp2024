extends TileMapLayer

var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(player.position.x, position.x)
	var player_high = player.position.x + player.colli
	var self_high
	self.collision_enabled = player_high < self_high
