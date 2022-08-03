# Air.gd
extends PlayerState


# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	if msg.has("do_jump"):
		player.y_velo = player.JUMP_FORCE


func physics_update(delta: float) -> void:
	# Vertical movement. first to add to movement	
	player.y_velo -= player.GRAVITY
	if player.y_velo < -player.MAX_FALL_SPEED:
		player.y_velo = -player.MAX_FALL_SPEED
	# Horizontal movement.
	var input_vec: Vector3 = player.get_input_vec()
	player.do_facing(input_vec)
	player.do_movement(input_vec, player.AIR_ACCELERATION, player.AIR_SPEED_MOD, Vector3.ZERO, true)

	# Landing.
	if player.is_grounded():
		if is_equal_approx(input_vec.length(), 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
