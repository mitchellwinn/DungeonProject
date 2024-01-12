extends Node2D

@export var ipField: TextEdit
@export var nameEntry: TextEdit
var hostIP = ""

var peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
		change_level.call_deferred(load("res://Assets/Levels/Erebos.tscn"))


func change_level(scene :PackedScene):
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())
