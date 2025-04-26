# res://scripts/InputController.gd
extends Node

@export var board_root : Node3D
@export var camera     : Camera3D
@export var rule_engine: Node

var selected_piece: Area3D = null
#var legal_moves: Array[Vector2i] = []
var legal_moves: Array = []
var highlighted_tiles: Array[MeshInstance3D] = []

signal piece_selected(piece)
signal moves_highlighted(moves)
signal piece_moved(piece, from_coord, to_coord)

func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:

		# 1) Clear any old highlights
		_clear_highlights()

		# 2) Build a world-space ray from the click
		var origin   = camera.project_ray_origin(ev.position)
		var to_point = origin + camera.project_ray_normal(ev.position) * 1000.0

		# 3) Brute-force every mesh under board_root
		var best_dist := INF
		var best_owner: Node        = null
		var best_mesh_inst: MeshInstance3D = null

		for owner in board_root.get_children():
			# owner is e.g. an Area3D (piece) or StaticBody3D (tile)
			var mesh_inst = _find_mesh_instance(owner)
			if mesh_inst and mesh_inst.mesh:
				var mesh  = mesh_inst.mesh
				var faces : PackedVector3Array = mesh.get_faces()
				var xform : Transform3D       = mesh_inst.global_transform

				# test each triangle in this mesh
				for i in range(0, faces.size(), 3):
					var a = xform * faces[i]
					var b = xform * faces[i + 1]
					var c = xform * faces[i + 2]
					var hit = Geometry3D.ray_intersects_triangle(origin, to_point, a, b, c)
					if hit != null:
						var d = origin.distance_to(hit)
						if d < best_dist:
							best_dist      = d
							best_owner     = owner
							best_mesh_inst = mesh_inst

		# 4) Dispatch the nearest hit
		if best_owner.has_meta("piece_type"):
			_select_piece(best_owner)
		elif best_owner.has_meta("coord") and selected_piece != null:
			# grab the coord we stored on the tile
			var tile_coord = best_owner.get_meta("coord")
			_try_move_to(tile_coord)



func _select_piece(piece: Area3D) -> void:
	selected_piece = piece
	print_debug("_select_piece ->", piece.name)
	# 1) Highlight the piece
	_highlight_piece(piece)
	# 2) Compute legal moves
	legal_moves = rule_engine.get_legal_moves(piece, piece.coord)
	print_debug("Legal moves for", piece.name, "=", legal_moves)
	# 3) Highlight tiles
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
	if selected_piece == null:
		return
	var piece_name = selected_piece.name
	print_debug("_try_move_to:", piece_name, "->", to_coord)
	if to_coord in legal_moves:
		var from_coord = selected_piece.coord
		print_debug("Moving", piece_name, "from", from_coord, "to", to_coord)
		emit_signal("piece_moved", selected_piece, from_coord, to_coord)
		selected_piece = null
		legal_moves.clear()
		highlighted_tiles.clear()
	else:
		print_debug("Invalid move:", to_coord, "not in", legal_moves)
		selected_piece = null
		legal_moves.clear()
		highlighted_tiles.clear()
		emit_signal("moves_highlighted", [])


# Depth-first search for the first MeshInstance3D under a node
func _find_mesh_instance(root: Node) -> MeshInstance3D:
	if root is MeshInstance3D:
		return root
	for child in root.get_children():
		var found = _find_mesh_instance(child)
		if found != null:
			return found
	return null
