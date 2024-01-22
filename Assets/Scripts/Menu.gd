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
	GameManager.portalStatic = portalStaticViewport
	populateInputDropdown()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func populateInputDropdown():
	devices = Utils.getInputDeviceList()
	for device in devices:
		deviceDropdown.add_item(str(device),null,true)

func _on_host_pressed():
	hostGame()

func _on_join_pressed():
	hostIP = ipField.text
	joinGame()

func hostGame():
	if nameEntry.text.strip_edges(true,true) == "":
		return
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	start_game()

func joinGame():
	if nameEntry.text.strip_edges(true,true) == "":
		return
	peer.create_client(hostIP,135)
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
