extends Node

static func get_legal_moves(piece: Node, from: Vector2i) -> Array:
	var moves: Array = []
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var dest = from + Vector2i(dx, dy)
			if dest.x >= 0 and dest.x < 8 and dest.y >= 0 and dest.y < 8:
				moves.append(dest)
	return moves
