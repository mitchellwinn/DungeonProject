extends Sprite2D

@export var ideaType: String
var amount = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Spin")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !GameManager.network:
		return
	if GameManager.network.dreamDilatorInUse != "":
		match ideaType:
			"good":
				$Queue.text = str(amount)+"/"+str(GameManager.network.goodIdeaCount)
			"bad":
				$Queue.text = str(amount)+"/"+str(GameManager.network.badIdeaCount)


func _on_plus_pressed():
	match ideaType:
			"good":
				if amount<GameManager.network.goodIdeaCount:
					amount+=1
					GameManager.dreamDilator.queuedIdeas+=1
			"bad":
				if amount<GameManager.network.badIdeaCount:
					amount+=1
					GameManager.dreamDilator.queuedIdeas+=1


func _on_minus_pressed():
	if amount>0:
		amount-=1
		GameManager.dreamDilator.queuedIdeas-=1
