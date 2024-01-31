extends State
class_name EntityScan

@export var jawSlot: Node3D
var scanTimer = 0
var potentialTarget

func Enter():
	scanTimer = rng.randf_range(3,8)
	potentialTarget = null
	print("enter scan state")

func Physics_Update(delta: float):
	entity.velocity = entity.velocity.lerp(Vector3.ZERO,delta*8)
	if scanTimer>0:
		scanTimer-=delta
		potentialTarget = Utils.noticedPotentialTarget(jawSlot,GameManager.players.get_children())
		if potentialTarget:
			entity.prioList.append(potentialTarget)
			Transitioned.emit(self,"chase")
	else:
		Transitioned.emit(self,"idle")
