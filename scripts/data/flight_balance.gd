class_name FlightBalance
extends Resource
@export var shift_seconds: float = 15.0
@export var click_income: float = 5.0
@export var chapter_income: PackedFloat32Array = [1.0, 2.0, 3.5]
@export var goals: PackedFloat32Array = [2100.0, 5300.0, 11000.0]
@export var price_scale: PackedFloat32Array = [1.0, 2.0, 3.5]
@export var event_interval: int = 3
@export_range(0.0, 1.0) var event_probability: float = 0.4
@export var combo_window: float = 0.6
@export var max_shift_extension: float = 9.0
