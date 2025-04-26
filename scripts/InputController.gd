extends Node

@export var board_root   : Node3D
@export var camera       : Camera3D
@export var rule_engine  : Node
@export var game_manager_path: NodePath
@onready var game_manager = get_node(game_manager_path)

var selected_piece: Area3D = null
var legal_moves   : Array  = []
var highlighted_tiles: Array[MeshInstance3D] = []

func _unhandled_input(ev: InputEvent) -> void:
	if not (ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed):
		return

	# clear old UI
	_clear_highlights()

	# shoot a math‐ray through every mesh
	var origin   = camera.project_ray_origin(ev.position)
	var to_point = origin + camera.project_ray_normal(ev.position) * 1000.0

	var best_dist := INF
	var best_owner: Node = null

	for owner in board_root.get_children():
		var mesh_inst = _find_mesh_instance(owner)
		if mesh_inst and mesh_inst.mesh:
			var faces = mesh_inst.mesh.get_faces()
			var xform = mesh_inst.global_transform
			for i in range(0, faces.size(), 3):
				var a = xform * faces[i]
				var b = xform * faces[i+1]
				var c = xform * faces[i+2]
				var hit = Geometry3D.ray_intersects_triangle(origin, to_point, a, b, c)
				if hit != null:
					var d = origin.distance_to(hit)
					if d < best_dist:
						best_dist = d
						best_owner = owner

	if best_owner == null:
		print_debug("Nothing clicked")
		return

	# if no piece is selected yet, only allow selecting your own
	if selected_piece == null:
		if best_owner.has_meta("piece_type") and best_owner.piece_color == game_manager.current_turn:
			_select_piece(best_owner)
		else:
			print_debug("Click ignored: no piece selected yet")
		return

	# otherwise we have a piece selected—compute the target coord
	var dest_coord: Vector2i = Vector2i(-1,-1)
	if best_owner.has_meta("piece_type"):
		# clicked on a piece: use its coord
		dest_coord = best_owner.get_meta("coord")
	elif best_owner.has_meta("coord"):
		# clicked on a tile: use its coord
		dest_coord = best_owner.get_meta("coord")
	else:
		return

	# if that coord is legal, do the move (capture or slide)
	if dest_coord in legal_moves:
		_try_move_to(dest_coord)
	else:
		# if they clicked another of their own pieces, switch selection
		if best_owner.has_meta("piece_type") and best_owner.piece_color == game_manager.current_turn:
			_select_piece(best_owner)
		else:
			print_debug("Illegal target:", dest_coord)


func _select_piece(piece: Area3D) -> void:
	# 1. Check turn
	var turn_color = game_manager.current_turn
	if piece.piece_color != turn_color:
		print_debug("Not %s's turn — can't pick %s" % [turn_color, piece.name])
		return

	# 2. Clear & highlight
	selected_piece = piece
	print_debug("_select_piece ->", piece.name)
	_highlight_piece(piece)

	# 3. Compute & paint legal moves
	legal_moves = rule_engine.get_legal_moves(piece, piece.coord, game_manager.board_map, game_manager.last_move)
	print_debug("Legal moves for", piece.name, "=", legal_moves)
	_highlight_tiles(legal_moves)

	emit_signal("piece_selected", piece)
	emit_signal("moves_highlighted", legal_moves)


func _highlight_piece(piece: Area3D) -> void:
	var mesh_inst = _find_mesh_instance(piece)
	if mesh_inst and mesh_inst.material_override:
		var orig = mesh_inst.material_override.albedo_color
		# lighten by +0.3, clamped
		var lighter = Color(
			min(orig.r + 0.3, 1.0),
			min(orig.g + 0.3, 1.0),
			min(orig.b + 0.3, 1.0),
			orig.a
		)
		mesh_inst.material_override.albedo_color = lighter


func _highlight_tiles(moves: Array) -> void:
	for coord in moves:
		var node_name = "Tile_%d_%d" % [coord.x, coord.y]
		if board_root.has_node(node_name):
			var tile = board_root.get_node(node_name) as StaticBody3D
			var mesh_inst = _find_mesh_instance(tile)
			if mesh_inst and mesh_inst.material_override:
				# gold-ish color
				mesh_inst.material_override.albedo_color = Color(1.0, 0.84, 0.0, 1.0)
				highlighted_tiles.append(mesh_inst)


func _clear_highlights() -> void:
	# reset the previously selected piece’s color
	if selected_piece != null:
		var mesh_inst = _find_mesh_instance(selected_piece)
		if mesh_inst and mesh_inst.material_override:
			var is_white = selected_piece.piece_color == "white"
			var orig = Color.WHITE if is_white else Color.DIM_GRAY
			mesh_inst.material_override.albedo_color = orig

	# reset all highlighted tiles
	for mesh_inst in highlighted_tiles:
		var tile = mesh_inst.get_parent() as StaticBody3D
		var coord = tile.coord
		var orig  = Color.WHITE if ((coord.x + coord.y) % 2 == 0) else Color.GRAY
		mesh_inst.material_override.albedo_color = orig

	highlighted_tiles.clear()

func _try_move_to(to_coord: Vector2i) -> void:
	print_debug("trying to move")
	if selected_piece == null:
		return

	var piece_name = selected_piece.name
	print_debug("_try_move_to:", piece_name, "->", to_coord)

	if to_coord in legal_moves:
		game_manager.attempt_move(selected_piece, to_coord)
		game_manager.next_turn()
		_clear_highlights()
		selected_piece = null
		legal_moves.clear()
		highlighted_tiles.clear()
	else:
		print_debug("Invalid move:", to_coord, "not in", legal_moves)
		_clear_highlights()
		selected_piece = null
		legal_moves.clear()
		highlighted_tiles.clear()



# Depth-first search for the first MeshInstance3D under a node
func _find_mesh_instance(root: Node) -> MeshInstance3D:
	if root is MeshInstance3D:
		return root
	for child in root.get_children():
		var found = _find_mesh_instance(child)
		if found != null:
			return found
	return null
