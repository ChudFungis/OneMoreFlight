class_name FlightBalance
extends Resource
@export var shift_seconds: float = 10.0
@export var click_income: float = 5.0
@export var chapter_income: PackedFloat32Array = [1.0, 2.0, 3.5]
@export var goals: PackedFloat32Array = [2100.0, 5300.0, 11000.0]
@export var price_scale: PackedFloat32Array = [1.0, 2.0, 3.5]
@export var event_interval: int = 3
@export var burst_cap: int = 60
@export var new_ability_weight: float = 0.65
@export var music_tap_interval: int = 50
@export var facetime_tap_interval: int = 10
@export var interest_level_step: float = 0.05
