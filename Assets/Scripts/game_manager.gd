extends Node

const player = preload("res://Assets/Prefabs/Player.tscn")

var portalStatic
var activePlayer
var activePlayerName
var teleportCool = 0
var dungeonExists = false

func _physics_process(delta):
	GameManager.teleportCool-=1
