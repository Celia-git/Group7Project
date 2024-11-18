extends CharacterBody2D

const SPEED = 100.0								# Sets the player's run speed
const ATTACK_DIST = 50.0
@onready var sprite = $AnimatedSprite2D			# Used for animation purposes
var health = 100
var last_direction="up"

# Adds the player to the appropriate group so it will be recognized by enemies.
func _ready():
	add_to_group("player")

func _physics_process(delta: float) -> void:	# Runs every frame, essentially handling most player logic.
	$ProgressBar.value = health		# Update the health bar.
	
	#Player died
	if health <= 0:	
		$AnimatedSprite2D.visible=false
		$ProgressBar.visible=false
		$GameOver.visible=true
	elif (sprite.is_playing() and sprite.animation == "attack"):	# If the player is attacking, prevent further movement.
		velocity = Vector2.ZERO
	elif (Input.is_action_just_pressed("ui_select")):	# Sets the spacebar as the attack button.
		attack()
	else:
		basic_movement() # If the player has health and isn't attacking, let the basic_movement function handle controls.
	move_and_slide()	# Move the player character in accordance with the previous lines.

func attack():
	sprite.play("attack")	# If the attack button is pressed, play the attack animation.
	
	# Check every node in the parent scene to see if it is an enemy and if it is close to the player.
	# If so, kill the enemy.
	for node in get_parent().get_children():
		if node.is_in_group("enemy") and abs(position.distance_to(node.position)) < ATTACK_DIST:
			node.sprite.play("die")	# Play the death animation.
			await get_tree().create_timer(1.5).timeout # Allow the animation to finish before killing the enemy.
			node.dead = true
			
func basic_movement():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")	# Check arrow key input.
	direction = direction.normalized()		# Standardizes speed.
	velocity = direction * SPEED	# Determine the player's velocity.
	
	# Animate the player's movement.
	if direction.x < 0:
		sprite.play("run_left")
		last_direction="left"
	elif direction.x > 0:
		sprite.play("run_right")
		last_direction="right"
	elif direction.y > 0:
		sprite.play("run_down")
		last_direction="down"
	elif direction.y < 0:
		sprite.play("run_up")
		last_direction="up"
	else:						# If the player isn't moving, play the idle animation.
		sprite.play("idle_"+last_direction)
			
