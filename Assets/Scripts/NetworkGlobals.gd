extends Node

@export var dreamDilatorInUse: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc ("reliable")
func rpcDreamDilatorUsage(id):
	dreamDilatorInUse = id
	
