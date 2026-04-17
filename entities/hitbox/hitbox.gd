@tool
class_name Hitbox
extends Area2D

signal hit_landed(receiver: Hurtbox)

const HITBOX_COLLISION_SHAPE_DEBUG_COLOR = Color(1.0, 0.3, 0.2, 0.42)

# For consistency and intuitiveness with Hurtbox.
@export var enabled := true:
	set(value):
		enabled = value
		
		for child in get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.set_deferred("disabled", not enabled)


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	for child in get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.debug_color = HITBOX_COLLISION_SHAPE_DEBUG_COLOR


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		# For a Hitbox to ignore a Hurtbox, they must be siblings.
		# So the Hitbox of e.g. a character can't hurt its own Hurtbox. 
		if area.get_parent() != get_parent():
			hit_landed.emit(area)
