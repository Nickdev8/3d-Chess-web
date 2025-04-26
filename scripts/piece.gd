extends Area3D

@export var piece_type: String
@export var piece_color: String
@export var coord: Vector2i
@export var size: float = 1.0
@export var mesh_inst: MeshInstance3D
@export var collison_inst: CollisionShape3D

func _ready() -> void:
	# 1) Load & instance the glTF scene
	var scene_path = "res://assets/%s.gltf" % piece_type
	var packed: PackedScene = ResourceLoader.load(scene_path)
	var inst = packed.instantiate() as Node3D
	add_child(inst)
	mesh_inst = _find_mesh_instance(inst)
	set_meta("piece_type", piece_type)

	# 2) Tint meshes (white or gray)
	if piece_color == "white":
		_recolor_meshes(Color.WHITE)
	else:
		_recolor_meshes(Color.DIM_GRAY)

	# 3) Find the MeshInstance3D and build its convex hull
	if mesh_inst:
		collison_inst = CollisionShape3D.new()
		add_child(collison_inst)
		# Mesh.create_convex_shape() returns ConvexPolygonShape3D :contentReference[oaicite:1]{index=1}
		collison_inst.shape = mesh_inst.mesh.create_convex_shape()
	else:
		push_warning("No MeshInstance3D found under %s" % scene_path)
		
	if piece_type == "pawn":
		collison_inst.scale = Vector3(0.35,0.3,0.35)
		collison_inst.rotation = rotation*2
	else:
		collison_inst.scale = Vector3(0.61,0.61,0.61)
		collison_inst.rotation = rotation*2

	# 4) Position & physics layers
	global_transform.origin = Vector3(coord.x * size, 0, coord.y * size)
	collision_layer = 1
	collision_mask  = 1

func _recolor_meshes(tint: Color) -> void:
	var orig = mesh_inst.mesh.surface_get_material(0)
	if orig == null:
		orig = StandardMaterial3D.new()
	var mat = orig.duplicate()
	mat.albedo_color = tint
	mesh_inst.material_override = mat


# Helper: depth‐first search for MeshInstance3D
func _find_mesh_instance(root: Node) -> MeshInstance3D:
	if root is MeshInstance3D:
		return root
	for child in root.get_children():
		var found = _find_mesh_instance(child)
		if found:
			return found
	return null
