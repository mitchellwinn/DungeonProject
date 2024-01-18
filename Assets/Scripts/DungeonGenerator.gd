extends Node

var rng = RandomNumberGenerator.new()
@export var seed: int
@export var randomSeed: bool
@export var nestLimit: int
var rooms: Array
@export var gateOfHornPortal: Node3D
@export var gateOfIvoryPortal: Node3D
@export var rootRoomPosition: Vector3
@export var roomDensity: int #adjusts the likelihood of each room having entrances to more rooms (1-1000)
@export var bigRoomChance: int #adjusts the likelihood of each room being a big room instead (1-1000)
var timeSinceLastCompletion = 0
const _test_room = preload("res://Assets/Rooms/_Test_Room.tscn")
const _big_room = preload("res://Assets/Rooms/_Big_Room.tscn")
var ivoryConnection = false
var complete = false


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Beginning dungeon generation...")
	await generate()
	await removeLooseExits()
	print ("generation complete!")
	GameManager.dungeonExists = true
		
func saveGeneratedMap():
	var node_to_save = get_node("RootRoom")
	#print("Attempting to save  " + node_to_save.name + "\nWhich includes:")
	for child in node_to_save.get_children():
		child.set_owner(node_to_save)
		#print(child.name)
	var scene = PackedScene.new()
	scene.pack(node_to_save)
	ResourceSaver.save(scene, "res://Assets/Rooms/RoomGenerationTest.tscn")	
	#get_tree().quit()

func portalPopulation(room):
	if room.nestLevel > 0 and !ivoryConnection and room.activeEntranceCount<=1:
		room.gateOfIvory.visible = true
		ivoryConnection = true
		await get_tree().physics_frame
		gateOfIvoryPortal.link(room.gateOfIvoryPortal)
	else:
		room.gateOfIvory.queue_free()

func generate():
	if randomSeed and multiplayer.is_server():
		rng.randomize()
		seed = rng.seed
	else:
		await get_tree().create_timer(.25).timeout
		rng.seed = seed
	seed(rng.seed)
	print("SEED: "+str(rng.seed))
	await generateRoom(rootRoomPosition,0)
	
func generateRoom(_position, nestLevel):
	#print("Attempting to generate root room")
	var roomInstance = _test_room.instantiate()
	rooms.append(roomInstance)
	roomInstance.name = "RootRoom"
	roomInstance.nestLevel = nestLevel
	add_child(roomInstance)
	#await get_tree().process_frame
	roomInstance.global_position = _position
	roomInstance.initializeRoom(self)
	await get_tree().physics_frame
	gateOfHornPortal.link(roomInstance.gateOfHornPortal)
	#print("Generated root room")
	#print("at "+str(roomInstance.global_position))
	#print("Attempting to generate children rooms for room "+str(rooms.size()))
	for entrance in roomInstance.entrances:
		if entrance.visible and !entrance.hasConnection:
			await generateRoomChild(roomInstance,entrance,nestLevel+1)

func decideRoomType():
	var roomInstance
	if rng.randi_range(0,1000)>(1000-bigRoomChance):
		roomInstance = _big_room.instantiate()
	else:
		roomInstance = _test_room.instantiate()
	return roomInstance

func generateRoomChild(parentRoom ,parentEntrance,nestLevel):
	#await get_tree().physics_frame
	if nestLevel>nestLimit:
		#print("Hit the nest limit")
		return -1
	#print("Attempting to generate child room "+str(rooms.size()))
	var roomInstance = decideRoomType()
	#await get_tree().physics_frame
	rooms.append(roomInstance)
	roomInstance.parentEntrance = parentEntrance
	roomInstance.parentRoom = parentRoom
	roomInstance.name = "ChildRoom"+str(rooms.size()-1)
	roomInstance.nestLevel = nestLevel
	get_node("RootRoom").add_child(roomInstance)
	var direction = (Vector3(parentEntrance.opening.global_position.x-parentEntrance.forwardsOffset,0,parentEntrance.opening.global_position.z-parentEntrance.sidewaysOffset)-parentEntrance.get_parent().get_parent().global_position)
	direction.y = 0
	direction = direction.normalized()
	#print("Direction: "+str(direction))
	#################################### POSITION OF NEWLY SPAWNED CHILD ROOM!
	roomInstance.global_position = Vector3(parentEntrance.forwardsOffset,parentEntrance.heightOffset,parentEntrance.sidewaysOffset)+parentRoom.global_position+direction*(roomInstance.get_node("RoomOuter").size.x/2+parentRoom.get_node("RoomOuter").size.x/2)
	await get_tree().physics_frame
	####################################
	roomInstance.initializeRoom(self)
	#print("at "+str(roomInstance.global_position))
	await get_tree().physics_frame
	#print("Testing to see if a room already exists here...")
	for overlappingArea in roomInstance.roomBoundaries.get_overlapping_areas():
		#print("Boundary of "+roomInstance.get_name()+" overlapped with something during the test!")
		#print("Its parent entrance happened to be of entrance type"+" "+parentEntrance.notes+" leading into this room.")
		#print ("Overlapped with "+overlappingArea.get_parent().get_name())
		#print("A room already exists here. Removing the current room.")
		#rooms.pop_back()
		rooms.erase(roomInstance)
		roomInstance.queue_free()
		await get_tree().physics_frame
		#room generation failed so we now want to try to link our room to what is already there
		overlappingArea.get_parent().linkRooms(parentRoom,parentEntrance)
		return
	#print("No room was found to be in the way.")
	#roomDensity=roomDensity*.9
	#print("Successfully initialized child room "+str(rooms.size()))
	timeSinceLastCompletion = 0
	#print("Attempting to generate children rooms for child room "+str(rooms.size()))
	for entrance in roomInstance.entrances:
		if entrance.visible and !entrance.hasConnection:
			await generateRoomChild(roomInstance,entrance,nestLevel+1)

func removeLooseExits():
	await get_tree().physics_frame
	#print("Attempting to remove loose exits from entrances that lead to nowhere.")
	var i = 0
	#print("Room generation ended on index "+str(rooms.size()))
	while i < rooms.size():
		#print("room"+str(i)+" "+rooms[i].name) 
		for entrance in rooms[i].entrances:
			if !entrance.hasConnection or entranceOverlappingNothing(entrance):
				#print("Removed "+entrance.direction+entrance.notes+" entrance.")
				#entrance.scale = Vector3.ZERO
				#entrance.visible = false
				entrance.queue_free()
				rooms[i].activeEntranceCount-=1
		portalPopulation(rooms[i])
		i+=1

func entranceOverlappingNothing(entrance):
	if entrance.area.get_overlapping_areas().size()==0:
		return true
