extends Node2D

const CARD: PackedScene = preload("res://card.tscn")
const CLUE: PackedScene = preload("res://clue_tile.tscn")
const TILE: PackedScene = preload("res://card_tile.tscn")
const HAND_LOGIC = preload("res://scripts/hand_logic.gd")
var card_held: Node
var layout: Array
var all_hands: Array
var width = 6
var height = 6
var board: Array = []
var board_offset = Vector2(100, 100)
var card_offset = Vector2(380, 450)

func _ready() -> void:
	load_level()
	for i in height:
		board.append([])
		for j in width:
			board[i].append(null)
	var current_clue = 0
	for i in height:
		for j in width:
			match layout[i][j]:
				"v", ">", "^", "<":
					var clue = CLUE.instantiate()
					clue.position = board_offset + Vector2(50 * j, 50 * i)
					#clue.hand_type = HAND_LOGIC.HAND_LIST.pick_random()
					clue.hand_type = all_hands[current_clue]
					current_clue += 1
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
					board[i][j] = tile
					add_child(tile)
	for i in len(HAND_LOGIC.SUITS):
		for j in len(HAND_LOGIC.VALUES):	
			var card = CARD.instantiate()
			card.suit = HAND_LOGIC.SUITS[i]
			card.value = HAND_LOGIC.VALUES[j]
			card.position = card_offset + Vector2(60 * j, 55 * i)
			card.connect("clicked_on", move_card_to_the_top)
			card.connect("released", release_card)
			add_child(card)
	#check_clues()

func _process(delta: float) -> void:
	check_clues()

func move_card_to_the_top(card: Node) -> void:
	if card_held == null:
		card_held = card
		move_child(card, -1)

func move_card_to_the_bottom(card: Node) -> void:
	move_child(card, 1)
	
func release_card() -> void:
	card_held = null
	
func give_card_to_tile(tile: Node) -> void:
	tile.card_held = card_held
	card_held = null

func check_clues() -> void:
	var finished = true
	for i in height:
		for j in width:
			if layout[i][j] in ["v", ">", "^", "<"]:
				if not check_clue(i, j):
					finished = false
	var complete_node = $Complete
	complete_node.visible = finished

func check_clue(i: int, j: int) -> bool:
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
			return false
		card_list.append(board[current.x][current.y].card_held)
		current += directions[layout[i][j]]
	var counts = HAND_LOGIC.card_counts(card_list)
	var final_hand = HAND_LOGIC.hand_calculation(counts)
	if final_hand == board[i][j].hand_type:
		board[i][j].solved = "correct"
	else:
		board[i][j].solved = "wrong"
	return final_hand == board[i][j].hand_type
	
func print_board() -> void:
	for i in height:
		for j in width:
			if layout[i][j] == "#":
				if board[i][j].card_held:
					print("%s-%s" % [board[i][j].card_held.value, board[i][j].card_held.suit])
				else:
					print("X-X")
		print()

func load_level() -> void:
	var level_file = FileAccess.open("res://board.txt", FileAccess.READ)
	var level_data = level_file.get_as_text().split("\n")
	var current_line = 0
	while level_data[current_line]:
		layout.append(level_data[current_line])
		current_line += 1
	width = len(layout[0])
	height = current_line
	#print(width, height)
	current_line += 1
	while current_line < len(level_data):
		all_hands.append(level_data[current_line])
		current_line += 1
