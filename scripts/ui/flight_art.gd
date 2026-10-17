class_name FlightArt
extends RefCounted
## Stable paths: custom texture > PNG > WebP > shipped SVG > shared fallback.
static func texture(folder: String, id: String, explicit: Texture2D = null) -> Texture2D:
	if explicit != null:
		return explicit
	for extension: String in ["png", "webp", "svg"]:
		var path := "res://assets/art/%s/%s.%s" % [folder, id, extension]
		if ResourceLoader.exists(path):
			return load(path) as Texture2D
	return preload("res://assets/art/icon_placeholder.svg")

static func image(folder: String, id: String, explicit: Texture2D = null) -> TextureRect:
	var node := TextureRect.new()
	node.texture = texture(folder, id, explicit)
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if folder == "heart" else CanvasItem.TEXTURE_FILTER_LINEAR
	return node
