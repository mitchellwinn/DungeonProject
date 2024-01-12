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
@export var stats: Node

func _ready():
	velocityLast = velocity
	global_position=Vector3(0,1,0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	if !is_multiplayer_authority():
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

