extends Node

const player = preload("res://Assets/Prefabs/Player.tscn")

var activePlayer
var activePlayerName
var teleportCool = 0

func _physics_process(delta):
	GameManager.teleportCool-=1
