extends CharacterBody2D

@export var default_gravity = 200
@export var reduced_gravity = 170
@export var speed = 100
@export var friction = 0.9

var selections
enum selection {none, hammer, pogo}
var selected = selection.pogo

var gravity = default_gravity

var last_valid_jump: int = 10
var jump_frames = 6

var pogo_data = {
	"time_since_attack_idle": 0,
	"time_since_big_attack": 0
}

var hammer_data = {
	"spin_cycle": 0,
	
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selections = [$none, $hammer, $pogo]
	
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
	if Input.is_action_pressed("activate_hammer"):
		print("hammer")

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
