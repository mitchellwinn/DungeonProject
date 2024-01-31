extends Node


@export var ign: String
var id: int
@export var baseAnimation: String
@export var animSpeed: float
@export var ideas: Array
@export var MAX_HP: int
@export var current_hp: int

# Called when the node enters the scene tree for the first time.
func _ready():
	current_hp = MAX_HP

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent() != GameManager.activePlayer:
		return
	
@rpc("any_peer", "call_local")
func damage(amount):
	if !get_parent().is_multiplayer_authority():
		return #only lower HP for client controlling character
	current_hp-=amount
	
func die():
	pass
