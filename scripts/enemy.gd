extends CharacterBody2D

var enemy

var time_since_hit_wall = 0
var corpse = preload("res://scenes/corpse.tscn")
var corpse_self_prop = preload("res://scenes/enemy.tscn")

var x_direction = 1
var alive = true
var random = RandomNumberGenerator.new()

var health = 10

func _ready():
	$Sprite2D.play("walk")

func kill():
	if alive:
		alive = false
		var parent = get_parent()
		var corpse_instance: RigidBody2D = corpse.instantiate()
		corpse_instance.position = self.position
		
		parent.add_child(corpse_instance)
		self.reparent(corpse_instance, true)
		var death_vector = Vector2((randi() % 400) - 200, - (randi() % 200) - 50)
		var offset = Vector2((randi() % 10) - 5, (randi() % 10) - 5)
		corpse_instance.apply_impulse(death_vector, offset)
		self.set_collision_mask_value(1, false)
		self.set_collision_mask_value(2, false)
		self.set_collision_layer_value(1, false)
		self.set_collision_layer_value(2, false)
		
func _process(delta: float) -> void:
	pass
	

func _physics_process(delta: float) -> void:
	if alive:
		var collision_objects = $Area2D.get_overlapping_bodies()
		for object in collision_objects:
			if "player" in object:
				object.restart()
		$Sprite2D.flip_h = x_direction > 0
		velocity.x = x_direction * 75
		if is_on_wall() and time_since_hit_wall > 3:
			x_direction *= -1
			time_since_hit_wall = 0
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		time_since_hit_wall += 1
		move_and_slide()
