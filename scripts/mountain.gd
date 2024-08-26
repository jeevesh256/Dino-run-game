extends Area2D

func _on_body_entered(body):
	if body.name == "dino":
		var game_script = get_node("/root/Node")  # Replace 'Node' with the actual name of your main node
		if game_script.gameRunning:
			game_script.game_over()
