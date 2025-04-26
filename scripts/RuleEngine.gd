# res://scripts/RuleEngine.gd
extends Node

# Optional: get board_map from your GameManager, or just pass it in as an arg
# @export var game_manager_path: NodePath
# @onready var game_manager = get_node(game_manager_path)
static func get_legal_moves(piece: Node, from: Vector2i, board_map: Dictionary, last_move: Dictionary) -> Array:
	match piece.piece_type:
		"pawn":   return _pawn_moves(piece, from, board_map, last_move)
		"knight": return _knight_moves(piece, from, board_map)
		"bishop": return _slider_moves(piece, from, board_map, [
						Vector2i(1,1), Vector2i(1,-1),
						Vector2i(-1,1), Vector2i(-1,-1)
					])
		"rook":   return _slider_moves(piece, from, board_map, [
						Vector2i(1,0), Vector2i(-1,0),
						Vector2i(0,1), Vector2i(0,-1)
					])
		"queen":  return _slider_moves(piece, from, board_map, [
						Vector2i(1,1), Vector2i(1,-1),
						Vector2i(-1,1), Vector2i(-1,-1),
						Vector2i(1,0), Vector2i(-1,0),
						Vector2i(0,1), Vector2i(0,-1)
					])
		"king":   return _king_moves(piece, from, board_map)
		_:
			return []


static func _in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < 8 and pos.y >= 0 and pos.y < 8


static func _pawn_moves(piece: Node, from: Vector2i, board_map: Dictionary, last_move: Dictionary) -> Array:
	var moves = []
	var forward = Vector2i(0,1) if piece.piece_color == "white" else Vector2i(0,-1)

	# — normal one‐ and two‐square advances —
	var one = from + forward
	if _in_bounds(one) and board_map.get(one) == null:
		moves.append(one)
		var start_row = 1 if piece.piece_color == "white" else 6
		if from.y == start_row:
			var two = one + forward
			if board_map.get(two) == null:
				moves.append(two)

	# — standard diagonal captures —
	for dx in [-1, 1]:
		var cap = from + Vector2i(dx, forward.y)
		var occ = board_map.get(cap, null)
		if _in_bounds(cap) and occ != null and occ.piece_color != piece.piece_color:
			moves.append(cap)

	# — **en passant** —
	# only possible immediately after an enemy pawn moves two squares
	var lm_piece = last_move.piece
	if lm_piece and lm_piece.piece_type == "pawn" and lm_piece.piece_color != piece.piece_color:
		var lm_from: Vector2i = last_move.from
		var lm_to:   Vector2i = last_move.to
		# white pawn can capture en passant on rank 4, black on rank 3
		var ep_rank = 4 if piece.piece_color == "white" else 3
		# check that this pawn is on the correct rank
		if from.y == ep_rank:
			# and that the enemy pawn jumped two squares from the right place
			var start_row = 6 if piece.piece_color == "white" else 1
			if lm_from.y == start_row and lm_to.y == ep_rank:
				# enemy pawn must have landed one file away
				for dx in [-1, 1]:
					if lm_to.x == from.x + dx:
						# the square behind that pawn is where we move
						var ep_target = Vector2i(lm_to.x, lm_to.y + (1 if piece.piece_color == "white" else -1))
						if _in_bounds(ep_target) and board_map.get(ep_target) == null:
							moves.append(ep_target)

	return moves

static func _knight_moves(piece: Node, from: Vector2i, board_map: Dictionary) -> Array:
	var moves = []
	var deltas = [
		Vector2i(1,2), Vector2i(2,1), Vector2i(-1,2), Vector2i(-2,1),
		Vector2i(1,-2), Vector2i(2,-1), Vector2i(-1,-2), Vector2i(-2,-1)
	]
	for d in deltas:
		var dest = from + d
		var occ = board_map.get(dest, null)
		if _in_bounds(dest) and (occ == null or occ.piece_color != piece.piece_color):
			moves.append(dest)
	return moves


static func _slider_moves(piece: Node, from: Vector2i, board_map: Dictionary, directions: Array) -> Array:
	var moves = []
	for dir in directions:
		var dest = from + dir
		while _in_bounds(dest):
			var occ = board_map.get(dest, null)
			if occ != null:
				# enemy? you can capture
				if occ.piece_color != piece.piece_color:
					moves.append(dest)
				break
			# empty square
			moves.append(dest)
			dest += dir
	return moves


static func _king_moves(piece: Node, from: Vector2i, board_map: Dictionary) -> Array:
	# like a 1-step slider in all directions
	return _slider_moves(piece, from, board_map, [
		Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1),
		Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)
	]).filter(func(x): return abs(x.x - from.x) <= 1 and abs(x.y - from.y) <= 1)
