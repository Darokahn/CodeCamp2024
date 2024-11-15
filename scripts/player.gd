extends Node2D

var body: CharacterBody2D
var hammer: CollisionObject2D
var onGround: bool
var respectsGravity: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = $CharacterBody2D
	hammer = $Area2D
	onGround = false
	respectsGravity = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		body.velocity.x += 200 * delta
	if Input.is_action_pressed("move_left"):
		body.velocity.x -= 200 * delta
	if Input.is_action_just_pressed("move_up"):
		body.velocity.y -= 20000 * delta
	if Input.is_action_pressed("move_down"):
		body.velocity.y += 200 * delta
	
	body.position += body.velocity * delta
	
	body.velocity *= Globals.AIR_FRICTION
	if onGround:
		body.velocity *= Globals.GROUND_FRICTION
	if respectsGravity:
		body.velocity.y += Globals.GRAVITY * delta
	
		
