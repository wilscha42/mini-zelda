extends Node

var player: Link = null

@onready var _player_health_bar := $HUD/PlayerHealthBar

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Link
	
	_player_health_bar.max_health = 12
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	
	_player_health_bar.health = player.health


func _on_player_health_changed(health: int) -> void:
	_player_health_bar.health = health

func _on_player_died() -> void:
	# TODO: Handle player death better.
	player.health = 12
