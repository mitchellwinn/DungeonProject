extends Node3D

@export var itemPath: String

# Called when the node enters the scene tree for the first time.
func _ready():
	while !GameManager.props:
		await get_tree().process_frame
	#print("rdy")
	if !is_multiplayer_authority():
	#	print("not auth")
		return
	var item = load(itemPath).instantiate()
	GameManager.props.add_child(item)
	item.global_position = global_position
	item.global_rotation = global_rotation
	#print("spawned Bow")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
