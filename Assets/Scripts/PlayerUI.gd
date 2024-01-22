extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$IdeasCount.text = "[center]\n"+str(GameManager.activePlayer.stats.ideas.size())+" IDEAS"
