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
