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
var northEntrances: Array
var southEntrances: Array
var eastEntrances: Array
var westEntrances: Array
var entrances: Array
var connectingEntrance
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
@export var fogAmt: float
var activeEntranceCount

func initializeRoom():
	if parentRoom:
		if gateOfHorn:
			gateOfHorn.queue_free()
	propsPopulation()
	if parentEntrance:
		parentEntrance.hasConnection = true
	var strength = 0
	for light in lightsParent.get_children():
		var strengthBoost = 0
		match roomType:
			"DepartmentStore":
				strengthBoost = 0
		strength = sceneRoot.rng.randf_range(-5,5)
		strength = strength + strengthBoost
		if strength<0:
			strength = 0
		if light.is_in_group("led"):
			light.material = light.material.duplicate()
			light.material.set("emission_energy_multiplier", strength*10)
		elif light.is_in_group("light"):
			if strength<0:
				light.queue_free()
			light.light_energy = strength/10
	activeEntranceCount = 0
	while activeEntranceCount<3 and nestLevel<=sceneRoot.nestLimit:
		for entrance in entrances:
			entrance.room = self
			#print(entrance.name)
			if entrance.active:
				continue
			activeEntranceCount += testEntranceGeneration(entrance)
			
	#print("this room has "+str(activeEntranceCount)+" active entrances.")

func propsPopulation():
	if roomType == "BigRoom":
		determineWalls()
		if sceneRoot.rng.randi_range(0,1000)>(1000-50):
			$NB.visible = true

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
		if (entrance.opening.global_position-parentEntrance.opening.global_position).length()>1.5:
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
							entrance.scale = parentEntrance.scale
							entrance.visible = true
							entrance.hasConnection = true
							parentEntrance.hasConnection = true
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
							entrance.scale = parentEntrance.scale
							entrance.visible = true
							entrance.hasConnection = true
							parentEntrance.hasConnection = true
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
							entrance.scale = parentEntrance.scale
							entrance.visible = true
							entrance.hasConnection = true
							parentEntrance.hasConnection = true
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
							entrance.scale = parentEntrance.scale
							entrance.visible = true
							entrance.hasConnection = true
							parentEntrance.hasConnection = true
							#print("matched with parent entrance")
							#print("parent entrance was of type"+" "+parentEntrance.notes)
						return
	#nothing to link to so hide the parent entrance
	#print("failed to link"+" "+parentEntrance.notes+" to the existing room")
	parentEntrance.hasConnection = false
	parentEntrance.scale = Vector3.ZERO
	parentEntrance.visible = false
	
func testEntranceGeneration(entrance):
	if connectingEntrance:
		if connectingEntrance == entrance:
			entrance.visible = true
			if entrance.heightOffset==0 and parentEntrance.heightOffset==0:
				entrance.scale = Vector3(sceneRoot.rng.randf_range(1.0,4.0),10,sceneRoot.rng.randi_range(1,4))
				parentEntrance.scale = entrance.scale
			else:
				parentEntrance.scale = Vector3.ONE
				entrance.scale = Vector3.ONE
			entrance.hasConnection = true
			entrance.active = true
			parentEntrance.hasConnection = true
			#print("matched with parent entrance")
			return 1
	var density = sceneRoot.roomDensity
	if roomType == "LongConfusing":
		density = density*2
	if sceneRoot.rng.randi_range(0,1000)>(1000-density):
		entrance.visible = true
		entrance.scale = Vector3.ONE
		entrance.active = true
		#print("created new entrance")
		return 1
	else:
		entrance.visible = false
		entrance.scale = Vector3.ZERO
		entrance.active = false
		#print("closed off entrance")
		return 0

func segregateEntrances():
	for entrance in entrances:
		match entrance.direction:
			"north":
				northEntrances.append(entrance)
			"south":
				southEntrances.append(entrance)
			"east":
				eastEntrances.append(entrance)
			"west":
				westEntrances.append(entrance)

func getRandomEntranceOfDirection(direction):
	match direction:
		"north":
			return southEntrances[sceneRoot.rng.randi_range(0,southEntrances.size()-1)]
		"south":
			return northEntrances[sceneRoot.rng.randi_range(0,northEntrances.size())-1]
		"east":
			return westEntrances[sceneRoot.rng.randi_range(0,westEntrances.size())-1]
		"west":
			return eastEntrances[sceneRoot.rng.randi_range(0,eastEntrances.size())-1]

func rotateRoom(quadrants):
	match quadrants:
		1:
			rotate(Vector3.UP,-1.5708*quadrants)
			for entrance in entrances:
				match entrance.direction:
					"north":
						entrance.direction = "east"
					"east":
						entrance.direction = "south"
					"south":
						entrance.direction = "west"
					"west":
						entrance.direction = "north"
		2:
			rotate(Vector3.UP,-1.5708*quadrants)
			for entrance in entrances:
				match entrance.direction:
					"north":
						entrance.direction = "south"
					"east":
						entrance.direction = "west"
					"south":
						entrance.direction = "north"
					"west":
						entrance.direction = "east"
		3:
			rotate(Vector3.UP,-1.5708*quadrants)
			for entrance in entrances:
				match entrance.direction:
					"north":
						entrance.direction = "west"
					"east":
						entrance.direction = "north"
					"south":
						entrance.direction = "east"
					"west":
						entrance.direction = "south"
	regroupRooms()
	#print("rotated room by "+str(quadrants)+" quadrants")
	#for entrance in entrances:
		#print(entrance.name+" is now pointing "+entrance.direction)
		
func regroupRooms():
	northEntrances.clear()
	southEntrances.clear()
	eastEntrances.clear()
	westEntrances.clear()
	segregateEntrances()


func _on_room_boundaries_body_entered(body):
	if body == GameManager.activePlayer:
		Utils.setVolumetricFogDensity(fogAmt)
