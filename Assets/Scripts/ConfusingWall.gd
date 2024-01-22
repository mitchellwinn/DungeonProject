extends CSGBox3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$break.position.x = get_parent().sceneRoot.rng.randi_range(-20,20)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
