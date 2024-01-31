extends Node

var targetFogDensity = -1.0

func _physics_process(delta):
	if targetFogDensity>=0:
		get_viewport().world_3d.environment.volumetric_fog_density = lerp(get_viewport().world_3d.environment.volumetric_fog_density, targetFogDensity,delta/5)

func getInputDeviceList():
	var devices: Array
	for device in AudioServer.get_input_device_list():
		devices.append(device)
	return devices

func setVolumetricFogDensity(density):
	targetFogDensity = density

func getFloorType(floor):
	if floor.is_in_group("carpet"):
		return "carpet"
	if floor.is_in_group("hard") or floor.is_in_group("wood"):
		return "hard"
	else:
		return "silent"

func noticedPotentialTarget(user,targets):
	var space_state = user.get_world_3d().direct_space_state
	for target in targets:
		var occlusionCast = PhysicsRayQueryParameters3D.create(user.global_position+Vector3.UP,target.global_position+Vector3.UP)
		occlusionCast.collide_with_areas = true
		var result = space_state.intersect_ray(occlusionCast)
		if result:
			if result.collider == target:
				if (target.global_position+Vector3.UP-user.global_position).normalized().dot(user.basis.z)>.5: #
					print("Target was seen!")
					return target
