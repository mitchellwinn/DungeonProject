extends Interactable

var ideas: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func interact():
	if GameManager.activePlayer.stats.ideas>0:
		for idea in GameManager.activePlayer.stats.ideas:
			GameManager.activePlayer.stats.ideas.erase(idea)
			idea.collector = self
			ideas.append(idea)
			idea.set_multiplayer_authority(int(1))
	elif GameManager.dreamExists and GameManager.network.dreamDilatorInUse == "":
		GameManager.network.rpcDreamDilatorUsage(GameManager.activePlayer.name)
		await useDreamDilator()
	return false	

func useDreamDilator():
	print("using dilator")
	var looping = true
	while looping:
		$Camera3D.current = true
		GameManager.activePlayer.camera.current = false
		await get_tree().physics_frame
		if Input.is_action_just_pressed("interact"):
			looping = false
	print("done using dilator")
	GameManager.activePlayer.camera.current = true
	GameManager.activePlayer.camera.current = false
	GameManager.network.rpcDreamDilatorUsage("")
