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
