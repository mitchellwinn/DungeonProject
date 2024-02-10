extends Item
	
@export var skeleton: Skeleton3D

func _ready():
	get_parent().get_node("BoneAttachment3D/Fire/AnimationPlayer").play("on")
	manyMeshes.append(get_parent().get_node("BoneAttachment3D/Fire/Sprite3D"))
	manyMeshes.append(get_parent().get_node("lantern/Armature/Skeleton3D/Cylinder/Cylinder"))
	manyMeshes.append(get_parent().get_node("lantern/Armature/Skeleton3D/Cylinder_001/Cylinder_001"))
	manyMeshes.append(get_parent().get_node("lantern/Armature/Skeleton3D/Lantern/Lantern"))
	manyMeshes.append(get_parent().get_node("lantern/Armature/Skeleton3D/Icosphere_002/Icosphere_002"))
	manyMeshes.append(get_parent().get_node("lantern/Armature/Skeleton3D/Torus/Torus"))
	manyMeshes.append(get_parent().get_node("lantern/Armature/Skeleton3D/Torus_001/Torus_001"))

func leftClick():
	pass
