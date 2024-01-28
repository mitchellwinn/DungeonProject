extends State
class_name EntityIdle

@export var move_speed := 3.5
@export var nav: NavigationAgent3D
@export var vocalIndex: int
var direction: Vector3

var random_spot: Vector3
var wander_time: float

func randomize_wander():
	if randf_range(-1,1)>-.75:
		random_spot = entity.global_position+Vector3(randf_range(-20,20), 0, randf_range(-20,20))
		entity.get_node("RayCast3D").global_position = random_spot
		if !entity.get_node("RayCast3D").is_colliding():
			randomize_wander()
			return
	else:
		random_spot = Vector3.ZERO
	vocalIndex = rng.randi_range(1,8)
	entity.get_node("Vocals").stream = load("res://Assets/SFX/ghoul_noises/"+str(vocalIndex)+".mp3")
	wander_time = randf_range(1,4)
	
func Enter():
	randomize_wander()

func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
		
	else:
		randomize_wander()


func Physics_Update(delta: float):
	if entity:
		nav.target_position = Vector3(random_spot.x,entity.global_position.y,random_spot.z)
		if (nav.target_position-entity.global_position).length()<1:
			entity.velocity = entity.velocity.lerp(Vector3.ZERO,delta*4)
			return
		direction = nav.get_next_path_position() - entity.global_position
		var target_basis = Basis.looking_at(-Vector3(direction.x,0,direction.z))
		entity.basis = entity.basis.slerp(target_basis, delta*10)
		entity.velocity = entity.velocity.lerp(Vector3(direction.x,entity.velocity.y,direction.z)*move_speed,delta)
