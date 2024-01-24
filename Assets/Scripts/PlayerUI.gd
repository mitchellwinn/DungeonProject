extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Main/IdeasCount.text = "[center]\n"+str(GameManager.activePlayer.stats.ideas.size())+" IDEAS"
	if GameManager.activePlayer.stats.ideas.size()==1:
		$Main/IdeasCount.text = "[center]\n"+str(GameManager.activePlayer.stats.ideas.size())+" IDEA"
	$DreamDilator/InDream/IdeasCount.text = "[center]\n"+str(GameManager.dreamDilator.ideas.size())+" IDEAS DEPOSITED"
	if GameManager.dreamDilator.ideas.size()==1:
		$DreamDilator/InDream/IdeasCount.text = "[center]\n"+str(GameManager.dreamDilator.ideas.size())+" IDEA DEPOSITED"
	$DreamDilator/OutDream/IdeasCount.text = "[center]"+str(GameManager.network.ideaQuota)+" IDEAS NEEDED TO OPEN GATES" 

#DREAM ACTIVATION
@rpc ("any_peer", "reliable")
func _on_activate_pressed():
	GameManager.network.rpcDreamDilatorUsage("")
	#modifiers
	var goodModifier = 0
	var badModifier = 0
	#modifiers
	for icon in get_tree().get_nodes_in_group("ideaIcon"):
		match icon.ideaType:
			"good":
				goodModifier += icon.amount
			"bad":
				badModifier += icon.amount
	GameManager.dungeon.rpcActivate(goodModifier,badModifier)
	
#DREAM CEASE
func _on_abort_pressed():
	GameManager.network.rpcDreamDilatorUsage("")
	GameManager.dungeon.rpcAbort(GameManager.network.ideaQuota+(GameManager.network.ideaQuota*.5)+5*(GameManager.network.ideaQuota/10))
	GameManager.network.rpcResetDilatorOptions()
