extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
	add_player(1)#host
		
func add_player(id: int):
	while !GameManager.dungeonExists:
		await get_tree().physics_frame
	var player = GameManager.player.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)
	print ("Spawned client player "+player.name)
	player.stats.ign = GameManager.activePlayerName
	#player.global_position = Vector3(0,5,0)
	$Players.add_child(player)

func del_player(id: int):
	if not $Players.has_node(str(id)):
		return 
	$Players.get_node(str(id)).queue_free()

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)

func _on_boundaries_body_entered(body):
	if body == GameManager.activePlayer:
		Utils.setVolumetricFogDensity(.07)
