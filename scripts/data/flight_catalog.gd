class_name FlightCatalog
extends RefCounted
const UPGRADES := [
	preload("res://resources/upgrades/cabrito.tres"),
	preload("res://resources/upgrades/facetime.tres"),
	preload("res://resources/upgrades/appointment.tres"),
	preload("res://resources/upgrades/flights.tres"),
	preload("res://resources/upgrades/love.tres"),
	preload("res://resources/upgrades/playlist.tres"),
	preload("res://resources/upgrades/tips.tres"),
	preload("res://resources/upgrades/jar.tres"),
	preload("res://resources/upgrades/team.tres"),
]
const RELICS := [
	preload("res://resources/relics/hoodie.tres"),
	preload("res://resources/relics/unlimited.tres"),
	preload("res://resources/relics/kiss.tres"),
	preload("res://resources/relics/passport.tres"),
	preload("res://resources/relics/bracelet.tres"),
	preload("res://resources/relics/postcard.tres"),
]
const EVENTS := [
	preload("res://resources/events/cancelled.tres"),
	preload("res://resources/events/gift.tres"),
	preload("res://resources/events/call.tres"),
	preload("res://resources/events/sale.tres"),
	preload("res://resources/events/repair.tres"),
	preload("res://resources/events/viral.tres"),
	preload("res://resources/events/dinner.tres"),
	preload("res://resources/events/rain.tres"),
]
static func find_item(items: Array, id: String) -> FlightDefinition:
	for item: FlightDefinition in items:
		if item.id == id:
			return item
	return null
