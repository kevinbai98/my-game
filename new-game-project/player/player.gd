extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var SPEED: float = 150
@export var GRAVITY: float = 900
@export var JUMP_VELOCITY: float = -250

enum PlayerState { IDLE, RUN, JUMP }
var current_state: PlayerState = PlayerState.IDLE

func _ready():
	if sprite == null:
		push_error("ERROR: AnimatedSprite2D not found!")
		return
	sprite.animation_finished.connect(_on_animation_finished)
	print("SpriteFrames animations: ", sprite.sprite_frames.get_animation_names())

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	# Movement input
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	# Flip sprite
	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false

	# Jumping
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		current_state = PlayerState.JUMP
		sprite.play("jump")
		print_debug("Jump triggered")

	# Move
	move_and_slide()

	# --- State update ---
	if not is_on_floor():
		current_state = PlayerState.JUMP
	elif direction != 0:
		current_state = PlayerState.RUN
		
	else:
		current_state = PlayerState.IDLE

	# --- Play animations ---
	match current_state:
		PlayerState.IDLE:
			if sprite.animation != "idle":
				sprite.play("idle")
				print_debug("Playing idle animation")
		PlayerState.RUN:
			if sprite.animation != "run":
				sprite.play("run")
				print_debug("Playing run animation")
		PlayerState.JUMP:
			if sprite.animation != "jump":
				sprite.play("jump")
				print_debug("Playing jump animation")

func _on_animation_finished():
	# Reset after jump ends
	if current_state == PlayerState.JUMP and is_on_floor():
		current_state = PlayerState.RUN if velocity.x != 0 else PlayerState.IDLE
		print_debug("Jump animation finished, new state: ", PlayerState.keys()[current_state])
