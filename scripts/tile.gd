extends StaticBody3D

@export var coord: Vector2i = Vector2i.ZERO

func _ready() -> void:
	var mesh_inst = $MeshInstance3D
	var orig_mat = mesh_inst.mesh.surface_get_material(0)
	if orig_mat == null:
		orig_mat = StandardMaterial3D.new()
	var mat = orig_mat.duplicate()
	mat.albedo_color = Color.WHITE if (coord.x + coord.y) % 2 == 0 else Color.GRAY
	mesh_inst.material_override = mat
	set_meta("coord", coord)
