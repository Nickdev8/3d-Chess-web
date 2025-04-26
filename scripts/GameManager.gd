extends Node

@export var board_root: Node3D
@export var size: float = 1

const TILE_SCENE  = preload("res://scenes/tile.tscn")
const PIECE_SCENE = preload("res://scenes/piece.tscn")

var board_map: Dictionary = {}
var starting_positions = [
	{"type":"rook",   "color":"white", "coord":Vector2i(0,7), "rotation":-90},
	{"type":"knight", "color":"white", "coord":Vector2i(1,7), "rotation":-90},
	{"type":"bishop", "color":"white", "coord":Vector2i(2,7), "rotation":-90},
	{"type":"queen",  "color":"white", "coord":Vector2i(3,7), "rotation":-90},
	{"type":"king",   "color":"white", "coord":Vector2i(4,7), "rotation":-90},
	{"type":"bishop", "color":"white", "coord":Vector2i(5,7), "rotation":-90},
	{"type":"knight", "color":"white", "coord":Vector2i(6,7), "rotation":-90},
	{"type":"rook",   "color":"white", "coord":Vector2i(7,7), "rotation":-90},
	
	{"type":"pawn",   "color":"white", "coord":Vector2i(0,6), "rotation":-90},
	{"type":"pawn",   "color":"white", "coord":Vector2i(1,6), "rotation":-90},
	{"type":"pawn",   "color":"white", "coord":Vector2i(2,6), "rotation":-90},
	{"type":"pawn",   "color":"white", "coord":Vector2i(3,6), "rotation":-90},
	{"type":"pawn",   "color":"white", "coord":Vector2i(4,6), "rotation":-90},
	{"type":"pawn",   "color":"white", "coord":Vector2i(5,6), "rotation":-90},
	{"type":"pawn",   "color":"white", "coord":Vector2i(6,6), "rotation":-90},
	{"type":"pawn",   "color":"white", "coord":Vector2i(7,6), "rotation":-90},
	
	{"type":"rook",   "color":"black", "coord":Vector2i(0,0), "rotation":90},
	{"type":"knight", "color":"black", "coord":Vector2i(1,0), "rotation":90},
	{"type":"bishop", "color":"black", "coord":Vector2i(2,0), "rotation":90},
	{"type":"queen",  "color":"black", "coord":Vector2i(3,0), "rotation":90},
	{"type":"king",   "color":"black", "coord":Vector2i(4,0), "rotation":90},
	{"type":"bishop", "color":"black", "coord":Vector2i(5,0), "rotation":90},
	{"type":"knight", "color":"black", "coord":Vector2i(6,0), "rotation":90},
	{"type":"rook",   "color":"black", "coord":Vector2i(7,0), "rotation":90},
	
	{"type":"pawn",   "color":"black", "coord":Vector2i(0,1), "rotation":90},
	{"type":"pawn",   "color":"black", "coord":Vector2i(1,1), "rotation":90},
	{"type":"pawn",   "color":"black", "coord":Vector2i(2,1), "rotation":90},
	{"type":"pawn",   "color":"black", "coord":Vector2i(3,1), "rotation":90},
	{"type":"pawn",   "color":"black", "coord":Vector2i(4,1), "rotation":90},
	{"type":"pawn",   "color":"black", "coord":Vector2i(5,1), "rotation":90},
	{"type":"pawn",   "color":"black", "coord":Vector2i(6,1), "rotation":90},
	{"type":"pawn",   "color":"black", "coord":Vector2i(7,1), "rotation":90},
	# … etc for all 32 pieces …
]
func _ready():
	board_map.clear()
	_spawn_tiles()     # <<<<<<<<<<<<< make tiles first
	_spawn_pieces()


func _spawn_tiles() -> void:
	for x in range(8):
		for y in range(8):
			var tile = TILE_SCENE.instantiate()
			tile.coord    = Vector2i(x, y)
			tile.position = Vector3(x*size, -0.5, y*size)
			tile.scale    = Vector3(size, 1, size)
			tile.name     = "Tile_%d_%d" % [x, y]
			board_root.add_child(tile)
			# Optionally store tiles in board_map too:
			# board_map[tile.coord] = tile


func _spawn_pieces() -> void:
	for data in starting_positions:
		var piece = PIECE_SCENE.instantiate() as Node3D
		piece.piece_type  = data.type
		piece.piece_color = data.color
		piece.coord       = data.coord
		piece.size        = size
		piece.rotation_degrees = Vector3(0, data.rotation, 0)
		board_root.add_child(piece)
		board_map[piece.coord] = piece
