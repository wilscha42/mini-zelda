@tool
class_name Hurtbox
extends Area2D

signal received_hit(damage: int, knockback: Vector2)

const HURTBOX_COLLISION_SHAPE_DEBUG_COLOR = Color(0.4, 1.0, 0.4, 0.42)

# Setting monitorable to true while inside an Area2D will not fire another
# area_entered signal, changing disabled to false, however, does.
@export var enabled := true:
	set(value):
		enabled = value
		
		for child in get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.set_deferred("disabled", not enabled)


func _ready() -> void:
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.debug_color = HURTBOX_COLLISION_SHAPE_DEBUG_COLOR


func hit(damage: int, knockback: Vector2) -> void:
	received_hit.emit(damage, knockback)
