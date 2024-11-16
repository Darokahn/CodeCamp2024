extends CharacterBody2D

var enemy

var time_since_hit_wall = 0
var corpse = preload("res://scenes/corpse.tscn")
var corpse_self_prop = preload("res://scenes/enemy.tscn")

var x_direction = 1
var alive = true
var random = RandomNumberGenerator.new()

var health = 10

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
	
func _process(delta: float) -> void:
	pass
	

func _physics_process(delta: float) -> void:
	if alive:
		velocity.x = x_direction * 75
		if is_on_wall() and time_since_hit_wall > 3:
			x_direction *= -1
			time_since_hit_wall = 0
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		time_since_hit_wall += 1
		move_and_slide()
