extends Node3D

@export var ideaType: String
@export var collector: Node3D
var orbitAngle = 0
var targetHeight = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_multiplayer_authority():
		return
	$AnimationPlayer.play("Hover")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if collector:
		orbit(delta, collector,1.5,5,targetHeight)

func orbit(delta, target, distance, speed, heightOffset):
	var point = target.global_position+heightOffset*Vector3.UP
	orbitAngle += delta*speed
	global_position = global_position.lerp(point + Vector3(cos(orbitAngle),0, sin(orbitAngle)) * distance,delta*10)

func _on_area_body_entered(body):
	if GameManager.activePlayer:
		if body is CharacterBody3D:
			if !collector:
				rpc("rpcUpdateCollector",GameManager.activePlayer.name)
				set_multiplayer_authority(int(str(body.name)))
				GameManager.activePlayer.stats.ideas.append(self)

@rpc ("any_peer", "call_local", "reliable")
func rpcUpdateCollector(playerName):
	$Get.play()
	for player in GameManager.players.get_children():
		if player.name==playerName and !collector:
			collector = player

@rpc ("any_peer", "call_local", "reliable")
func rpcDepositIdea():
	collector = GameManager.dreamDilator
	targetHeight = 3+GameManager.dreamDilator.ideas.size()*.5
	GameManager.dreamDilator.ideas.append(self)
