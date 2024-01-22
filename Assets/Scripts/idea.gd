extends Node3D

@export var collector: Node3D
var orbitAngle = 0
var targetHeight = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_multiplayer_authority():
		return
	$AnimationPlayer.play("Hover")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if collector:
		orbit(delta, collector,1.5,5,targetHeight)

func orbit(delta, target, distance, speed, heightOffset):
	var point = target.global_position+heightOffset*Vector3.UP
	orbitAngle += delta*speed
	global_position = global_position.lerp(point + Vector3(cos(orbitAngle),0, sin(orbitAngle)) * distance,delta*10)


func _on_area_body_entered(body):
	if !is_multiplayer_authority():
		return
	if GameManager.activePlayer:
		if body == GameManager.activePlayer:
			if !collector:
				collector = GameManager.activePlayer
				set_multiplayer_authority(int(str(body.name)))
				GameManager.activePlayer.stats.ideas.append(self)
