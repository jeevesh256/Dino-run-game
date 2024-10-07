extends Node

var mountain = preload("res://mountain.tscn")
var barrel = preload("res://barrel.tscn")
var bird = preload("res://bird.tscn")

const DINO_START_POS := Vector2(224, 488)
const CAM_START_POS := Vector2(576, 324)
const OBSTACLE_WIDTH := 320
const GROUND_WIDTH := 1152
const MAX_CONSECUTIVE_OBSTACLES: int = 1
const GROUND_Y: int = 498
const BIRD_Y: int = 400

var consecutive_obstacles: int = 0
var speed: float
var startSpeed = 5.0
var maxSpeed = 8.0  # Define a maximum speed
var speedIncreaseRate = 0.1  # Rate at which the speed increases
var screenSize: Vector2
var gameRunning: bool = false
var score: int
var obstacles = []

@onready var dino = $dino
@onready var camera_2d = $Camera2D
@onready var ground = $ground
@onready var ground_clone = ground.duplicate()
@onready var hud = $HUD
@onready var gameOver = $gameOver
@onready var bgm = $bgMusic

func _ready():
	screenSize = get_window().size
	add_child(ground_clone)
	ground_clone.position.x = ground.position.x + GROUND_WIDTH
	gameOver.get_node("Button").pressed.connect(_on_button_pressed)
	new_game()

func new_game():
	get_tree().paused = false
	dino.position = DINO_START_POS
	camera_2d.position = CAM_START_POS
	ground.position = Vector2(0, 0)
	ground_clone.position = Vector2(GROUND_WIDTH, 0)
	bgm.play()
	hud.get_node("start").show()
	hud.get_node("gameOver").hide()
	gameOver.hide()
	gameRunning = false
	score = 0
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()

func _process(delta):
	if gameRunning:
		# Gradually increase the speed based on score or time
		speed = startSpeed + (score / 100) * speedIncreaseRate  # You can adjust this formula

		# Ensure speed doesn't exceed maxSpeed
		if speed > maxSpeed:
			speed = maxSpeed

		dino.position.x += speed
		camera_2d.position.x += speed
		
		score += speed
		hud.get_node("score").text = "SCORE: " + str(score / 20)
		
		# Check for high score update
		HighScore.update_high_score(score / 20)  # Update high score based on current score
		
		# Display the high score
		hud.get_node("highScore").text = "HIGH SCORE: " + str(HighScore.get_high_score())

		# Random chance to spawn an obstacle
		if randi() % 100 < 1:
			spawn_obstacle()

		# Move the ground sprite and its clone
		ground.position.x -= speed
		ground_clone.position.x -= speed

		# Loop the ground smoothly
		if ground.position.x + GROUND_WIDTH <= camera_2d.position.x - screenSize.x * 0.5:
			ground.position.x = ground_clone.position.x + GROUND_WIDTH
		
		if ground_clone.position.x + GROUND_WIDTH <= camera_2d.position.x - screenSize.x * 0.5:
			ground_clone.position.x = ground.position.x + GROUND_WIDTH

		# Move all obstacles with the ground
		for obstacle in obstacles:
			obstacle.position.x -= speed

		# Remove obstacles that have moved off-screen
		obstacles = obstacles.filter(func(o): return o.position.x + OBSTACLE_WIDTH > camera_2d.position.x - screenSize.x * 0.5)
		
	else:
		if Input.is_action_pressed("ui_accept"):
			_start_game()

func _start_game():
	if not gameRunning:
		gameRunning = true
		hud.get_node("start").hide()

func spawn_obstacle():
	if consecutive_obstacles >= MAX_CONSECUTIVE_OBSTACLES:
		consecutive_obstacles = 0
		return

	var random_num = randi() % 3
	var instance
	var spawn_y = GROUND_Y

	if random_num == 0:
		instance = mountain.instantiate()
	elif random_num == 1:
		instance = barrel.instantiate()
	else:
		instance = bird.instantiate()
		spawn_y = BIRD_Y

	var spawn_x = camera_2d.position.x + screenSize.x + randi() % 200
	instance.position = Vector2(spawn_x, spawn_y)

	add_child(instance)
	obstacles.append(instance)

	consecutive_obstacles += 1

func game_over():
	gameRunning = false
	hud.get_node("gameOver").show()
	gameOver.show()
	get_tree().paused = true

func _on_button_pressed():
	_restart_game()

func _restart_game():
	get_tree().reload_current_scene()
