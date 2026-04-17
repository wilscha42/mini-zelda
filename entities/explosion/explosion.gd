class_name Explosion
extends Node2D

const KNOCKBACK_FACTOR = 400.0

@export var damage: int = 2

@onready var _anim = $AnimationPlayer


func _ready() -> void:
	_anim.play("explode")


func _on_hitbox_hit_landed(receiver: Hurtbox) -> void:
	var dir = global_position.direction_to(receiver.global_position)
	var knockback = dir * KNOCKBACK_FACTOR
	
	receiver.hit(damage, knockback)
