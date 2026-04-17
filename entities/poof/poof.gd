class_name Poof
extends Node2D

@onready var _anim = $AnimationPlayer


func _ready() -> void:
	_anim.play("poof")
