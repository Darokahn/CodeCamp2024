extends CharacterBody2D

@export var default_gravity = 40
@export var reduced_gravity = 20
@export var speed = 20
@export var friction = 0.9

var player

var selections
enum selection {none, hammer, pogo}
var selected = selection.hammer

var gravity = default_gravity

var movement_values = Vector4()
var movement_axes = Vector2()

var last_valid_jump: int = 10
var jump_frames = 6
enum direction {left, right, up, down}
var facing: direction = direction.left
var time_since_on_ground = 0
var jump_force_per_frame = 100

var pogo_data = {
	"time_since_attack_idle": 0,
	"time_since_big_attack": 0,
	"launch_scale": 500
}

var hammer_data = {
	"is_spinning": false,
	"total_steps": 8,
	"spin_progress": 8,
	"spin_frames": [],
	"default_position": Vector2(0, 20),
	"swing_distance": 20
}

func _ready() -> void:
	selections = [$none, $hammer, $pogo]
	var swing_distance = hammer_data["swing_distance"]
	for i in range(8):
		var angle = (float(i)/hammer_data["total_steps"]) * (2 * PI)
		hammer_data["spin_frames"].append(Vector2(cos(angle) * swing_distance, sin(angle) * swing_distance))

func big_pogo(launch_direction, highest_hit):
	velocity += launch_direction * (pogo_data["launch_scale"] * highest_hit)

func process_pogo():
	var attack_distance = 20
	var attack_direction = Vector2(Input.get_axis("arrow_left", "arrow_right"), Input.get_axis("arrow_up", "arrow_down"))
	
	$pogo.position = attack_direction.normalized() * attack_distance
	
	var hit_objects = $pogo.get_overlapping_bodies()
	
	var launch_direction = attack_direction * -1
	
	if attack_direction.length() > 0:
		if pogo_data["time_since_attack_idle"] < 4:
			var highest_hit = 0
			for object in hit_objects:
				if "enemy" in object:
					highest_hit = 1.5
				else:
					highest_hit = max(highest_hit, 1)
			big_pogo(launch_direction, highest_hit)
		pogo_data["time_since_attack_idle"] += 1
	else:
		pogo_data["time_since_attack_idle"] = 0

func process_hammer():
	var delay_scale = 3
	
	if Input.is_action_just_pressed("activate_hammer") and time_since_on_ground > 1:
		hammer_data["is_spinning"] = true
	if Input.is_action_just_released("activate_hammer"):
		hammer_data["is_spinning"] = false

	if hammer_data["is_spinning"]:
		hammer_data["spin_progress"] = (hammer_data["spin_progress"] + 1) % (hammer_data["total_steps"] * delay_scale)
		var spin_progress = hammer_data["spin_progress"]
		if facing == direction.left:
			spin_progress = (hammer_data["total_steps"] * delay_scale) - spin_progress - 1
		$hammer.position = hammer_data["spin_frames"][spin_progress / delay_scale] + hammer_data["default_position"]
	else:
		hammer_data["spin_progress"] = 0
		$hammer.position = hammer_data["default_position"]

func _process(delta: float) -> void:
	if is_on_floor():
		time_since_on_ground = 0
	else:
		time_since_on_ground += 1
	var strings = ["move_up", "move_down", "move_left", "move_right"]
	movement_values = Vector4()
	for i in range(4):
		var string = strings[i]
		movement_values[i] = int(Input.is_action_pressed(string))
	
	movement_axes = Vector2(-1 * movement_values[direction.up] + movement_values[direction.down], -1 * movement_values[direction.left] + movement_values[direction.right])
	
	if movement_axes[0] == 1:
		facing = direction.right
	elif movement_axes[0] == -1:
		facing = direction.left
	
	$Sprite2D.flip_h = facing
		
	for i in range(len(selections)):
		if i != selected:
			selections[i].visible = false
	if selected == selection.none:
		""
	elif selected == selection.hammer:
		process_hammer()
	elif selected == selection.pogo:
		process_pogo()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		last_valid_jump = 0
	else:
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
		velocity.y -= jump_force_per_frame
	move_and_slide()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass
