extends Node

@export var dreamDilatorInUse: String
@export var ideaQuota: int

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
	if !is_multiplayer_authority():
		return
	initialize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc ("any_peer", "reliable")
func rpcDreamDilatorUsage(id):
	dreamDilatorInUse = id
	
@rpc ("any_peer", "reliable")
func rpcResetDilatorOptions():
	GameManager.dreamDilator.queuedIdeas = 0
	var ideaIcons = get_tree().get_nodes_in_group("ideaIcon")
	for icon in ideaIcons:
		icon.amount = 0
	
func initialize():
	ideaQuota = 3
	goodIdeaCount = 10

