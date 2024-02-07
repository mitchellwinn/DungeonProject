extends Node
class_name State

@export var entity: CharacterBody3D

var rng = RandomNumberGenerator.new()
signal Transitioned

func Enter():
	pass
	
func Exit():
	pass
	
func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass

@rpc ("any_peer", "call_local", "reliable")
func carry(playerID):
	for player in GameManager.players.get_children():
		if player.stats.id == playerID:
			entity.carrying = player
			entity.carrying.stats.grappled = true
			#entity.get_node("Offensive").stop()
			entity.carrying.stats.bleeding = true

@rpc ("any_peer", "call_local", "reliable")
func drop(playerID):
	for player in GameManager.players.get_children():
		if player.id == playerID:
			entity.carrying = null
			entity.carrying.stats.grappled = false
			#entity.get_node("Offensive").stop()
			entity.carrying.stats.bleeding = false
