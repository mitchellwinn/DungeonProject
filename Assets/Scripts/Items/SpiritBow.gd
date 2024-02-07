extends Item


var shootStrength = 0.1

func leftClick():
	if GameManager.activePlayer.stats.usingAbility!="":
		return
	var selectedIdea = 0
	if true:
		if GameManager.activePlayer.stats.ideas.size()>0:
			GameManager.activePlayer.stats.ideas[selectedIdea].rpc("set_behavior","toHand")
		GameManager.activePlayer.stats.usingAbility = "pullBow"
		GameManager.activePlayer.stats.moveSpeedScalar = 0
		while (Input.is_action_pressed("leftClick")):
			if GameManager.activePlayer.stats.ideas.size()>0:
				GameManager.activePlayer.stats.ideas[selectedIdea].rpc("set_behavior","toHand")
			if Input.is_action_just_pressed("scrollup"):
				selectedIdea+=1
				if selectedIdea > GameManager.activePlayer.stats.ideas.size()-1:
					selectedIdea = 0
					GameManager.activePlayer.stats.ideas[GameManager.activePlayer.stats.ideas.size()-1].rpc("set_behavior","orbit")
				else:
					GameManager.activePlayer.stats.ideas[selectedIdea-1].rpc("set_behavior","orbit")
			elif Input.is_action_just_pressed("scrolldown"):
				selectedIdea-=1
				if selectedIdea < 0:
					selectedIdea = GameManager.activePlayer.stats.ideas.size()-1
					GameManager.activePlayer.stats.ideas[0].rpc("set_behavior","orbit")
				else:
					GameManager.activePlayer.stats.ideas[selectedIdea+1].rpc("set_behavior","orbit")
			shootStrength += GameManager.globalPhysicsDelta
			if shootStrength>3:
				shootStrength = 3
			await get_tree().process_frame
		if GameManager.activePlayer.stats.ideas.size()>0:
			GameManager.activePlayer.stats.ideas[selectedIdea].rpc("shoot",GameManager.activePlayer.basis.z+Vector3(0,GameManager.activePlayer.camera.basis.z.y,0),shootStrength*10)
			GameManager.activePlayer.stats.usingAbility = "shootBow"
			GameManager.activePlayer.stats.ideas.erase(GameManager.activePlayer.stats.ideas[selectedIdea])
		else:
			GameManager.activePlayer.stats.usingAbility = "shootBow"
		await get_tree().create_timer(.55).timeout
	GameManager.activePlayer.stats.usingAbility = ""
	GameManager.activePlayer.stats.moveSpeedScalar = 1
