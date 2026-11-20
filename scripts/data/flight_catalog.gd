class_name FlightCatalog
extends RefCounted
const UPGRADES := [
	preload("res://resources/upgrades/cabrito_power.tres"),
	preload("res://resources/upgrades/facetime_date.tres"),
	preload("res://resources/upgrades/gringo_influence.tres"),
	preload("res://resources/upgrades/volaris_red_eye.tres"),
	preload("res://resources/upgrades/nicky_mode.tres"),
	preload("res://resources/upgrades/norteno_playlist.tres"),
	preload("res://resources/upgrades/one_wish_willow.tres"),
	preload("res://resources/upgrades/passive_income_princess.tres"),
	preload("res://resources/upgrades/well_rested.tres"),
]
const RELICS := [
	preload("res://resources/relics/hoodie.tres"),
	preload("res://resources/relics/unlimited.tres"),
	preload("res://resources/relics/kiss.tres"),
	preload("res://resources/relics/passport.tres"),
	preload("res://resources/relics/bracelet.tres"),
	preload("res://resources/relics/postcard.tres"),
]

static func find_item(items: Array, id: String) -> FlightDefinition:
	for item: FlightDefinition in items:
		if item.id == id:
			return item
	return null
