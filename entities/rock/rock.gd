extends Liftable

const DAMAGE_THREASHOLD = Vector2(20, 20)
const KNOCKBACK_MULTIPLIER = 200.0

@export var throw_damage: int = 1

@onready var _hitbox = $Sprite2D/Hitbox


func _physics_process(_delta: float) -> void:
	_hitbox.enabled = Util.any_component_greater(
			linear_velocity.abs(), DAMAGE_THREASHOLD
	)


func _on_hitbox_hit_landed(receiver: Hurtbox) -> void:
	var dir = global_position.direction_to(receiver.global_position)
	receiver.hit(throw_damage, dir * KNOCKBACK_MULTIPLIER)
