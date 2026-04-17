@tool
class_name HeartSymbol
extends TextureRect
## Helper Node for [PlayerHealthBar].
##
## Allows displaying one of five heart states (full, three-quarter, half, 
## quarter and empty).

const TEXTURE_HEART_FULL = preload(
		"res://ui/hud/player_health_bar/heart_symbol_full.png"
)
const TEXTURE_HEART_THREEQUARTER = preload(
		"res://ui/hud/player_health_bar/heart_symbol_threequarter.png"
)
const TEXTURE_HEART_HALF = preload(
		"res://ui/hud/player_health_bar/heart_symbol_half.png"
)
const TEXTURE_HEART_QUARTER = preload(
		"res://ui/hud/player_health_bar/heart_symbol_quarter.png"
)
const TEXTURE_HEART_EMPTY = preload(
		"res://ui/hud/player_health_bar/heart_symbol_empty.png"
)

## Given an integer ranging from [code]0[/code] to [code]4[/code], the 
## respective texture is loaded, where [code]0[/code] represents an empty and
## [code]4[/code] a full heart.
@export var fill_grade: int = 0: 
	set(value):
		value = clamp(value, 0, 4)
		fill_grade = value
		
		match fill_grade:
			0:
				texture = TEXTURE_HEART_EMPTY
			1:
				texture = TEXTURE_HEART_QUARTER
			2:
				texture = TEXTURE_HEART_HALF
			3:
				texture = TEXTURE_HEART_THREEQUARTER
			4:
				texture = TEXTURE_HEART_FULL
