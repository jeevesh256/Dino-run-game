# HighScore.gd
extends Node

# Declare the variable to store the high score
var high_score: int = 0

# Function to update the high score
func update_high_score(new_score: int):
	if new_score > high_score:
		high_score = new_score

# Function to get the current high score
func get_high_score() -> int:
	return high_score
