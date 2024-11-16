extends CharacterBody2D

@export var default_gravity = 200
@export var reduced_gravity = 170
@export var speed = 100
@export var friction = 0.9

var selections
enum selection {none, hammer, pogo}
var selected = selection.hammer

var gravity = default_gravity

var last_valid_jump: int = 10
var jump_frames = 6
enum direction {left, right}
var facing: direction = direction.left

var pogo_data = {
	"time_since_attack_idle": 0,
	"time_since_big_attack": 0
}

var hammer_data = {
	"total_steps": 8,
	"spin_progress": 8,
	"spin_frames": [],
	"default_position": Vector2()
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selections = [$none, $hammer, $pogo]
	var swing_distance = 100
	for i in range(8):
		var angle = (float(i)/hammer_data["total_steps"]) * (2 * PI)
		hammer_data["spin_frames"].append(Vector2(cos(angle) * swing_distance, sin(angle) * swing_distance))
	hammer_data["default_position"] = Vector2(0, 50)

func big_pogo(launch_direction, highest_hit):
	velocity += launch_direction * (3000 * highest_hit)

func process_pogo():
	var attack_direction = Vector2(Input.get_axis("arrow_left", "arrow_right"), Input.get_axis("arrow_up", "arrow_down"))
	
	$pogo.position = attack_direction * 100
	
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
	var delay_scale = 10

	if Input.is_action_pressed("activate_hammer"):
		hammer_data["spin_progress"] = (hammer_data["spin_progress"] + 1) % (hammer_data["total_steps"] * delay_scale)
		if facing == direction.left:
			hammer_data["spin_progra"] = hammer_data["total_steps"] - hammer_data
		$hammer.position = hammer_data["spin_frames"][hammer_data["spin_progress"] / delay_scale]
		print($hammer.position)
		
	else:
		hammer_data["spin_progress"] = 0
		$hammer.position = hammer_data["default_position"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
		velocity.y -= 700
	move_and_slide()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass
