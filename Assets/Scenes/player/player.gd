extends CharacterBody2D

@export var speed = 100.0
@export var jump_velocity = -300.0
@export var gravity = 600.0

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Apply gravity
	velocity.y += gravity * delta

	# Handle horizontal movement
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		animated_sprite.flip_h = direction < 0 # Flip sprite
		animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		animated_sprite.play("idle")

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		animated_sprite.play("jump") # Play jump animation

	move_and_slide()
