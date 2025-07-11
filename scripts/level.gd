extends Node2D

const CARD: PackedScene = preload("res://card.tscn")
const CLUE: PackedScene = preload("res://clue_tile.tscn")
const TILE: PackedScene = preload("res://card_tile.tscn")
const HAND_LOGIC = preload("res://scripts/hand_logic.gd")
var card_held: Node
var all_cards: Array
var all_tiles: Array
var layout = [".vvvvv", ">#####", ">#####", ">#####", ">#####", ">#####",]
var width = 6
var height = 6
var board = []
var board_offset = Vector2(100, 100)

func _ready() -> void:
	for i in height:
		board.append([])
		for j in width:
			board[i].append(null)
	for i in height:
		for j in width:
			match layout[i][j]:
				"v", ">", "^", "<":
					var clue = CLUE.instantiate()
					clue.position = board_offset + Vector2(50 * j, 50 * i)
					clue.hand_type = HAND_LOGIC.HAND_LIST.pick_random()
					var directions = {
						"v": "down",
						">": "right",
						"^": "up",
						"<": "left"
					}
					clue.direction = directions[layout[i][j]]
					board[i][j] = clue
					add_child(clue)
				"#":
					var tile = TILE.instantiate()
					tile.position = board_offset + Vector2(50 * j, 50 * i)
					tile.connect("request_card", give_card_to_tile)
					tile.connect("released_on", move_card_to_the_bottom)
					all_tiles.append(tile)
					board[i][j] = tile
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
	check_clues()
	#print(card_held)
	if Input.is_action_just_pressed("ui_click"):
		print_board()

func move_card_to_the_top(card: Node) -> void:
	if card_held == null:
		card_held = card
		move_child(card, -1)

func release_card() -> void:
	card_held = null
	
func move_card_to_the_bottom(card: Node) -> void:
	move_child(card, 0)
	
func give_card_to_tile(tile: Node) -> void:
	tile.card_held = card_held
	card_held = null

func check_clues() -> void:
	for i in height:
		for j in width:
			if layout[i][j] in ["v", ">", "^", "<"]:
				check_clue(i, j)

func check_clue(i: int, j: int):
	var directions = {
		"v": Vector2(1, 0),
		">": Vector2(0, 1),
		"^": Vector2(-1, 0),
		"<": Vector2(0, -1)
	}
	var current = Vector2(i, j)
	var card_list = []
	current += directions[layout[i][j]]
	while 0 <= current.x and current.x < height \
		and 0 <= current.y and current.y < width \
		and layout[current.x][current.y] == "#":
		if not board[current.x][current.y].card_held:
			board[i][j].solved = "incomplete"
			return
		card_list.append(board[current.x][current.y].card_held)
		current += directions[layout[i][j]]
	var counts = HAND_LOGIC.card_counts(card_list)
	var final_hand = HAND_LOGIC.hand_calculation(counts)
	if final_hand == board[i][j].hand_type:
		board[i][j].solved = "correct"
	else:
		board[i][j].solved = "wrong"

func print_board():
	for i in height:
		for j in width:
			if layout[i][j] == "#":
				if board[i][j].card_held:
					print("%s-%s" % [board[i][j].card_held.value, board[i][j].card_held.suit])
				else:
					print("X-X")
		print()
