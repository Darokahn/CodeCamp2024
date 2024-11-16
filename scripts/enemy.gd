extends CharacterBody2D

var enemy
var time_since_hit_wall = 0

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var x_direction = 1

func _physics_process(delta: float) -> void:
	velocity.x = x_direction * 75
	if is_on_wall() and time_since_hit_wall > 3:
		x_direction *= -1
		print(velocity.x)
		time_since_hit_wall = 0
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	time_since_hit_wall += 1
	move_and_slide()
