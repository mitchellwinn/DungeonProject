extends Node

const player = preload("res://Assets/Prefabs/Player.tscn")

var portalStatic
var activePlayer
var network
var activePlayerName
var teleportCool = 0
var dungeonExists = false
var dreamDilator
var generatingDungeon = false
var dungeon

func _physics_process(delta):
	GameManager.teleportCool-=1
	if activePlayer:
		generalUImanagement()
	
func generalUImanagement():
	if dungeonExists:
		activePlayer.get_node("UI/Main/IdeasCount").visible = true
	else:
		activePlayer.get_node("UI/Main/IdeasCount").visible = false
