extends CharacterBody2D

@export var default_gravity = 50
@export var reduced_gravity = 40
@export var speed = 20
@export var friction = 0.9

var player
var prop = preload("res://scenes/debug.tscn")

var selections
enum selection {none, hammer, pogo}
var selected = selection.hammer

var gravity = default_gravity

var movement_values = Vector4()
var movement_axes = Vector2()

var last_valid_jump: int = 10
var jump_frames = 10
enum direction {left, right, up, down}
var facing: direction = direction.left
var time_since_on_ground = 0
var jump_force_per_frame = 100
var jump_inertia = 0

var initial_position

var jump_data = {
	"jump_frames": 8,
	"last_valid_jump": 10,
	"force": 150,
	"jump_acceleration": 0
}

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
	"swing_distance": 20,
	"launch_scale": 1000,
	"spin_speed_scale": 2
}

var animation_state = "default"

func spawn_debug():
	var debug = prop.instantiate()
	debug.position = position
	get_parent().add_child(debug)

func _ready() -> void:
	initial_position = position
	selections = [$none, $hammer, $pogo]
	var swing_distance = hammer_data["swing_distance"]
	for i in range(8):
		var angle = (float(i)/hammer_data["total_steps"]) * (2 * PI)
		hammer_data["spin_frames"].append(Vector2(cos(angle) * swing_distance, sin(angle) * swing_distance))
	hammer_data["last_position"] = hammer_data["spin_frames"][0]
	
func restart():
	position = initial_position

func launch_pogo(launch_direction, highest_hit):
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
			launch_pogo(launch_direction, highest_hit)
		pogo_data["time_since_attack_idle"] += 1
	else:
		pogo_data["time_since_attack_idle"] = 0
		
func launch_hammer(enemy_position):
	var launch_vector = (position - enemy_position).normalized()
	launch_vector *= hammer_data["launch_scale"]
	velocity += launch_vector

func process_hammer():
	var delay_scale = hammer_data["spin_speed_scale"]
	
	if Input.is_action_just_pressed("activate_hammer") and time_since_on_ground > 1:
		hammer_data["is_spinning"] = true
		$CollisionShape2D.scale = Vector2(0.1, 0.1)
	if Input.is_action_just_released("activate_hammer") or time_since_on_ground < 1:
		hammer_data["is_spinning"] = false
		$CollisionShape2D.scale = Vector2(0.5, 0.5)

	if hammer_data["is_spinning"]:
		for object in $hammer.get_overlapping_bodies():
			if "enemy" in object:
				launch_hammer(object.position)
				Globals.kill(object)
		hammer_data["spin_progress"] = (hammer_data["spin_progress"] + 1) % (hammer_data["total_steps"] * delay_scale)
		var spin_progress = hammer_data["spin_progress"]
		var int_step = spin_progress / delay_scale
		var spin_angle = (2 * PI) / hammer_data["total_steps"] * int_step
		if facing == direction.left:
			spin_angle *= -1
			spin_progress = (hammer_data["total_steps"] * delay_scale) - spin_progress - 1
		
		if int_step % 2 == 1:
			$Sprite2D.rotation = spin_angle
		
	else:
		$Sprite2D.rotation = 0
		hammer_data["spin_progress"] = 0
		$hammer.position = hammer_data["default_position"]

func process_animation():
	var past_state = animation_state
	var movement_threshold = 30
	var on_floor = is_on_floor()
	if on_floor:
		if velocity.length() < movement_threshold:
			animation_state = "default"
		elif abs(velocity.x) > movement_threshold and not is_on_wall():
			animation_state = "run"
	else:
		if hammer_data["is_spinning"]:
			animation_state = "roll"
		elif velocity.y > 0:
			animation_state = "fall"
		else:
			animation_state = "jump"
	if animation_state != past_state:
		$Sprite2D.play(animation_state)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch"):
		selected = (selected + 1) % 3
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
	
	process_animation()
	
	process_hammer()
		
	for i in range(len(selections)):
		selections[i].visible = i == selected
	if selected == selection.none:
		""
	
	elif selected == selection.pogo:
		process_pogo()

func _physics_process(delta: float) -> void:
	var x_movement = Input.get_axis("move_left", "move_right")
	if is_on_floor():
		jump_data["last_valid_jump"] = 0
		if Input.is_action_just_pressed("move_up"):
			jump_data["jump_acceleration"] = jump_data["force"]
	else:
		jump_data["last_valid_jump"] += 1
	if Input.is_action_pressed("move_up") and jump_data["last_valid_jump"] < jump_data["jump_frames"] and jump_data["jump_acceleration"] > 0:
		jump_data["jump_acceleration"] = jump_data["force"]
	elif jump_data["jump_acceleration"] > 0:
		jump_data["jump_acceleration"] -= 20
	velocity.y -= jump_data["jump_acceleration"]
	velocity.y += gravity
	velocity.x += x_movement * speed
	velocity *= friction
	move_and_slide()
		
	
	
	#if Input.is_action_just_pressed("move_up"):
		#if is_on_floor():
				## last_valid_jump keeps track of how long it's been since the player could organically jump.
				## As long as it has been less than jump_frames, the player can continue to to gain velocity
				## by holding jump.
				#last_valid_jump = 0
#
	#var x_movement = Input.get_axis("move_left", "move_right")
#
	#if Input.is_action_pressed("move_up"):
		#
		#gravity = reduced_gravity # player is slightly less affected by gravity while holding up
		#last_valid_jump += 1
		#if last_valid_jump < jump_frames:
			#velocity.y -= jump_force_per_frame
	#else:
		#gravity = default_gravity
	#
#
	#velocity.x += x_movement * speed
	#velocity.y += gravity 
	#velocity *= friction # reduce velocity so player stops moving eventually
#
	#move_and_slide()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass
