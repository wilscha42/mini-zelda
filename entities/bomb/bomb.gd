class_name Bomb
extends Liftable

const KNOCKBACK_COOLDOWN = 0.5
const ExplosionScene = preload("res://entities/explosion/explosion.tscn")

@onready var _knockback_cooldown_timer = $KnockbackCooldownTimer
@onready var _anim = $AnimationPlayer


func _on_hurtbox_received_hit(_damage: int, knockback: Vector2) -> void:
	if _knockback_cooldown_timer.time_left == 0:
		apply_impulse(knockback)
		_knockback_cooldown_timer.start(KNOCKBACK_COOLDOWN)
		
		ignite()


func ignite() -> void:
	_anim.play("ignite")


func explode() -> void:
	var explosion = ExplosionScene.instantiate()
	explosion.global_position = global_position
	inital_parent.add_child.call_deferred(explosion)
	
	queue_free()


func _on_hitbox_hit_landed(_receiver: Hurtbox) -> void:
	explode()
