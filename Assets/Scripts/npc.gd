extends Area2D # <-- CHANGED FROM CharacterBody2D

# --- Exported Variables (Tweak in the Inspector) ---
@export var speed: float = 40.0            # Horizontal walking speed
@export var patrol_duration: float = 3.0   # Max time to walk before idling (if no obstacles)
@export var idle_min_time: float = 2.0     # Minimum time to stand still
@export var idle_max_time: float = 5.0     # Maximum time to stand still

# --- State Constants ---
const STATE_IDLE = 0
const STATE_PATROL = 1

# --- Built-in Physics Vars ---
# Removed gravity calculation since Area2D doesn't need it for movement
var current_state: int = STATE_PATROL
var direction: int = 1 # 1 for right, -1 for left

# --- Node References (MUST be added in the scene) ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_timer: Timer = $StateTimer         # Used to control state durations
@onready var ground_check_ray: RayCast2D = $GroundCheckRayCast # Points down/forward
@onready var wall_check_ray: RayCast2D = $WallCheckRayCast     # Points forward

func _ready() -> void:
	# Connect the timer signal to the state transition function
	state_timer.timeout.connect(_on_state_timer_timeout)
	_change_state(STATE_PATROL)

func _physics_process(delta: float) -> void:
	# Apply gravity and move_and_slide are removed!
	
	# Run the current state logic
	match current_state:
		STATE_PATROL:
			_state_patrol(delta)
		STATE_IDLE:
			_state_idle(delta)
			
	# We use position manipulation instead of move_and_slide()
	# Note: Since the NPC doesn't collide, we don't need a physics body
	# to stop it from falling, but we still rely on GroundCheckRayCast 
	# for the wandering logic.

# ----------------------------------------------------
# --- State Management and Transitions ---
# ----------------------------------------------------

func _change_state(new_state: int) -> void:
	current_state = new_state
	
	match current_state:
		STATE_PATROL:
			animated_sprite.play("Walk") # Assumes you have a "Walk" animation
			# Set patrol duration and start the timer
			state_timer.start(patrol_duration)
		STATE_IDLE:
			animated_sprite.play("Idle") # Assumes you have an "Idle" animation
			# Set a random idle duration and start the timer
			var idle_time = randf_range(idle_min_time, idle_max_time)
			state_timer.start(idle_time)
			# Removed velocity.x = 0 as we use position directly now
			
func _on_state_timer_timeout() -> void:
	# Logic to switch to the *other* state when the timer runs out
	if current_state == STATE_PATROL:
		_change_state(STATE_IDLE)
	elif current_state == STATE_IDLE:
		# After idling, switch back to patrol, but first decide which way to go
		# 50/50 chance to switch direction after idling
		if randi() % 2 == 0:
			_turn_around()
		_change_state(STATE_PATROL)

# ----------------------------------------------------
# --- State Logic Functions ---
# ----------------------------------------------------

func _state_patrol(delta: float) -> void: # <-- delta parameter is now used
	# 1. Update visual and directional components (must run every frame)
	animated_sprite.flip_h = direction < 0
	wall_check_ray.scale.x = direction     # Flip RayCasts to point forward
	ground_check_ray.scale.x = direction   # Flip RayCasts to point forward
	
	# 2. Check for walls or cliffs and reverse direction if needed
	if wall_check_ray.is_colliding() or not ground_check_ray.is_colliding():
		_turn_around()
		# Reset the timer when turning due to obstacle,
		# so the NPC gets a fresh patrol duration from the new spot.
		state_timer.start(patrol_duration) 
		
	# 3. Apply movement using global_position directly (since no collision is desired)
	global_position.x += direction * speed * delta

func _state_idle(_delta: float) -> void:
	# Just sits here waiting for the timer to finish
	pass

# ----------------------------------------------------
# --- Helper Function ---
# ----------------------------------------------------

func _turn_around() -> void:
	direction *= -1
