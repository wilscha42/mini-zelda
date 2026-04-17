class_name Link
extends CharacterBody2D

signal health_changed(health: int)
signal died

const SPEED = 120.0
const GUARD_SPEED = 40.0
const CARRY_SPEED = 60.0
const JUMP_VELOCITY = -200.0
const ACCELERATION_GROUND = 120.0
const ACCELERATION_MIDAIR = 4.0
const ACCELERATION_ATTACK = 10.0
const ACCELERATION_HURT = 10.0
const ACCELERATION_GUARD = 60.0
const HURT_INVINCABILITY_DURATION = 1.0
const GUARD_COOLDOWN_DURATION = 1.0
const DROP_MIN_VELOCITY = Vector2(50.0, -100.0)
const THROW_HORIZ_VELOCITY_FACTOR = 3.0
const BLOCKING_ANIMATIONS = [
	"attack",
	"hurt",
	"guard_block",
	"drop",
	"throw",
]
const BombScene = preload("res://entities/bomb/bomb.tscn")

@export var health: int = 12:
	set(value):
		health = value
		health_changed.emit(value)
		
		if health <= 0:
			died.emit()
@export var attack_damage: int = 1
# Knockback value whose x component directed accordinly to _facing.
@export var attack_knockback := Vector2(200.0, -100.0)
# Knockback value whose x component directed accordinly to _facing.
@export var guard_knockback := Vector2(100.0, -100.0)
@export var controllable := true

# Direction the player faces in horizontally. By default right, so 1.
var _facing: int = 1
var _guarding := false
var _carrying: bool:
	get():
		return _carried_liftable != null
var _carried_liftable: Liftable = null

@onready var _sprite := $Sprite
@onready var _anim := $AnimationPlayer
@onready var _hurtbox := $Sprite/HurtBox
@onready var _interact_area := $Sprite/InteractArea
@onready var _carried_container := $Sprite/CarriedContainer
@onready var _invincibality_timer := $InvincabilityTimer
@onready var _guard_cooldown_timer := $GuardCooldownTimer


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if (
			Input.is_action_just_pressed("jump") 
			and is_on_floor()
			and controllable
			and (not _anim.current_animation == "hurt")
	):
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("move_left", "move_right")
	if (not controllable) or _anim.current_animation == "hurt":
		direction = 0.0
	
	if direction and is_on_floor() and not _guarding:
		_facing = int(direction)
	
	if (
			Input.is_action_just_pressed("attack") 
			and not _anim.current_animation in ["attack", "guard_block"]
			and not _guarding
			and not _carrying
	):
		_anim.play("attack")
	
	_guarding = (
			Input.is_action_pressed("guard") 
			and not _carrying
			and _anim.current_animation != "guard_block"
			and _guard_cooldown_timer.time_left == 0
	)
	
	if Input.is_action_just_pressed("carry") and not _anim.current_animation in BLOCKING_ANIMATIONS:
		if _carrying:
			_anim.play("drop")
		else:
			for body in _interact_area.get_overlapping_bodies():
				if body is Liftable:
					carry(body)
					break
	
	if Input.is_action_just_pressed("bomb") and not _anim.current_animation in BLOCKING_ANIMATIONS and not _carrying:
		var bomb = BombScene.instantiate()
		get_parent().add_child(bomb)
		carry(bomb)
		bomb.ignite()
	
	if Input.is_action_just_pressed("throw") and _carrying:
		_anim.play("throw")
	
	var acceleration = (
			ACCELERATION_MIDAIR if not is_on_floor()
			else ACCELERATION_ATTACK if _anim.current_animation == "attack"
			else ACCELERATION_HURT if _anim.current_animation == "hurt"
			else ACCELERATION_GUARD if _guarding
			else ACCELERATION_GROUND
	)
	
	var speed = (
			GUARD_SPEED if _guarding
			else CARRY_SPEED if _carried_liftable
			else SPEED
	)
	
	velocity.x = move_toward(velocity.x, speed * direction, acceleration)
	
	move_and_slide()
	
	_hurtbox.enabled = _invincibality_timer.time_left == 0
	_sprite.material.set(
			"shader_parameter/enabled", _invincibality_timer.time_left > 0
			# TODO: This is a little inelegant. Add a better way to 
			# differiantiate between hurt and attack invincablity blinking. 
			and _anim.current_animation != "attack"
	)
	
	if _anim.current_animation != "attack":
		# Flip the sprite AND its children horizontally.
		_sprite.scale.x = _facing
		# The carried item should not be affected be that though.
		_carried_container.scale.x = _facing
	
	# Looping, stateful animations.
	if not _anim.current_animation in BLOCKING_ANIMATIONS:
		if _guarding:
			if velocity.x != 0:
				_anim.play("guard_move")
			else:
				_anim.play("guard")
		elif _carried_liftable:
			if is_on_floor():
				if velocity.x != 0:
					_anim.play("carry_move")
				else:
					_anim.play("carry")
			else:
				_anim.play("carry_fall")
		else:
			if is_on_floor():
				if velocity.x != 0:
					_anim.play("run")
				else:
					_anim.play("idle")
			else:
				if velocity.y < 0:
					_anim.play("jump")
				else:
					_anim.play("fall")


func carry(liftable: Liftable) -> void:
	liftable.lift(_carried_container)
	
	_carried_liftable = liftable


func drop_carried() -> void:
	_carried_liftable.unlift()
	_carried_liftable.apply_impulse(
			DROP_MIN_VELOCITY * Vector2(_facing, 1) + velocity
	)
	
	_carried_liftable = null


func throw_carried() -> void:
	if not _carried_liftable:
		return
	
	_carried_liftable.unlift()
	_carried_liftable.apply_impulse(
			DROP_MIN_VELOCITY
			* Vector2(_facing * THROW_HORIZ_VELOCITY_FACTOR, 1) 
			+ velocity 
	)
	
	_carried_liftable = null


func _on_sword_hit_landed(receiver: Hurtbox) -> void:
	var knockback = attack_knockback * Vector2(_facing, 1.0)
	receiver.hit(attack_damage, knockback)


func _on_shield_hit_landed(receiver: Hurtbox) -> void:
	var knockback = guard_knockback * Vector2(_facing, 1.0)
	receiver.hit(0, knockback)


func _on_hurt_box_received_hit(damage: int, knockback: Vector2) -> void:
	velocity = knockback
	# Only blocks when guarding against knockback direction.
	if _guarding and sign(knockback.x) + _facing == 0:
		_anim.play("guard_block")
		_guard_cooldown_timer.start(GUARD_COOLDOWN_DURATION)
	else:
		health -= damage
		_anim.play("hurt")
		_invincibality_timer.start(HURT_INVINCABILITY_DURATION)
		
		if _carrying:
			drop_carried()
