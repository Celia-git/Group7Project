extends CharacterBody2D

const SPEED = 70.0			# Enemy movement speed.
const ATTACK_DIST = 30.0	# Distance from which enemy can damage player.
const CHASE_DIST = 80.0	# Distance from which enemy will pursue player.
@onready var sprite = $AnimatedSprite2D		# Helps with animation.
var player		# Keeps track of player for attack purposes.
var dead = false	# Tracks whether or not the enemy is dead.

# Label the character as an enemy to enable player attacks; then designate the player to allow
# enemy attacks.
func _ready() -> void:
	add_to_group("enemy")
	for node in get_parent().get_children():
		if node.is_in_group("player"):
			player = node

func _physics_process(delta: float) -> void:
	if dead:		# If dead, remove visibility, collisions, and movement.
		velocity = Vector2.ZERO
		sprite.visible = false
		$CollisionShape2D.disabled = true
	# If the enemy is dying or attacking, prevent the enemy from performing any other actions.
	elif sprite.is_playing() and (sprite.animation == "die" or sprite.animation == "attack"):
		velocity = Vector2.ZERO
	# If the player exists and is within range, attack the player.
	elif player and abs(position.distance_to(player.position)) < ATTACK_DIST:
		attack()
	# If the player exists and is in sight, pursue the player.
	elif player and abs(position.distance_to(player.position)) < CHASE_DIST:
		chase()
	# If none of the above conditions are true, remain still and play the idle animation.
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")

	move_and_slide()	# Move the enemy character in accordance with the previous instructions.

# To attack, play the attack animation and reduce the player's health.
func attack():
	sprite.play("attack")
	player.health -= 10

# To chace, play the movement animation and move toward the player.
func chase():
	sprite.play("move")
	var direction = (player.position - position).normalized()	# Calculate direction and stabilize speed.
	velocity = SPEED * direction	# Specify the velocity.
