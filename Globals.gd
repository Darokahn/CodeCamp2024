extends Node

var AIR_FRICTION = 0.99
var GROUND_FRICTION = 0.95
var GRAVITY = 1000
var dummy_corpse = preload("res://scenes/corpse.tscn")

func kill(obj: Node2D):
	var new_corpse = dummy_corpse.instantiate()
	var parent = obj.get_parent()
	new_corpse.position = obj.position
	parent.add_child(new_corpse)
	obj.reparent(new_corpse)
	var death_vector = Vector2((randi() % 400) - 200, - (randi() % 200) - 50)
	var offset = Vector2((randi() % 10) - 5, (randi() % 10) - 5)
	new_corpse.apply_impulse(death_vector, offset)
	obj.set_collision_mask_value(1, false)
	obj.set_collision_mask_value(2, false)
	obj.set_collision_layer_value(1, false)
	obj.set_collision_layer_value(2, false)
	
