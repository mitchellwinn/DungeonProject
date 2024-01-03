@tool
extends Node3D

var rng = RandomNumberGenerator.new()
@export var seed: int
@export var randomSeed: bool
var rooms: Dictionary
@export var roomAmount = 10
var currentRoom = 0
const test_room = preload("res://Assets/Rooms/Test_Room.tscn")


# Called when the node enters the scene tree for the first time.
func _run():
	generate()
	
func generate():
	if randomSeed:
		seed = rng.randi_range( -9223372036854775808,9223372036854775807)
	rng.seed = seed
	while currentRoom<roomAmount:
		var roomInstance= test_room.instantiate()
		self.add_child(roomInstance)
		if currentRoom==0: #main entrance
			pass
		else:
			roomInstance.global_position = 
		rooms[currentRoom] = roomInstance
		
		
