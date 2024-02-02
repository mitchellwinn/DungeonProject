extends Node3D

@export var input: AudioStreamPlayer3D
@export var output: AudioStreamPlayer3D
@export var ceilingRay: RayCast3D
var idx 
var effect
var playback
var bufferSize = 512

# Called when the node enters the scene tree for the first time.
func _ready():
	playback = output.get_stream_playback()
	if !is_multiplayer_authority():
		return
	input.stream = AudioStreamMicrophone.new()
	input.play()
	output.volume_db = -9999
	idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	print("Input device: ", AudioServer.input_device)
	2	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_multiplayer_authority():
		#print("no auth")
		return
	if get_parent().stats.current_hp<=0:
		return
	reverbCalculator()
	#bufferSize = effect.get_frames_available()
	if (effect.can_get_buffer(bufferSize) && playback.can_push_buffer(bufferSize)):
		rpc("sendData",(effect.get_buffer(bufferSize)))
	effect.clear_buffer()
	#playback.clear_buffer()

@rpc("any_peer", "call_remote", "reliable")
func sendData(buffer):
	for i in range(0, bufferSize):
		playback.push_frame(buffer[i])
		#print("playing data...")
	#print("finished voice packet!")

func reverbCalculator():
	var physicalidx = AudioServer.get_bus_index("Physical")
	var reverbEffect = AudioServer.get_bus_effect(physicalidx, 0)
	if ceilingRay.is_colliding():
		reverbEffect.wet = (ceilingRay.get_collision_point()-global_position).length()/100
		reverbEffect.room_size = (ceilingRay.get_collision_point()-global_position).length()/100
	else:
		reverbEffect.wet = 0

		
		
