extends CharacterBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed: int = 10
# Maximum speed of the mob in meters per second.
@export var max_speed: int = 18

# Emitted when the player jumped on the mob
signal squashed

func _physics_process(_delta: float) -> void:
	move_and_slide()

# This function will be called from the Main scene.
func initialize(start_position: Vector3, player_position: Vector3) -> void:
	# Position the mob at start_position and face towards player_position
	look_at_from_position(start_position, player_position, Vector3.UP)

	# Randomly rotate Y within -45 and +45 degrees
	rotate_y(randf_range(-PI / 4.0, PI / 4.0))

	# Calculate a random speed (integer)
	var random_speed: int = randi_range(min_speed, max_speed)

	# Adjust animation playback speed if AnimationPlayer exists
	if has_node("AnimationPlayer"):
		var anim: AnimationPlayer = $AnimationPlayer
		if anim:
			anim.speed_scale = float(random_speed) / float(min_speed)

	# Calculate forward velocity
	velocity = Vector3.FORWARD * random_speed
	# Rotate velocity to match mob's facing direction
	velocity = velocity.rotated(Vector3.UP, rotation.y)

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()

func squash() -> void:
	squashed.emit()
	queue_free() # Destroy this node
