extends Interactable
class_name Item

@export var mesh: Node3D
@export var manyMeshes: Array
@export var itemSlot: String
@export var animationModifier: String
@export var iconPath: String
@export var holderID:= -1 #item starts not being held by anyone, -1 if on ground.
@export var holder: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !mesh:
		return
	if holderID == -1:
		mesh.rotation = Vector3(0,0,-deg_to_rad(90))
		displayingName = true
	else:
		matchToLimb()
		displayingName = false
	if !GameManager.activePlayer:
		return
	#print(str(GameManager.activePlayer.stats.id)+":"+str(get_parent().get_multiplayer_authority()))
	if holderID != GameManager.activePlayer.stats.id:
		if mesh is MeshInstance3D:
			mesh.set_layer_mask_value(3,false)
			mesh.set_layer_mask_value(4,true)
			mesh.set_layer_mask_value(11,false)
		else:
			for meshOf in manyMeshes:
				meshOf.set_layer_mask_value(3,false)
				meshOf.set_layer_mask_value(4,true)
				meshOf.set_layer_mask_value(11,false)
	else:
		if GameManager.activePlayer.stats.hotbar[GameManager.activePlayer.stats.hotbarIndex] != self:
			rpc("toggleVisibility", false)
		else:
			if Input.is_action_just_pressed("leftClick"):
				leftClick()
			if Input.is_action_just_pressed("rightClick"):
				rightClick()
			rpc("toggleVisibility", true)
		if mesh is MeshInstance3D:
			mesh.set_layer_mask_value(3,true)
			mesh.set_layer_mask_value(4,false)
			mesh.set_layer_mask_value(11,true)
		else:
			for meshOf in manyMeshes:
				meshOf.set_layer_mask_value(3,true)
				meshOf.set_layer_mask_value(4,false)
				meshOf.set_layer_mask_value(11,true)
	if !GameManager.activePlayer.fullyActionable and holderID == GameManager.activePlayer.stats.id:
		if mesh is MeshInstance3D:
			mesh.set_layer_mask_value(3,false)
			mesh.set_layer_mask_value(4,true)
			mesh.set_layer_mask_value(11,false)
		else:
			for meshOf in manyMeshes:
				meshOf.set_layer_mask_value(3,true)
				meshOf.set_layer_mask_value(4,false)
				meshOf.set_layer_mask_value(11,true)

func leftClick():
	pass
	
func rightClick():
	pass

func interact():
	print("interact function called")
	if holderID == -1:
		rpc("updateHolder",GameManager.activePlayer.stats.id)
		await get_tree().create_timer(.1).timeout
		GameManager.activePlayer.stats.getItem(self)
		
@rpc("any_peer", "call_local", "reliable")
func toggleVisibility(on):
	get_parent().visible = on

func drop(pos,rot):
	rpc("rpcDrop",pos,rot)
	
@rpc("any_peer", "call_local", "reliable")
func rpcDrop(pos,rot):
	print("drpopped")
	get_parent().global_position = pos
	get_parent().global_rotation = rot
	holderID = -1
	holder = null

func matchToLimb():
	match itemSlot:
		"leftHand":
			var offset = Vector3.ZERO
			if get_parent().get_node("lantern"):
				get_parent().get_node("lantern/Armature/Skeleton3D").physical_bones_start_simulation(["Bone", "Bone.001", "Bone.003", "Bone.002"])
			if get_parent().get_node("GrabPoint"):
				offset = get_parent().get_node("GrabPoint").position
			get_parent().global_transform = holder.leftHandSocket.global_transform
			get_parent().global_position = get_parent().global_position + offset
			mesh.rotation = Vector3(deg_to_rad(-90),deg_to_rad(-90),0)

			#get_parent().rotate(get_parent().basis.x,deg_to_rad(90))

@rpc("any_peer", "call_local", "reliable")
func updateHolder(id):
	#print(str(id))
	if holderID == -1:
		holderID = id
		for player in GameManager.players.get_children():
			if player.stats.id == id:
				holder = player
		return true
