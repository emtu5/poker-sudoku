extends Node2D

signal clicked_on(card: Node2D)
signal released()

var value_node: Label
var suit_node: Sprite2D

var suit_textures: Dictionary = {
	"club": preload("res://assets/club.png"),
	"diamond": preload("res://assets/diamond.png"),
	"heart": preload("res://assets/heart.png"),
	"spade": preload("res://assets/spade.png")
}

var value: String:
	set(val):
		value_node = $Value
		value = val
		if suit in ["heart", "diamond"]:
			value_node.set("theme_override_colors/font_color", Color(1, 0, 0, 1))
		value_node.text = value
		
var suit: String:
	set(sut):
		suit_node = $Suit
		suit = sut
		suit_node.texture = suit_textures[suit]

var card_held: bool = false

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("ui_click"):
		card_held = not card_held
		if card_held:
			clicked_on.emit(self)
		else:
			await get_tree().create_timer(0.001).timeout
			released.emit()

func _process(delta: float) -> void:
	if card_held:
		self.position = get_global_mouse_position()
