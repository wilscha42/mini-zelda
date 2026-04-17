extends Liftable

const DAMAGE_THREASHOLD = Vector2(20, 20)
const SHATTER_THREASHOLD = Vector2(100, 250)
const KNOCKBACK_MULTIPLIER = 200.0

@export var throw_damage: int = 1

@onready var _hitbox = $Sprite2D/Hitbox
@onready var _anim = $AnimationPlayer

var _previous_velocity := Vector2.ZERO


func _physics_process(_delta: float) -> void:
	_previous_velocity = linear_velocity
	
	_hitbox.enabled = Util.any_component_greater(
			linear_velocity.abs(), DAMAGE_THREASHOLD
	)


func shatter():
	queue_free()


func _on_hitbox_hit_landed(receiver: Hurtbox) -> void:
	var dir = global_position.direction_to(receiver.global_position)
	receiver.hit(throw_damage, dir * KNOCKBACK_MULTIPLIER)
	
	_anim.play("shatter")


func _on_hurt_box_received_hit(_damage: int, _knockback: Vector2) -> void:
	_anim.play("shatter")


func _on_body_entered(_body: Node) -> void:
	if Util.any_component_greater(_previous_velocity.abs(), SHATTER_THREASHOLD):
		_anim.play("shatter")
