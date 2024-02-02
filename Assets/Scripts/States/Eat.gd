extends EntityIdle
class_name EntityEat

var scanTimer = 0

func Enter():
	entity.play_sound("Eat","res://Assets/SFX/dramaticStab.mp3",rng.randf_range(.9,1.1))
	entity.carrying.set_multiplayer_authority(1)
	randomize_wander()
	print("enter eat state")
	entity.carrying.stats.grappled = true
	entity.get_node("Offensive").stop()
	entity.carrying.stats.bleeding = true
	
func Exit():
	entity.carrying.stats.grappled = false
	entity.carrying.stats.bleeding = false
	entity.carrying.set_multiplayer_authority(entity.carrying.stats.id)
	entity.carrying = null

func Physics_Update(delta: float):
	if entity:
		entity.carrying.global_position = entity.carrying.global_position.lerp(jawSlot.global_position,delta*5)
		entity.carrying.global_rotation = jawSlot.global_rotation
		if entity.carrying.stats.current_hp <= 0:
			Transitioned.emit(self,"idle")
		nav.target_position = Vector3(random_spot.x,entity.global_position.y,random_spot.z)
		if (nav.target_position-entity.global_position).length()<1:
			entity.velocity = entity.velocity.lerp(Vector3.ZERO,delta*8)
			return
		direction = nav.get_next_path_position() - entity.global_position
		var target_basis = Basis.looking_at(-Vector3(direction.x,0,direction.z))
		entity.basis = entity.basis.slerp(target_basis, delta*10)
		entity.velocity = entity.velocity.lerp(Vector3(direction.x,entity.velocity.y,direction.z)*move_speed,delta*4)

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
	bite(5)
	vocalIndex = rng.randi_range(1,8)
	wander_time = randf_range(3,8)

func bite(dmg):
	entity.carrying.stats.damage(dmg)
