extends Node

@export var dreamDilatorInUse: String
@export var ideaQuota: int
@export var dreamTimer: float 
@export var dreamSequence: int
var dreamLength = 60*7

#idea storage
@export var goodIdeaCount: int
@export var badIdeaCount: int
#

#ideas spent on generation
@export var goodModifier: int
@export var badModifier: int
#

@export var dungeonLive: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.network = self
	if !is_multiplayer_authority():
		return
	initialize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_multiplayer_authority():
		return
	if GameManager.dungeonExists:
		dreamTimer+=delta
	if dreamTimer>dreamLength*.1 and dreamSequence == 0:
		dreamSequence+=1
		var track = RandomNumberGenerator.new().randi_range(1,3)
		rpc("rpcBGM",track)
	if dreamTimer>=dreamLength:
		rpc("rpcAbort",ideaQuota)

@rpc ("any_peer","call_local","reliable")
func rpcBGM(track):
	$BGM.stream = load("res://Assets/Music/ambient#"+str(track)+".mp3")
	$BGM.play()

@rpc ("any_peer","call_local","reliable")
func rpcDreamDilatorUsage(id):
	dreamDilatorInUse = id
	
@rpc ("any_peer","call_local","reliable")
func rpcResetDilatorOptions():
	GameManager.dreamDilator.queuedIdeas = 0
	var ideaIcons = get_tree().get_nodes_in_group("ideaIcon")
	for icon in ideaIcons:
		icon.amount = 0

@rpc ("any_peer","call_local", "reliable")
func rpcActivate(goodModifier,badModifier):
	GameManager.network.badModifier = badModifier
	GameManager.network.badIdeaCount -= badModifier
	GameManager.dungeon.generationMain()
	GameManager.network.dungeonLive = true
	GameManager.network.dreamTimer = 0
	GameManager.network.goodModifier = goodModifier
	GameManager.network.goodIdeaCount -= goodModifier
	GameManager.activePlayer.get_node("UI/Main/Message").visible=true
	GameManager.activePlayer.get_node("UI/Main/GenerationMessage").visible=true
	while GameManager.generatingDungeon:
		await get_tree().physics_frame
	GameManager.activePlayer.get_node("UI/Main/Message").visible=false
	GameManager.activePlayer.get_node("UI/Main/GenerationMessage").visible=false

@rpc ("any_peer","call_local", "reliable")	
func rpcAbort(newQuota):
	GameManager.network.ideaQuota = newQuota
	for idea in GameManager.dreamDilator.ideas:
		match idea.ideaType:
			"good":
				GameManager.network.goodIdeaCount+=1
			"bad":
				GameManager.network.badIdeaCount+=1
		idea.queue_free()
	GameManager.dreamDilator.ideas.clear()
	GameManager.dungeon.delete()
	GameManager.network.dungeonLive = false
	GameManager.network.dreamSequence = 0
	GameManager.network.dreamTimer = 0
	if GameManager.activePlayer.global_position.y<-10:
		GameManager.activePlayer.global_position = Vector3(0,5,0)
	for idea in GameManager.activePlayer.stats.ideas:
		idea.queue_free()

func initialize():
	ideaQuota = 3
	goodIdeaCount = 10

