extends Node


@export var ign: String
var id: int
@export var baseAnimation: String
@export var animSpeed: float
@export var ideas: Array
@export var MAX_HP: int
@export var current_hp: int
@export var grappled: bool
@export var stunned: float
@export var bleeding: bool
@export var hotbar:= [null,null,null,null]
@export var hotbarIndex:= 0
@export var usingAbility: String
@export var moveSpeedScalar:=1
@export var stateMachine: Node
var bleedingLast: bool
var hpValue: float

# Called when the node enters the scene tree for the first time.
func _ready():
	current_hp = MAX_HP
	hpValue = 0.0
	if get_parent()!=GameManager.activePlayer:
		return
	$HealthDisplay.play("bleed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bleedingLast = bleeding
	if get_parent() != GameManager.activePlayer:
		return
	stunned -= delta
	if stunned<0:
		stunned = 0
	hpValue = lerp(hpValue,2.0-float(current_hp)/10.0,delta*5)
	scrollHotbar(delta)
	if Input.is_action_just_pressed("drop"):
		if hotbar[hotbarIndex]:
			hotbar[hotbarIndex].drop(get_parent().global_position,get_parent().global_rotation)
			hotbar[hotbarIndex].holderID = -1
			hotbar[hotbarIndex] = null
	updateHotbarUI()
	$HealthDisplay.seek(hpValue)
	
func updateHotbarUI():
	#print("update hotbar")
	var i = 0
	for slot in hotbar:
		if slot is Item:
			#print("slot "+str(i))
			get_parent().get_node("UI/Hotbar").get_children()[i].get_child(0).texture = load(slot.iconPath)
			#print("set icon to viewport slot "+str(i))
		else:
			get_parent().get_node("UI/Hotbar").get_children()[i].get_child(0).texture = null
			#print("can't access what would be slot "+str(i))
		i+=1	

func scrollHotbar(delta):
	if GameManager.activePlayer.stats.usingAbility != "":
		return
	if Input.is_action_just_pressed("scrollup"):
		hotbarIndex+=1
	elif Input.is_action_just_pressed("scrolldown"):
		hotbarIndex-=1
	if hotbarIndex>hotbar.size()-1:
		hotbarIndex=0
	elif hotbarIndex<0:
		hotbarIndex = hotbar.size()-1
	var slots = get_parent().get_node("UI/Hotbar").get_children()
	for child in slots:
		if child == slots[hotbarIndex]:
			child.scale = lerp(child.scale,Vector2(.6,.6),delta*25)
		else:
			child.scale = lerp(child.scale,Vector2(.5,.5),delta*25)

func getItem(item):
	var slot = hotbarIndex
	if hotbar[hotbarIndex] is Item: #has item in hand
		print("slot full")
		var i =0
		for potentialSlot in hotbar:
			if potentialSlot is Item:
				print("slot is not null")
				i+=1
			else:
				print("found null slot")
				hotbar[i] = item
				return true
	else:
		hotbar[hotbarIndex] = item
		return true
	
@rpc("any_peer", "call_local")
func damage(amount,location):
	if get_parent().is_multiplayer_authority():
		current_hp-=amount
		stunned = float(amount)/5.0
		if stateMachine:
			if stateMachine.current_state is EntityChase:
				return
		var direction = (location-get_parent().global_position).normalized()
		var target_basis = Basis.looking_at(-Vector3(direction.x,0,direction.z))
		get_parent().basis = target_basis
		if current_hp<=0:
			die()
	
func die():
	if get_parent() is Entity:
		stateMachine.current_state.Exit()
		moveSpeedScalar = 0
		await get_tree().create_timer(35).timeout 
		get_parent().rpc("despawn")
	for player in GameManager.players.get_children():
		if player.stats.current_hp>0:
			player.camera.position = Vector3(0,3,-1.5)
			player.camera.current = true
		else:
			player.camera.position = Vector3(0,2.325,0)
			player.camera.current = false
	for player in GameManager.players.get_children():
		if player.stats.current_hp>0:
			return
	#all players are dead
	GameManager.network.rpcAbort(GameManager.network.ideaQuota)
