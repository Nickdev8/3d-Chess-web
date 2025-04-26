extends Node
@onready var board = %Board

const TILE_SCENE = preload("res://scenes/tile.tscn")
@export var size = 100

func _ready():
	for x in range(8):
		for y in range(8):
			var tile = TILE_SCENE.instantiate()
			tile.coord = Vector2(x, y)
			tile.position = Vector3(x, 0, y)
			tile.name = "Tile_%d_%d" % [x, y]
			board.add_child(tile)
