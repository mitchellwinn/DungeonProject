extends EntityIdle
class_name EntityChase

@export var jawSlot: Node3D

func Enter():
	entity.play_sound("Scream",entity.screamDirectory+str(1)+".mp3",rng.randf_range(.9,1.1))
	pass

func Update(delta: float):
	pass


func Physics_Update(delta: float):
	if entity:
		for target in entity.prioList:
			if (target.global_position-entity.global_position).length()>30:
				entity.prioList.erase(target)
		if entity.prioList.size()==0:
			Transitioned.emit(self,"scan")
			return
		nav.target_position = entity.prioList[0].global_position
		if !entity.get_node("Offensive").is_playing():
			var index = rng.randi_range(2,3)
			entity.play_sound("Offensive",entity.offensiveDirectory+str(index)+".mp3",rng.randf_range(.9,1.1))
		checkEat()
		if (nav.target_position-entity.global_position).length()<1:
			entity.velocity = entity.velocity.lerp(Vector3.ZERO,delta*4)
			return
		direction = nav.get_next_path_position() - entity.global_position
		var target_basis = Basis.looking_at(-Vector3(direction.x,0,direction.z))
		entity.basis = entity.basis.slerp(target_basis, delta*10)
		entity.velocity = entity.velocity.lerp(Vector3(direction.x,entity.velocity.y,direction.z)*move_speed,delta*3)

func checkEat():
	if jawSlot.get_node("EatHitbox").get_overlapping_bodies().size()>0:
		entity.carrying = jawSlot.get_node("EatHitbox").get_overlapping_bodies()[0]
		Transitioned.emit(self,"eat")
