@tool
class_name PlayerHealthBar
extends Control
## Health bar designed for the HUD, displayed in hearts.

const HeartSymbolScene := preload(
		"res://ui/hud/player_health_bar/heart_symbol.tscn"
)

## Health to be displayed as filled, measured in quarter-hearts.
@export var health: int:
	set(value):
		value = clamp(0, value, max_health)
		health = value
		
		_update_heart_symbols()
## Maximum health, measured in quarter-hearts. Values that are not a
## multiple of 4 will result in a heart that can't be fully filled.
@export var max_health: int:
	set(value):
		value = max(0, value)
		max_health = value
		
		health = min(health, max_health)
		
		_update_heart_symbols()


func _update_heart_symbols() -> void:
	for heart_symbol in get_children():
		heart_symbol.queue_free()
	
	# Max Health values that are not a multiple of 4 still need a full heart
	# to be displayed. 
	var heart_count = ceil(max_health / 4.0)
	for i in range(heart_count):
		var heart_symbol = HeartSymbolScene.instantiate()
		heart_symbol.fill_grade = clamp(health - i * 4, 0, 4)
		add_child(heart_symbol)
