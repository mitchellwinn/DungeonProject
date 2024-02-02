extends CharacterBody3D

const MOVE_SPEED = 1
const MAX_SPEED = 20
const JUMP_POWER = 15
const FALL_SPEED = 50
const TURN_SPEED = 1
const DRAG = 10
var mouseDelta: Vector2
var runToggle = 1
var moveDirection = Vector3.ZERO
var velocityLast
var interacting = false
@export var inDungeon: bool
@export var camera: Camera3D
@export var camContainer: Node3D
@export var stats: Node
@export var skeleton: Skeleton3D
@export var animator: AnimationPlayer
@export var headSocket: Node3D
@export var torsoSocket: BoneAttachment3D
var rng 

func _ready():
	velocityLast = velocity
	global_position=Vector3(0,1,0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	$VOIP.set_multiplayer_authority(name.to_int())
	if !is_multiplayer_authority():
		$UI.visible = false
		$NameTag.set_layer_mask_value(3,false)
		$NameTag.set_layer_mask_value(4,true)
		for mesh in skeleton.get_children():
			if mesh is BoneAttachment3D:
				continue
			mesh.set_layer_mask_value(3,false)
			mesh.set_layer_mask_value(4,true)
		camera.current = false
		$OmniLight3D.visible = false
		$SpotLight3D.visible = false
	else:
		stats.ign = GameManager.activePlayerName
		camera.current = true
		GameManager.activePlayer = self
	
func _process(delta):
	if !GameManager.activePlayer:
		return
	$NameTag.text = stats.ign
	$NameTag.global_transform.basis = get_viewport().get_camera_3d().global_transform.basis

func _physics_process(delta):
	if stats.bleeding and !stats.bleedingLast:
		bleedAnimate(true)
	elif !stats.bleeding and stats.bleedingLast:
		bleedAnimate(false)
	if !is_multiplayer_authority():
		animateRemote()
		return
	if Input.is_action_just_pressed("tab") and GameManager.network.dreamDilatorInUse == "":
		match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	checkRun()
	jump()
	gravity(delta)
	if playerFocus() and fullyActionable():
		moveInputs(delta)
		checkInteract()
	if true:#DRAG
		velocity.x = lerpf(velocity.x,0.0,clamp(delta*DRAG,0,1))
		velocity.z = lerpf(velocity.z,0.0,clamp(delta*DRAG,0,1))
		#print("velocity: "+str(velocity))
	velocityLast = velocity
	move_and_slide()
	mouseDelta = Vector2.ZERO
	animate(delta)

func bleedAnimate(on):
	torsoSocket.get_node("Blood1").emitting = on
	torsoSocket.get_node("Blood2").emitting = on
	torsoSocket.get_node("Blood3").emitting = on

func checkInteract():
	if interacting:
		return
	if camera.get_node("InteractCast").is_colliding():
		$UI/Main/Target.text = "[center]\n"+camera.get_node("InteractCast").get_collider().displayName
		if Input.is_action_just_pressed("interact"):
			print("interact")
			interacting = true
			interacting = await camera.get_node("InteractCast").get_collider().interact()
	else:
		$UI/Main/Target.text = ""
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and fullyActionable(): 
		mouseDelta.x = event.relative.x
		mouseDelta.y = event.relative.y
	
func checkRun():
	if Input.is_action_pressed("run"):
		runToggle = 1.75
	else:
		runToggle = 1

func jump():
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y+=JUMP_POWER
		

func gravity(delta):
	if !is_on_floor() and !stats.grappled:
		velocity.y-=delta*FALL_SPEED
		
func moveInputs(delta):
	rotation.y -= mouseDelta.x * TURN_SPEED * delta
	camera.rotation.x+=(-mouseDelta.y * TURN_SPEED * delta)
	moveDirection = Vector3.ZERO
	if camera.rotation.x > 1.1 :
		camera.rotation.x = 1.1
	elif camera.rotation.x < -1.1 :
		camera.rotation.x = -1.1
	if Input.is_action_pressed("forward"):
		moveDirection += basis.z
	if Input.is_action_pressed("back"):
		moveDirection -= basis.z
	if Input.is_action_pressed("right"):
		moveDirection -= basis.x
	if Input.is_action_pressed("left"):
		moveDirection += basis.x
	moveDirection = moveDirection.normalized()
	velocity += moveDirection*runToggle*delta*60
	velocity.x = clamp(velocity.x,-MAX_SPEED,MAX_SPEED)
	velocity.z = clamp(velocity.z,-MAX_SPEED,MAX_SPEED)
		
func playerFocus():
	match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				return true
			Input.MOUSE_MODE_HIDDEN:
				return true
			Input.MOUSE_MODE_VISIBLE:
				return false
	
func fullyActionable():
	if !interacting and !GameManager.generatingDungeon and !stats.grappled:
		return true
	
func animate(delta):
	camera.global_position = camera.global_position.lerp(headSocket.global_position,delta*60)
	#camContainer.global_rotation = camContainer.global_rotation.lerp(headSocket.global_rotation,delta*20)
	if stats.grappled:
		stats.animSpeed = 2
		stats.baseAnimation = "flailing"
	elif is_on_floor():
		if velocity.length()>MOVE_SPEED*1 and runToggle>1:
			if basis.z.dot(velocity.normalized())>0:
				stats.animSpeed = velocity.length()/3
				stats.baseAnimation = "run"
			else:
				stats.animSpeed = velocity.length()/3
				stats.baseAnimation = "walkBackwards"
		elif velocity.length()>MOVE_SPEED*1:
			if basis.z.dot(velocity.normalized())>0:
				stats.animSpeed = velocity.length()/3
				stats.baseAnimation = "walk"
			else:
				stats.animSpeed = velocity.length()/3
				stats.baseAnimation = "walkBackwards"
		else:
			stats.baseAnimation = "idle"
			stats.animSpeed = 1
	else:
		if velocity.y>=0:
			stats.animSpeed = 1
			stats.baseAnimation = "jump"
		else:
			stats.animSpeed = 1
			stats.baseAnimation = "fall"
	animator.play("root|"+stats.baseAnimation,3,stats.animSpeed,false)
	#print(baseAnimation)

func animateRemote():
	animator.play("root|"+stats.baseAnimation,3,stats.animSpeed,false)

func _on_left_footstep_body_entered(body):
	var family = Utils.getFloorType(body)
	if family == "silent":
		return
	var roll = rng.randi_range(1,9)
	$LeftFootstep.stream = load("res://Assets/SFX/footsteps/"+family+"/"+str(roll)+".mp3")
	if !$LeftFootstep.is_playing():
		$LeftFootstep.play()


func _on_right_footstep_body_entered(body):
	var family = Utils.getFloorType(body)
	if family == "silent":
		return
	var roll = rng.randi_range(1,9)
	$RightFootstep.stream = load("res://Assets/SFX/footsteps/"+family+"/"+str(roll)+".mp3")
	if !$RightFootstep.is_playing():
		$RightFootstep.play()
