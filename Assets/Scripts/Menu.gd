extends Node2D

@export var ipField: TextEdit
@export var nameEntry: TextEdit
@export var portalStaticViewport: SubViewport
@export var deviceDropdown: ItemList
var network = preload("res://Assets/Prefabs/Network.tscn")
var hostIP = ""
var devices

var peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	portMap()
	GameManager.portalStatic = portalStaticViewport
	populateInputDropdown()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func populateInputDropdown():
	devices = Utils.getInputDeviceList()
	for device in devices:
		deviceDropdown.add_item(str(device),null,true)

func portMap():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	
	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			
			var map_result_udp = upnp.add_port_mapping(9999,9999,"godot_udp", "UDP", 0)
			var map_result_tcp = upnp.add_port_mapping(9999,9999,"godot_tcp", "TCP", 0)
			
			if not map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(9999,9999,"","UDP")
			if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(9999,9999,"","TCP")
	
	var external_ip = upnp.query_external_address()
	
	upnp.delete_port_mapping(9999,"UDP")
	upnp.delete_port_mapping(9999,"TCP")
	
	$UI/PublicIP.text = str(external_ip)

func _on_host_pressed():
	hostGame()

func _on_join_pressed():
	hostIP = ipField.text
	joinGame()

func hostGame():
	if nameEntry.text.strip_edges(true,true) == "":
		return
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer
	start_game()

func joinGame():
	if nameEntry.text.strip_edges(true,true) == "":
		return
	peer.create_client(hostIP,9999)
	multiplayer.multiplayer_peer = peer
	start_game()

func start_game():
	GameManager.activePlayerName = nameEntry.text
	$UI.visible=false	
	if multiplayer.is_server():
		GameManager.network = network.instantiate()
		add_child(GameManager.network)
		change_level.call_deferred(load("res://Assets/Levels/Erebos.tscn"))


func change_level(scene :PackedScene):
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())


func _on_item_list_item_selected(index):
	AudioServer.input_device = str(devices[index])
