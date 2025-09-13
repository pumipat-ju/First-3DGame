extends CharacterBody3D

signal hit

@export var speed: float = 14
@export var fall_acceleration: float = 75   # m/s^2
@export var jump_impulse: float = 25      # m/s
@export var bounce_impulse: float = 16      # m/s

var target_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO

	# --- Input ---
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at($Pivot.global_transform.origin + Vector3(direction.x, 0.0, direction.z), Vector3.UP)

	# --- Ground velocity ---
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# --- Gravity ---
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		if target_velocity.y < 0.0:
			target_velocity.y = 0.0

	# --- Jump ---
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse

	# --- Move ---
	velocity = target_velocity
	move_and_slide()

	# --- Collisions ---
	for i in range(get_slide_collision_count()):
		var col: KinematicCollision3D = get_slide_collision(i)
		var other = col.get_collider()
		if other == null:
			continue

		if other.is_in_group("mob"):
			# เหยียบจากบน → มอนตาย + ผู้เล่นเด้ง
			if Vector3.UP.dot(col.get_normal()) > 0.1:
				if "squash" in other:
					other.squash()
				target_velocity.y = bounce_impulse
				velocity = target_velocity
				break
			else:
				# ถ้าไม่ใช่เหยียบจากบน (ด้านข้าง/ล่าง) → ผู้เล่นตาย
				die()
				break

func die() -> void:
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body: Node) -> void:
	if body.is_in_group("mob"):
		die()
