extends Node

const VALUES = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
const SUITS = ["club", "diamond", "heart", "spade"]
const HAND_LIST = [
	"high_card",
	"pair",
	"two_pair",
	"three_of_a_kind",
	"straight",
	"flush",
	"full_house",
	"four_of_a_kind",
	"straight_flush"
]

static func card_counts(card_list: Array) -> Dictionary:
	var counts: Dictionary = {
		"value": {},
		"suit": {}
	}
	for v in VALUES:
		counts.value[v] = 0
	for s in SUITS:
		counts.suit[s] = 0
	for card in card_list:
		counts.value[card.value] += 1
		counts.suit[card.suit] += 1
	return counts

static func hand_calculation(counts: Dictionary) -> String:
	var flush: bool = false
	var straight: bool = false
	
	# flush check
	var empty_suits: int = 0
	for s in SUITS:
		if counts.suit[s] == 0:
			empty_suits += 1
	flush = empty_suits == 3
	
	# straight check
	var compressed: Array = []
	compressed.append(counts.value["2"])
	for v in VALUES:
		#print(v)
		if counts.value[v] != compressed[-1]:
			compressed.append(counts.value[v])
	straight = compressed in [[0, 1], [0, 1, 0], [1, 0]]
	if compressed == [1, 0, 1] and counts.value["K"] == 0:
		straight = true
		
	if straight and flush:
		return "straight_flush"
	
	if 4 in counts.value.values():
		return "four_of_a_kind"
	if 3 in counts.value.values() and 2 in counts.value.values():
		return "full_house"
	if flush:
		return "flush"
	if straight:
		return "straight"
	if 3 in counts.value.values():
		return "three_of_a_kind"
	if counts.value.values().count(2) == 2:
		return "two_pair"
	if 2 in counts.value.values():
		return "pair"
	return "high_card"
