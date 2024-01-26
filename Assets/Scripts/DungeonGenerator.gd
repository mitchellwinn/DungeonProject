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
@export var longConfusingRoomChance: int
@export var departmentStoreChance: int
@export var ideaChance: int
var timeSinceLastCompletion = 0
#const gOh = preload("res://Assets/Prefabs/gate_of_horn.tscn")
#const gOi = preload("res://Assets/Prefabs/gate_of_ivory.tscn")
const _test_room = preload("res://Assets/Rooms/_Test_Room.tscn")
const _big_room = preload("res://Assets/Rooms/_Big_Room.tscn")
const _long_confusing_room = preload("res://Assets/Rooms/_Long_Confusing_Room.tscn")
const _department_store = preload("res://Assets/Rooms/_Department_Store.tscn")
var ivoryConnection = false
var complete = false
#ideas
@export var good_idea = preload("res://Assets/Prefabs/good_idea.tscn")
@export var bad_idea = preload("res://Assets/Prefabs/bad_idea.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	gateOfHornPortal = get_parent().get_node("Gate Of Horn").portal
	gateOfIvoryPortal = get_parent().get_node("Gate Of Ivory").portal
	GameManager.dungeon = self
	while !GameManager.network:
		await get_tree().physics_frame
	if GameManager.network.dungeonLive and (!GameManager.generatingDungeon or GameManager.dungeonExists):
		GameManager.dungeon.generationMain()
	pass
		
func generationMain():
	GameManager.generatingDungeon = true
	print("Beginning dungeon generation...")
	await generateStart()
	await removeLooseExits()
	print ("generation complete!")
	GameManager.dungeonExists = true
	GameManager.generatingDungeon = false
	
func delete():
	GameManager.dungeonExists = false
	gateOfHornPortal.delink()
	gateOfIvoryPortal.delink()
	ivoryConnection = false
	for room in rooms:
		rooms.erase(room)
		room.queue_free()
	rooms.clear()

func portalPopulation(room):
	if room.nestLevel > nestLimit*.75 and !ivoryConnection and room.activeEntranceCount==1:
		print("Gate of Ivory room chosen!")
		print("Of said room, nest level: "+str(room.nestLevel)+", entrance amount: "+str(room.activeEntranceCount))
		room.gateOfIvory.visible = true
		room.gateOfIvoryPortal = room.gateOfIvory.portal
		ivoryConnection = true
		await get_tree().physics_frame
		gateOfIvoryPortal.link(room.gateOfIvoryPortal,false)
	else:
		room.gateOfIvory.queue_free()

func ideaPopulation(room):
	while rng.randi_range(0,1000)>(1000-(ideaChance+room.nestLevel*15)):
		var idea = decideIdeaType()
		self.add_child(idea)
		idea.global_position = room.global_position
		idea.global_position.x += rng.randf_range(-room.get_node("RoomOuter").size.x/2+1,room.get_node("RoomOuter").size.x/2-1)
		idea.global_position.z += rng.randf_range(-room.get_node("RoomOuter").size.z/2+1,room.get_node("RoomOuter").size.z/2-1)
		idea.global_position.y+=2
		print(idea.global_position)
		await get_tree().physics_frame
		while idea.get_node("area").get_overlapping_bodies().size()>0:
			idea.global_position = room.global_position
			idea.global_position.x += rng.randf_range(-room.get_node("RoomOuter").size.x/2+1,room.get_node("RoomOuter").size.x/2-1)
			idea.global_position.z += rng.randf_range(-room.get_node("RoomOuter").size.z/2+1,room.get_node("RoomOuter").size.z/2-1)
			idea.global_position.y+=2
			await get_tree().physics_frame

func decideIdeaType():
	var idea
	if rng.randi_range(0,1000)>(500-GameManager.network.goodModifier*10):
		idea = good_idea.instantiate()
	else:
		idea = bad_idea.instantiate()
	return idea

func generateStart():
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
	roomInstance.appendEntrancesToGroup()
	roomInstance.segregateEntrances()
	roomInstance.sceneRoot = self
	rooms.append(roomInstance)
	roomInstance.name = "RootRoom"
	roomInstance.nestLevel = nestLevel
	add_child(roomInstance)
	#await get_tree().process_frame
	roomInstance.global_position = _position
	roomInstance.initializeRoom()
	await get_tree().physics_frame
	gateOfHornPortal.link(roomInstance.gateOfHornPortal,true)
	#print("Generated root room")
	#print("at "+str(roomInstance.global_position))
	#print("Attempting to generate children rooms for room "+str(rooms.size()))
	for entrance in roomInstance.entrances:
		if entrance.visible and !entrance.hasConnection:
			await generateRoomChild(roomInstance,entrance,nestLevel+1,true)

func decideRoomType(parent, retry, nestLevel):
	var roomInstance
	if rng.randi_range(0,1000)>(1000-departmentStoreChance\
	-GameManager.network.goodModifier*3):
		roomInstance = _department_store.instantiate()
	elif rng.randi_range(0,1000)>(1000-longConfusingRoomChance\
	-GameManager.network.goodModifier*5)\
	and nestLevel<nestLimit*.7 and nestLevel>nestLimit*.2:
		roomInstance = _long_confusing_room.instantiate()
	elif rng.randi_range(0,1000)>(1000-bigRoomChance\
	-GameManager.network.goodModifier*10):
		roomInstance = _big_room.instantiate()
	else:
		roomInstance = _test_room.instantiate()
	return roomInstance

func generateRoomChild(parentRoom ,parentEntrance,nestLevel,retry):
	#await get_tree().physics_frame
	if nestLevel>nestLimit:
		#print("Hit the nest limit")
		return
	#print("Attempting to generate child room "+str(rooms.size()))
	var roomInstance = decideRoomType(parentRoom,retry,nestLevel)
	roomInstance.appendEntrancesToGroup()
	roomInstance.segregateEntrances()
	roomInstance.sceneRoot = self
	rooms.append(roomInstance)
	roomInstance.parentEntrance = parentEntrance
	roomInstance.parentRoom = parentRoom
	roomInstance.name = "ChildRoom"+str(rooms.size()-1)
	roomInstance.nestLevel = nestLevel
	get_node("RootRoom").add_child(roomInstance)
	roomInstance.rotateRoom(rng.randi_range(0,3))
	#await get_tree().physics_frame
	#var direction = (Vector3(parentEntrance.opening.global_position.x-parentEntrance.forwardsOffset,0,parentEntrance.opening.global_position.z-parentEntrance.sidewaysOffset)-parentEntrance.get_parent().get_parent().global_position)
	#direction.y = 0
	#direction = direction.normalized()
	#print("Direction: "+str(direction))
	#################################### POSITION OF NEWLY SPAWNED CHILD ROOM!
	var connectingEntrance = roomInstance.getRandomEntranceOfDirection(parentEntrance.direction)
	print (connectingEntrance.notes)
	roomInstance.connectingEntrance = connectingEntrance
	roomInstance.initializeRoom()
	#original position algorithm based on offset variables
	#roomInstance.global_position = Vector3(parentEntrance.forwardsOffset,parentEntrance.heightOffset,parentEntrance.sidewaysOffset)-Vector3(connectingEntrance.forwardsOffset,connectingEntrance.heightOffset,connectingEntrance.sidewaysOffset)+parentRoom.global_position+direction*(roomInstance.get_node("RoomOuter").size.x/2+parentRoom.get_node("RoomOuter").size.x/2)
	#new position algorithm based on space
	roomInstance.global_position = \
		Vector3(parentEntrance.opening.global_position.x-parentRoom.global_position.x,\
		parentEntrance.heightOffset,\
		parentEntrance.opening.global_position.z-parentRoom.global_position.z)\
		-Vector3(connectingEntrance.opening.global_position.x-roomInstance.global_position.x,\
		connectingEntrance.heightOffset,\
		connectingEntrance.opening.global_position.z-roomInstance.global_position.z)\
		+parentRoom.global_position
	await get_tree().physics_frame
	#testing to see if room already exists
	for overlappingArea in roomInstance.roomBoundaries.get_overlapping_areas():
		#parentEntrance.hasConnection = false
		#parentEntrance.visible = false
		#parentEntrance.active = false
		if !overlappingArea.name=="RoomBoundaries":
			return
		rooms.erase(roomInstance)
		roomInstance.queue_free()
		await get_tree().physics_frame
		overlappingArea.get_parent().linkRooms(parentRoom,parentEntrance)
		return
	####################################
	#print("at "+str(roomInstance.global_position))
	await get_tree().physics_frame
	timeSinceLastCompletion = 0
	for entrance in roomInstance.entrances:
		if entrance.visible and !entrance.hasConnection:
			await generateRoomChild(roomInstance,entrance,nestLevel+1,false)
	return 0
	
#important function
func removeLooseExits():
	await get_tree().physics_frame
	#print("Attempting to remove loose exits from entrances that lead to nowhere.")
	var i = 0
	#print("Room generation ended on index "+str(rooms.size()))
	while i < rooms.size():
		#print("room"+str(i)+" "+rooms[i].name) 
		for entrance in rooms[i].entrances:
			#break
			if (entranceOverlappingNothing(entrance) or !entrance.hasConnection):
				#print("Removed "+entrance.direction+entrance.notes+" entrance.")
				#entrance.scale = Vector3.ZERO
				#entrance.visible = false
				rooms[i].activeEntranceCount-=1
				print("removing entrance of type "+entrance.notes)
				entrance.queue_free()
		portalPopulation(rooms[i])
		if is_multiplayer_authority():
			ideaPopulation(rooms[i])
		i+=1

func entranceOverlappingNothing(entrance):
	if entrance.area.get_overlapping_areas().size()==0:
		return true
	for area in entrance.area.get_overlapping_areas():
		if area.get_parent().room != entrance.room:
			return false
	return true
