extends Node2D

signal request_card(tile: Node2D)
signal released_on(card: Node2D)

var card_held: Node:
	set(card):
		card_held = card
		if card_held:
			card_held.position = self.position
			released_on.emit(card_held)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("ui_click"):
		if not card_held:
			request_card.emit(self)
		else:
			card_held = null
