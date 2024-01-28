extends State
class_name EntityRoam

@export var move_speed := 20.0

var move_direction: Vector3
var wander_time: float

func randomize_wander():
	if randf_range(-1,1)>0:
		move_direction = Vector3(randf_range(-1,1), 0, randf_range(-1,1))
	else:
		move_direction = Vector3.ZERO
	wander_time = randf_range(3,5)
	
func Enter():
	randomize_wander()

func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
		
	else:
		randomize_wander()


func Physics_Update(delta: float):
	if entity:
		entity.velocity = entity.velocity.lerp(Vector3(move_direction.x,entity.velocity.y,move_direction.z)*move_speed,delta)
