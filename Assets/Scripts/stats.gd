extends Node


@export var ign: String
var id: int
@export var baseAnimation: String
@export var animSpeed: float
@export var ideas: Array
@export var MAX_HP: int
@export var current_hp: int
@export var grappled: bool
@export var bleeding: bool
var bleedingLast: bool
var hpValue: float

# Called when the node enters the scene tree for the first time.
func _ready():
	current_hp = MAX_HP
	hpValue = 0.0
	if get_parent()!=GameManager.activePlayer:
		return
	$HealthDisplay.play("bleed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bleedingLast = bleeding
	if get_parent() != GameManager.activePlayer:
		return
	hpValue = lerp(hpValue,2.0-float(current_hp)/10.0,delta*5)
	$HealthDisplay.seek(hpValue)
	
@rpc("any_peer", "call_local")
func damage(amount):
	if !get_parent().is_multiplayer_authority():
		return #only lower HP for client controlling character
	current_hp-=amount
	if current_hp<=0:
		die()
	
func die():
	get_parent().set_multiplayer_authority(id)
	for player in GameManager.players.get_children():
		if player.stats.current_hp>0:
			return
	#all players are dead
	GameManager.network.rpcAbort(GameManager.network.ideaQuota)
