extends Node3D

@export var input: AudioStreamPlayer3D
@export var output: AudioStreamPlayer3D
var idx 
var effect
var playback

# Called when the node enters the scene tree for the first time.
func _ready():
	playback = output.get_stream_playback()
	if !is_multiplayer_authority():
		return
	input.stream = AudioStreamMicrophone.new()
	input.play()
	idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	print("Input device: ", AudioServer.input_device)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_multiplayer_authority():
		#print("no auth")
		return
	if (effect.can_get_buffer(512) && playback.can_push_buffer(512)):
		sendData(effect.get_buffer(512))
	effect.clear_buffer()

@rpc("any_peer", "reliable")
func sendData(buffer):
	#New Voice Packet Received
	for i in range(0, 512):
		playback.push_frame(buffer[i])
		#print("playing data...")
	#print("finished voice packet!")
