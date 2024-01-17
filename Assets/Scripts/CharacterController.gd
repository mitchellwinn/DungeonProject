extends CharacterBody3D

const MOVE_SPEED = 1
const MAX_SPEED = 20
const FALL_SPEED = 50
const TURN_SPEED = 1
const DRAG = 10
var mouseDelta: Vector2
var runToggle = 1
var moveDirection = Vector3.ZERO
var velocityLast
@export var camera: Camera3D
@export var camContainer: Node3D
@export var stats: Node
@export var skeleton: Skeleton3D
@export var animator: AnimationPlayer
@export var headSocket: Node3D
var baseAnimation
var rng

func _ready():
	velocityLast = velocity
	global_position=Vector3(0,1,0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	if !is_multiplayer_authority():
		for mesh in skeleton.get_children():
			mesh.set_layer_mask_value(3,false)
			mesh.set_layer_mask_value(4,true)
		camera.current = false
		$OmniLight3D.visible = false
		$SpotLight3D.visible = false
	else:
		stats.ign = GameManager.activePlayerName
		camera.current = true
		GameManager.activePlayer = self
	
func _physics_process(delta):
	$NameTag.text = stats.ign
	$NameTag.global_transform.basis = GameManager.activePlayer.camera.global_transform.basis
	if !is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("tab"):
		match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	checkRun()
	gravity(delta)
	if playerFocus() and fullyActionable():
		moveInputs(delta)
	velocityLast = velocity
	move_and_slide()
	mouseDelta = Vector2.ZERO
	animate(delta)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseDelta.x = event.relative.x
		mouseDelta.y = event.relative.y
	
func checkRun():
	if Input.is_action_pressed("run"):
		runToggle = 1.75
	else:
		runToggle = 1
		
func gravity(delta):
	if !is_on_floor():
		velocity.y-=delta*FALL_SPEED
		
func moveInputs(delta):
	moveDirection = Vector3.ZERO
	rotation.y -= mouseDelta.x * TURN_SPEED * delta
	camera.rotation.x+=(-mouseDelta.y * TURN_SPEED * delta)
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
	if true:#DRAG
		velocity.x = lerpf(velocity.x,0.0,clamp(delta*DRAG,0,1))
		velocity.z = lerpf(velocity.z,0.0,clamp(delta*DRAG,0,1))
		#print("velocity: "+str(velocity))
		
func playerFocus():
	match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				return true
			Input.MOUSE_MODE_HIDDEN:
				return true
			Input.MOUSE_MODE_VISIBLE:
				return false
	
func fullyActionable():
	return true
	
func animate(delta):
	camera.global_position = camera.global_position.lerp(headSocket.global_position,delta*60)
	#camContainer.global_rotation = camContainer.global_rotation.lerp(headSocket.global_rotation,delta*20)
	if is_on_floor():
		if velocity.length()>MOVE_SPEED*1 and runToggle>1:
			if basis.z.dot(velocity.normalized())>0:
				baseAnimation = "run"
				animator.play("root|"+baseAnimation,3,velocity.length()/3,false)
			else:
				baseAnimation = "walkBackwards"
				animator.play("root|"+baseAnimation,3,velocity.length()/3,false)
		elif velocity.length()>MOVE_SPEED*1:
			if basis.z.dot(velocity.normalized())>0:
				baseAnimation = "walk"
				animator.play("root|"+baseAnimation,3,velocity.length()/3,false)
			else:
				baseAnimation = "walkBackwards"
				animator.play("root|"+baseAnimation,3,velocity.length()/3,false)
		else:
			baseAnimation = "idle"
			animator.play("root|"+baseAnimation,3,1,false)
	else:
		pass
	print(baseAnimation)


func getFloorType(floor):
	if floor.is_in_group("carpet"):
		return "carpet"
	if floor.is_in_group("hard") or floor.is_in_group("wood"):
		return "hard"
	else:
		return "silent"

func _on_left_footstep_body_entered(body):
	var family = getFloorType(body)
	if family == "silent":
		return
	var roll = rng.randi_range(1,9)
	$LeftFootstep.stream = load("res://Assets/SFX/footsteps/"+family+"/"+str(roll)+".mp3")
	$LeftFootstep.play()


func _on_right_footstep_body_entered(body):
	var family = getFloorType(body)
	if family == "silent":
		return
	var roll = rng.randi_range(1,9)
	$RightFootstep.stream = load("res://Assets/SFX/footsteps/"+family+"/"+str(roll)+".mp3")
	$RightFootstep.play()
