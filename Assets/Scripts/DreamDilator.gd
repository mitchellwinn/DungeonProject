extends Interactable

var ideas: Array
@export var queuedIdeas: int

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.dreamDilator = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func interact():
	print("interact function called")
	if GameManager.activePlayer.stats.ideas.size()>0:
		await depositIdeas()
	elif GameManager.network.dreamDilatorInUse == "":
		GameManager.network.rpc("rpcDreamDilatorUsage",GameManager.activePlayer.name)
		while GameManager.network.dreamDilatorInUse != GameManager.activePlayer.name:
			await get_tree().physics_frame
		await useDreamDilator()
		#await get_tree().physics_frame
	return false

func depositIdeas():
	for idea in GameManager.activePlayer.stats.ideas:
		idea.rpc("rpcDepositIdea")
		idea.set_multiplayer_authority(int(1))
		await get_tree().create_timer(.35).timeout
	GameManager.activePlayer.stats.ideas.clear()
	
func useDreamDilator():
	print("using dilator")
	GameManager.activePlayer.get_node("UI/Main").visible = false
	GameManager.activePlayer.get_node("UI/DreamDilator").visible = true
	GameManager.activePlayer.camera.current = false
	if GameManager.dungeonExists:
		await inDream()
	elif !GameManager.dungeonExists:
		await outDream()
	print("done using dilator")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.activePlayer.camera.current = true
	$Camera3D.current = false
	$Camera3D2.current = false
	GameManager.activePlayer.get_node("UI/Main").visible = true
	GameManager.activePlayer.get_node("UI/DreamDilator").visible = false
	GameManager.network.rpc("rpcDreamDilatorUsage","")
	
func inDream():
	var looping = true
	$Camera3D.current = true
	GameManager.activePlayer.get_node("UI/DreamDilator/InDream").visible = true
	while looping and GameManager.network.dreamDilatorInUse == GameManager.activePlayer.name:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		await get_tree().physics_frame
		if Input.is_action_just_pressed("interact"):
			looping = false
	GameManager.activePlayer.get_node("UI/DreamDilator/InDream").visible = false
func outDream():
	var looping = true
	$Camera3D2.current = true
	GameManager.activePlayer.get_node("UI/DreamDilator/OutDream").visible = true
	while looping  and GameManager.network.dreamDilatorInUse == GameManager.activePlayer.name:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		await get_tree().physics_frame
		if queuedIdeas>=GameManager.network.ideaQuota:
			GameManager.activePlayer.get_node("UI/DreamDilator/OutDream/Activate").visible = true
		else:
			GameManager.activePlayer.get_node("UI/DreamDilator/OutDream/Activate").visible = false
		if Input.is_action_just_pressed("interact"):
			looping = false
	GameManager.activePlayer.get_node("UI/DreamDilator/OutDream").visible = false
