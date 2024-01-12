extends Node3D

var sceneRoot
var parentEntrance #null for root room
var parentRoom
var nestLevel
@export var entrance1: Node3D
@export var entrance2: Node3D
@export var entrance3: Node3D
@export var entrance4: Node3D
@export var entrance5: Node3D
@export var entrance6: Node3D
@export var entrance7: Node3D
@export var entrance8: Node3D
var entrances: Array
@export var lightsParent: Node3D
@export var roomBoundaries: Area3D
@export var roomType: String
@export var wall1: CSGBox3D
@export var wall2: CSGBox3D
@export var wall3: CSGBox3D
@export var gateOfHorn: Node3D
@export var gateOfIvory: Node3D
@export var gateOfHornPortal: Node3D
@export var gateOfIvoryPortal: Node3D

func initializeRoom(root):
	appendEntrancesToGroup()
	if parentRoom:
		if gateOfHorn:
			gateOfHorn.queue_free()
	if roomType == "BigRoom":
		determineWalls()
	if parentEntrance:
		parentEntrance.hasConnection = true
	sceneRoot = root
	for light in lightsParent.get_children():
		light.light_energy = root.rng.randf_range(0,5)
	var activeEntranceCount = 0
	for entrance in entrances:
		#print(entrance.name)
		activeEntranceCount += testEntranceGeneration(entrance)
	#print("this room has "+str(activeEntranceCount)+" active entrances.")

func appendEntrancesToGroup():
	if entrance1:
		entrances.append(entrance1)
	if entrance2:
		entrances.append(entrance2)
	if entrance3:
		entrances.append(entrance3)
	if entrance4:
		entrances.append(entrance4)
	if entrance5:
		entrances.append(entrance5)
	if entrance6:
		entrances.append(entrance6)
	if entrance7:
		entrances.append(entrance7)
	if entrance8:
		entrances.append(entrance8)
	entrances.shuffle()

func determineWalls():
	var wallsInRoom = 3
	while wallsInRoom>2:
		if randi_range(0,10)>5:
			wall1.queue_free()
			wallsInRoom-=1
		if randi_range(0,10)>5:
			wall2.queue_free()
			wallsInRoom-=1
		if randi_range(0,10)>5:
			wall3.queue_free()
			wallsInRoom-=1

func linkRooms(parentRoom,parentEntrance):
	#print("Attempting to link rooms...")
	for entrance in entrances:
		if !parentEntrance.canLinkToOthers:
			continue
		if (entrance.opening.global_position-parentEntrance.opening.global_position).length()>.5:
			continue
		match entrance.direction:
				"north":
					if parentEntrance.direction == "south":
						if entrance.hasConnection:
							var duplicateEntrance = entrance.duplicate()
							entrance.get_parent().add_child(duplicateEntrance)
							duplicateEntrance.global_position.x=parentEntrance.global_position.x
							duplicateEntrance.hasConnection = true
							#print("matched duplicate with parent entrance")
						else:
							entrance.scale = Vector3.ONE
							entrance.visible = true
							entrance.hasConnection = true
							#print("matched with parent entrance")
							#print("parent entrance was of type"+" "+parentEntrance.notes)
						return
				"south":
					if parentEntrance.direction == "north":
						if entrance.hasConnection:
							var duplicateEntrance = entrance.duplicate()
							entrance.get_parent().add_child(duplicateEntrance)
							duplicateEntrance.global_position.x=parentEntrance.global_position.x
							duplicateEntrance.hasConnection = true
							#print("matched duplicate with parent entrance")
						else:
							entrance.scale = Vector3.ONE
							entrance.visible = true
							entrance.hasConnection = true
							#print("matched with parent entrance")
							#print("parent entrance was of type"+" "+parentEntrance.notes)
						return
				"east":
					if parentEntrance.direction == "west":
						if entrance.hasConnection:
							var duplicateEntrance = entrance.duplicate()
							entrance.get_parent().add_child(duplicateEntrance)
							duplicateEntrance.global_position.z=parentEntrance.global_position.z
							duplicateEntrance.hasConnection = true
							#print("matched duplicate with parent entrance")
						else:
							entrance.scale = Vector3.ONE
							entrance.visible = true
							entrance.hasConnection = true
							#print("matched with parent entrance")
							#print("parent entrance was of type"+" "+parentEntrance.notes)
						return
				"west":
					if parentEntrance.direction == "east":
						if entrance.hasConnection:
							var duplicateEntrance = entrance.duplicate()
							entrance.get_parent().add_child(duplicateEntrance)
							duplicateEntrance.global_position.z=parentEntrance.global_position.z
							duplicateEntrance.hasConnection = true
							#print("matched duplicate with parent entrance")
						else:
							entrance.scale = Vector3.ONE
							entrance.visible = true
							entrance.hasConnection = true
							#print("matched with parent entrance")
							#print("parent entrance was of type"+" "+parentEntrance.notes)
						return
	#nothing to link to so hide the parent entrance
	#print("failed to link"+" "+parentEntrance.notes+" to the existing room")
	parentEntrance.hasConnection = false
	parentEntrance.scale = Vector3.ZERO
	parentEntrance.visible = false
	
func testEntranceGeneration(entrance):
	if parentEntrance:
		#creates an entrance to match the entrance leading into the room
		if parentEntrance.opening.global_position.y-entrance.opening.global_position.y<=.5:
			match entrance.direction:
				"north":
					if parentEntrance.direction == "south":
						entrance.visible = true
						entrance.scale = Vector3.ONE
						entrance.hasConnection = true
						#print("matched with parent entrance")
						return 1
				"south":
					if parentEntrance.direction == "north":
						entrance.visible = true
						entrance.scale = Vector3.ONE
						entrance.hasConnection = true
						#print("matched with parent entrance")
						return 1
				"east":
					if parentEntrance.direction == "west":
						entrance.visible = true
						entrance.scale = Vector3.ONE
						entrance.hasConnection = true
						#print("matched with parent entrance")
						return 1
				"west":
					if parentEntrance.direction == "east":
						entrance.visible = true
						entrance.scale = Vector3.ONE
						entrance.hasConnection = true
						#print("matched with parent entrance")
						return 1
	if sceneRoot.rng.randi_range(0,1000)>(1000-sceneRoot.roomDensity):
		entrance.visible = true
		entrance.scale = Vector3.ONE
		#print("created new entrance")
		return 1
	else:
		entrance.visible = false
		entrance.scale = Vector3.ZERO
		#print("closed off entrance")
		return 0
