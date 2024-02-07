extends Node3D

@export var ideaType: String
@export var collector: Node3D
var orbitAngle = 0
var targetHeight = 1
var behavior = "orbit"
var throwDirection
var shootStrength
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_multiplayer_authority():
		return
	$AnimationPlayer.play("Hover")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if collector:
		match behavior:
			"orbit":
				orbit(delta, collector,1.5,5,targetHeight)
			"toHand":
				global_position = lerp(global_position,collector.leftHandSocket.global_position,delta*15)
			"shoot":
				global_position = global_position + throwDirection*shootStrength*delta
				if $area.get_overlapping_bodies().size()>0:
					if $area.get_overlapping_bodies()[0] != GameManager.activePlayer:
						if $area.get_overlapping_bodies()[0].get_node("stats") and is_multiplayer_authority():
							$area.get_overlapping_bodies()[0].stats.rpc("damage",rng.randi_range(7,15),global_position)
						explode()

func orbit(delta, target, distance, speed, heightOffset):
	var point = target.global_position+heightOffset*Vector3.UP
	orbitAngle += delta*speed
	global_position = global_position.lerp(point + Vector3(cos(orbitAngle),0, sin(orbitAngle)) * distance,delta*10)

func _on_area_body_entered(body):
	if GameManager.activePlayer:
		if body is CharacterBody3D:
			if !collector:
				rpc("rpcUpdateCollector",GameManager.activePlayer.name)
				GameManager.activePlayer.stats.ideas.append(self)
		
func explode():
	$Explode.pitch_scale = randf_range(.9,1.1)
	$Explode.stream = load("res://Assets/SFX/shatter/"+str(randi_range(1,5))+".mp3")
	$Explode.play()
	behavior = ""
	$area.monitoring = false
	$area.visible = false
	$BreakParticles.emitting = true
	await get_tree().create_timer(1.0).timeout
	queue_free()
	

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

@rpc ("any_peer", "call_local", "reliable")	
func set_behavior(behave):
	behavior = behave
	
@rpc ("any_peer", "call_local", "reliable")	
func shoot(direction,speed):
	behavior = "shoot"
	throwDirection = direction
	shootStrength = speed
