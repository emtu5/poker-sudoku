extends Node2D

const CARD: PackedScene = preload("res://card.tscn")
const CLUE: PackedScene = preload("res://clue_tile.tscn")
const TILE: PackedScene = preload("res://card_tile.tscn")
const HAND_LOGIC = preload("res://scripts/hand_logic.gd")
var card_held: Node
var all_cards: Array
var all_tiles: Array
var layout = [".vvvvv", ">#####", ">#####", ">#####", ">#####", ">#####",]
var board = []
var board_offset = Vector2(100, 100)

func _ready() -> void:
	for i in range(6):
		board.append([])
		for j in range(6):
			board[i].append(null)
	for i in range(6):
		for j in range(6):
			match layout[i][j]:
				"v", ">", "^", "<":
					var clue = CLUE.instantiate()
					clue.position = board_offset + Vector2(50 * j, 50 * i)
					add_child(clue)
				"#":
					var tile = TILE.instantiate()
					tile.position = board_offset + Vector2(50 * j, 50 * i)
					tile.connect("request_card", give_card_to_tile)
					tile.connect("released_on", move_card_to_the_bottom)
					all_tiles.append(tile)
					add_child(tile)
	for s in HAND_LOGIC.SUITS:
		for v in HAND_LOGIC.VALUES:	
			var card = CARD.instantiate()
			card.suit = s
			card.value = v
			card.position = Vector2(randi_range(100, 1100), randi_range(500, 600))
			card.connect("clicked_on", move_card_to_the_top)
			card.connect("released", release_card)
			all_cards.append(card)
			add_child(card)

func _process(delta: float) -> void:
	print(card_held)
	#if Input.is_action_just_pressed("ui_click") and card_held:
		#card_held = null
func move_card_to_the_top(card: Node) -> void:
	card_held = card
	move_child(card, -1)

func release_card() -> void:
	card_held = null
	
func move_card_to_the_bottom(card: Node) -> void:
	move_child(card, 0)
	
func give_card_to_tile(tile: Node) -> void:
	tile.card_held = card_held
