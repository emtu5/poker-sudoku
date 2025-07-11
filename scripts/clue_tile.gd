extends Node2D

var hand_node: Label
var arrow_node: Sprite2D

var short_hands: Dictionary = {
	"high_card": "HC",
	"pair": "P",
	"two_pair": "2P",
	"three_of_a_kind": "3OAK",
	"straight": "S",
	"flush": "F",
	"full_house": "FH",
	"four_of_a_kind": "4OAK",
	"straight_flush": "SF"
}

var hand_type: String:
	set(hand):
		hand_type = hand
		hand_node = $Hand
		hand_node.text = short_hands[hand_type]
		
var direction: String:
	set(dir):
		direction = dir
		arrow_node = $Arrow
		match direction:
			"down":
				arrow_node.rotation_degrees = 0
			"right":
				arrow_node.rotation_degrees = 90
			"up":
				arrow_node.rotation_degrees = 180
			"left":
				arrow_node.rotation_degrees = 270
