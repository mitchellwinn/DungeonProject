extends Node3D

@export var targetPortal: Node3D
@export var view: SubViewport
@export var camera: Camera3D
@export var gate: Node3D
@export var direction: Node3D
@export var playerCamRelativeToPortal: Transform3D
@export var movedToTargetPortal: Transform3D
var on = false
var parent = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.environment = get_viewport().world_3d.environment.duplicate()
	camera.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	camera.environment.tonemap_exposure = 1
	camera.environment.tonemap_exposure = 1
	camera.environment.glow_enabled = false	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if targetPortal and GameManager.activePlayer and on and GameManager.dungeonExists:
		if (global_position - GameManager.activePlayer.camera.global_position).length()>5:
			targetPortal.camera.current = false#can't see to faraway camera
		else:
			targetPortal.camera.current = true
			targetPortal.camera.environment.volumetric_fog_density = lerp(get_viewport().world_3d.environment.volumetric_fog_density, Utils.targetFogDensity,delta/5)
		#print(gate.name+"|"+targetPortal.gate.name)
		playerCamRelativeToPortal = gate.global_transform.affine_inverse()*GameManager.activePlayer.camera.global_transform
		movedToTargetPortal = targetPortal.gate.global_transform * playerCamRelativeToPortal
		targetPortal.camera.global_transform = movedToTargetPortal
		#print(gate.name+"|"+"gate pos: "+str(gate.global_position)+"\ntarget gate camera pos: "+str(targetPortal.camera.global_position))
		get_child(0).material.set_shader_parameter("texture_albedo",targetPortal.view.get_texture())
		get_child(1).material.set("albedo_texture", GameManager.portalStatic.get_texture())
		get_child(0).visible = true
		get_child(1).visible = true
	elif !on:
		get_child(0).visible = false
		get_child(1).visible = false
		
		

func link(portal):
	parent = true
	targetPortal = portal
	targetPortal.targetPortal = self
	#targetPortal.camera.current = true
	on = true
	if targetPortal.gate.name != "Gate Of Ivory":
		targetPortal.on = true
	print("target portal of "+gate.name+" ("+gate.get_parent().name+") has been linked to "+targetPortal.gate.name+" ("+targetPortal.gate.get_parent().name+")")

func delink():
	if targetPortal:
		targetPortal.targetPortal = null
		targetPortal.parent = false
		targetPortal.on = false
	targetPortal = null
	parent = false
	on = false

func _on_area_3d_body_entered(body):
	print(body.name)
	#return
	if targetPortal and on:
		if body.velocity.normalized().dot(direction.global_transform.basis.z)>0 and GameManager.teleportCool<0:
			print("TELEPORT")
			print("initial pos: "+str(body.global_position))
			print("initial rot: "+str(body.global_rotation))
			print("initial vel: "+str(body.velocity))
			#body.global_position = Vector3(body.global_position.x+(targetPortal.global_position.x-global_position.x),body.global_position.y+(targetPortal.global_position.y-global_position.y),body.global_position.z+(targetPortal.global_position.z-global_position.z))
			#GameManager.teleportCool=2
			var relativeToPortal = gate.global_transform.affine_inverse()*body.global_transform
			var movedToTargetPortal = targetPortal.gate.global_transform * relativeToPortal
			body.global_transform = movedToTargetPortal
			var r = targetPortal.gate.global_transform.basis.get_euler() - gate.global_transform.basis.get_euler()
			body.velocity = body.velocity \
				.rotated(Vector3(1,0,0),r.x) \
				.rotated(Vector3(0,1,0),r.y) \
				.rotated(Vector3(0,0,1),r.z) 
			print("final pos: "+str(body.global_position))
			print("final rot: "+str(body.global_rotation))
			print("final vel: "+str(body.velocity))
		else:
			if GameManager.teleportCool>=0:
				print("TELECOOLDOWN")
			elif body.velocity.normalized().dot(direction.basis.z)<=0:
				print("entered from wrong way")
	else:
		print("no target...")	
