class_name Liftable
extends RigidBody2D

var inital_parent: Node2D = null

func _ready() -> void:
	inital_parent = get_parent()

func lift(binded_node: Node2D) -> void:
	inital_parent = get_parent()
	inital_parent.remove_child(self)
	
	freeze = true
	position = Vector2.ZERO
	
	binded_node.add_child(self)


func unlift() -> void:
	var binded_node = get_parent()
	binded_node.remove_child(self)
	
	position = binded_node.global_position
	freeze = false
	
	inital_parent.add_child.call_deferred(self)
