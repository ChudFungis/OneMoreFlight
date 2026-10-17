class_name FlightDefinition
extends Resource
## Shared editable content record. Effect names are handled explicitly by GameManager.
@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var effect: String = ""
@export var amount: float = 0.0
@export var max_level: int = 0 # Zero denotes an unlimited-level ability.
@export var choice: String = "Accept outcome"
@export var price: float = 0.0
@export var negative: bool = false
@export var alternative: String = ""
@export var alternative_effect: String = ""
@export var alternative_amount: float = 0.0
@export var icon: Texture2D
