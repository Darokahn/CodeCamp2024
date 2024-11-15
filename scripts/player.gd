extends CharacterBody2D

@export var default_gravity = 200
@export var reduced_gravity = 170
@export var speed = 100
@export var friction = 0.9

var gravity = default_gravity

var last_valid_jump: int = 10
var jump_frames = 6

var time_since_attack = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var attack_direction = Vector2(Input.get_axis("arrow_left", "arrow_right"), Input.get_axis("arrow_up", "arrow_down"))
	
	$weaponBox.position = attack_direction * 100
	
	var hitObject: bool = $weaponBox.get_overlapping_bodies().size() > 1
	
	var launch_direction = attack_direction * -1
	
	
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		last_valid_jump = 0
	elif last_valid_jump <= jump_frames:
		last_valid_jump += 1
	var x_movement = Input.get_axis("move_left", "move_right")
		
	if Input.is_action_pressed("move_up"):
		gravity = reduced_gravity
	else:
		gravity = default_gravity
	velocity.x += x_movement * speed
	velocity.y += gravity
	velocity *= friction
	if last_valid_jump < jump_frames:
		velocity.y -= 700
	move_and_slide()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass
