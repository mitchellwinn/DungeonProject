extends State
class_name EntityIdle

@export var move_speed : int
@export var nav: NavigationAgent3D
@export var vocalIndex: int
var potentialTarget
var direction: Vector3
@export var jawSlot: Node3D

var random_spot: Vector3
var wander_time: float

func randomize_wander():
	if randf_range(-1,1)>-.2:
		random_spot = entity.global_position+Vector3(randf_range(-20,20), 0, randf_range(-20,20))
		entity.get_node("RayCast3D").global_position = random_spot
		await get_tree().physics_frame
		if !entity.get_node("RayCast3D").is_colliding():
			randomize_wander()
			return
	else:
		if !get_parent().current_state is EntityEat:
			Transitioned.emit(self, "scan")
			return
		random_spot = entity.global_position
	vocalIndex = rng.randi_range(1,8)
	if name=="Idle":
		entity.play_sound("Vocals",entity.vocalsDirectory+str(vocalIndex)+".mp3",rng.randf_range(.9,1.1))
	wander_time = randf_range(3,8)
	
func Enter():
	get_parent().get_parent().get_node("ShapeKeys").play("GapingJaws")
	randomize_wander()

func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
		
	else:
		randomize_wander()


func Physics_Update(delta: float):
	if entity:
		potentialTarget = Utils.noticedPotentialTarget(jawSlot,GameManager.players.get_children())
		if potentialTarget:
			entity.prioList.append(potentialTarget)
			Transitioned.emit(self,"chase")
		nav.target_position = Vector3(random_spot.x,entity.global_position.y,random_spot.z)
		if (nav.target_position-entity.global_position).length()<1:
			entity.velocity = entity.velocity.lerp(Vector3.ZERO,delta*8)
			return
		direction = nav.get_next_path_position() - entity.global_position
		var target_basis = Basis.looking_at(-Vector3(direction.x,0,direction.z))
		entity.basis = entity.basis.slerp(target_basis, delta*10)
		entity.velocity = entity.velocity.lerp(Vector3(direction.x,entity.velocity.y,direction.z)*move_speed,delta*8)
		potentialTarget = Utils.noticedPotentialTarget(jawSlot,GameManager.players.get_children())
