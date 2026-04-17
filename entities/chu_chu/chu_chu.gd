class_name ChuChu
extends CharacterBody2D

enum State {PATROL, CHASE}
enum PatrolState {WAIT, MOVE}

const PATROL_SPEED = 10.0
const CHASE_SPEED = 30.0
const PATROL_STATE_DURATION_MIN = 1.0
const PATROL_STATE_DURATION_MAX = 3.0
const ACCELERATION = 10.0
const ATTACK_COOLDOWN_DURATION = 1.5
const ATTACK_DISTANCE = 40.0
const FORGET_DISTANCE = 150.0
const ATTACK_VELOCITY = Vector2(200, -100)
const HITSTUN_DURATION = 0.5
const INVINCABILITY_DURATION = 0.2
const KNOCKBACK_MULTIPLIER = 200.0

@export var health: int = 3
@export var attack_damage: int = 1

var _state := State.PATROL
var _patrol_state := PatrolState.WAIT
var _facing: int = 1
var _target: Hurtbox = null

@onready var _anim := $AnimationPlayer
@onready var _sprite := $Sprite
@onready var _attack_cooldown_timer := $AttackCooldownTimer
@onready var _hitstun_timer := $HitstunTimer
@onready var _patrol_state_timer := $PatrolStateTimer


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var speed: float
	var direction: int
	
	if _state == State.PATROL:
		if _patrol_state_timer.time_left > 0:
			# Turn when on wall while moving.
			if _patrol_state == PatrolState.MOVE and is_on_wall():
				_facing *= -1
		else:
			_patrol_state = (
					PatrolState.WAIT if _patrol_state == PatrolState.MOVE
					else PatrolState.MOVE
			)
			
			var patrol_state_duration = randf_range(
					PATROL_STATE_DURATION_MIN, PATROL_STATE_DURATION_MAX
			)
			
			_patrol_state_timer.start(patrol_state_duration)
			
			# Change direction every now and then.
			if _patrol_state == PatrolState.MOVE and randi() % 2 == 0:
				_facing *= -1
		speed = PATROL_SPEED * int(_patrol_state == PatrolState.MOVE)
		direction = _facing
	elif _state == State.CHASE:
		var direction_to_target = global_position.direction_to(
				_target.global_position
		)
		
		var distance_to_target = global_position.distance_to(
				_target.global_position
		)
		
		speed = CHASE_SPEED
		direction = sign(direction_to_target.x)
		
		if distance_to_target <= ATTACK_DISTANCE:
			speed = 0
			
			if (
					_attack_cooldown_timer.time_left == 0 
					and _hitstun_timer.time_left == 0
			): 
				_anim.play("attack")
		
		if distance_to_target >= FORGET_DISTANCE:
			_state = State.PATROL
	
	if _hitstun_timer.time_left > 0:
		speed = 0
	
	velocity.x = move_toward(velocity.x, speed * direction, ACCELERATION)
	
	if direction:
		_facing = direction
	
	if _anim.current_animation != "die":
		move_and_slide()
	
	_sprite.scale.x = _facing
	
	if not _anim.current_animation in ["attack", "hurt", "die"]:
		if is_on_floor():
			if _state == State.PATROL:
				_anim.play("patrol")
			elif _state == State.CHASE:
				_anim.play("chase")
		else:
			_anim.play("jump")


func _on_detection_area_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		_target = area
		_state = State.CHASE


func attack() -> void:
	velocity = ATTACK_VELOCITY * Vector2(_facing, 1)
	_attack_cooldown_timer.start(ATTACK_COOLDOWN_DURATION)


func die() -> void:
	queue_free()


func _on_hitbox_hit_landed(receiver: Hurtbox) -> void:
	var dir = global_position.direction_to(receiver.global_position)
	receiver.hit(attack_damage, dir * KNOCKBACK_MULTIPLIER)


func _on_hurtbox_received_hit(damage: int, knockback: Vector2) -> void:
	health -= damage
	velocity = knockback
	
	# Turn around when hit, depending on knockback.
	if sign(knockback.x) == _facing:
		_facing *= -1
	
	if damage > 0:
		_anim.play("hurt")
	
	_hitstun_timer.start(HITSTUN_DURATION)
	
	if health <= 0:
		_anim.play("die")
