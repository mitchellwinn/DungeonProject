extends NavigationObstacle3D


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().physics_frame
	if GameManager.dungeonExists:
		return
	if $Area3D.get_overlapping_areas().size()>0:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
