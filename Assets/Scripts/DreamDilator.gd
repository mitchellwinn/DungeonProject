extends Interactable

var ideas: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func interact():
	print("interact function called")
	if GameManager.activePlayer.stats.ideas.size()>0:
		for idea in GameManager.activePlayer.stats.ideas:
			GameManager.activePlayer.stats.ideas.erase(idea)
			idea.collector = self
			idea.targetHeight = 3+ideas.size()*.5
			ideas.append(idea)
			idea.set_multiplayer_authority(int(1))
			await get_tree().create_timer(.35).timeout
	elif GameManager.dungeonExists and GameManager.network.dreamDilatorInUse == "":
		GameManager.network.rpcDreamDilatorUsage(GameManager.activePlayer.name)
		await useDreamDilator()
	await get_tree().physics_frame
	return false	

func useDreamDilator():
	print("using dilator")
	var looping = true
	while looping:
		GameManager.activePlayer.get_node("UI").visible = false
		$Camera3D.current = true
		GameManager.activePlayer.camera.current = false
		await get_tree().physics_frame
		if Input.is_action_just_pressed("interact"):
			looping = false
	print("done using dilator")
	GameManager.activePlayer.camera.current = true
	$Camera3D.current = false
	GameManager.activePlayer.get_node("UI").visible = true
	GameManager.network.rpcDreamDilatorUsage("")
