extends EntityIdle
class_name EntityEat

@export var jawSlot: Node3D
var scanTimer = 0

func Enter():
	entity.play_sound("Eat","res://Assets/SFX/dramaticStab.mp3",rng.randf_range(.9,1.1))
	entity.carrying.set_multiplayer_authority(1)
	await get_tree().physics_frame
	randomize_wander()
	print("enter eat state")
	entity.carrying.grappled = true
	entity.get_node("Offensive").stop()
	entity.carrying.stats.bleeding = true
	
func Exit():
	entity.carrying.grappled = false
	entity.carrying.stats.bleeding = false
	entity.carrying.set_multiplayer_authority(entity.carrying.stats.id)

func Physics_Update(delta: float):
	entity.carrying.global_position = entity.carrying.global_position.lerp(jawSlot.global_position,delta*5)
	entity.carrying.global_rotation = jawSlot.global_rotation
	if entity:
		nav.target_position = Vector3(random_spot.x,entity.global_position.y,random_spot.z)
		if (nav.target_position-entity.global_position).length()<1:
			entity.velocity = entity.velocity.lerp(Vector3.ZERO,delta*8)
			return
		direction = nav.get_next_path_position() - entity.global_position
		var target_basis = Basis.looking_at(-Vector3(direction.x,0,direction.z))
		entity.basis = entity.basis.slerp(target_basis, delta*10)
		entity.velocity = entity.velocity.lerp(Vector3(direction.x,entity.velocity.y,direction.z)*move_speed,delta*4)

func bite():
	entity.carrying.stats.damage(5)
