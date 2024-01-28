extends CharacterBody3D
class_name Entity

@export var powerLevel: int
@export var animator: AnimationPlayer
@export var stats: Node
@export var stateMachine: Node

var rng = RandomNumberGenerator.new()

const FALL_SPEED = 50

func _physics_process(delta):
	if is_multiplayer_authority():
		gravity(delta)
		move_and_slide()
		animate(delta)
	else:
		animateRemote()

func gravity(delta):
	if !is_on_floor():
		velocity.y-=delta*FALL_SPEED

func animate(delta):
	if !stateMachine.current_state:
		return
	if is_on_floor():
		if stateMachine.current_state is EntityRoam:
			if velocity.length()>2:
				stats.baseAnimation = "Roam"
				stats.animSpeed = velocity.length()/3
			elif velocity.length()>.5:
				stats.baseAnimation = "Investigate"
				stats.animSpeed = velocity.length()/3
			else:
				stats.baseAnimation = "Idle"
				stats.animSpeed = 1
		elif  stateMachine.current_state is EntityIdle:
			if velocity.length()>.5:
				stats.baseAnimation = "Investigate"
				stats.animSpeed = velocity.length()/2
			else:
				stats.baseAnimation = "Idle"
				stats.animSpeed = 1
	else:
		pass
	animator.play("root|"+stats.baseAnimation,3,stats.animSpeed,false)
	#print(stats.baseAnimation)

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
