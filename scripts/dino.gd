extends CharacterBody2D


const gravity = 4200
const jump = -1500
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var run_col = $runCol
@onready var duck_col = $duckCol
@onready var jump_sound = $jumpSound

func _physics_process(delta):
	velocity.y += gravity * delta
	if is_on_floor():
		if get_parent().gameRunning:
			duck_col.disabled = true
			run_col.disabled = false
			if Input.is_action_pressed("jump"):
				velocity.y = jump
				#jump_sound.play()
			elif Input.is_action_pressed("ui_down"):
				run_col.disabled = true
				duck_col.disabled = false
				animated_sprite_2d.play("duck")
			else:
				animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("jump")
	
	move_and_slide()
