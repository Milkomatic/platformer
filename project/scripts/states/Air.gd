# Air.gd
extends PlayerState


# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	player.cam.has_input = true	
	if msg.has("do_jump"):
		player.y_velo = player.JUMP_FORCE
		player.play_anim("jump")
	elif msg.has("do_air_jump") :
		player.y_velo = player.AIR_JUMP_FORCE
		player.spend_stamina(player.AIR_JUMP_STAM_COST)
		player.play_anim("jump")
	elif msg.has("do_wall_jump"):
		player.y_velo = player.V_WALL_JUMP_FORCE
		player.move_vec = msg["wall_normal"] * player.H_WALL_JUMP_FORCE
		player.spend_stamina(player.WALL_JUMP_STAM_COST)


func physics_update(delta: float) -> void:
	# Vertical movement. first to add to movement	
	player.y_velo -= player.GRAVITY
	if player.y_velo < -player.MAX_FALL_SPEED:
		player.y_velo = -player.MAX_FALL_SPEED
	# Horizontal movement.
	var input_vec: Vector3 = player.get_input_vec()
	player.do_momentum_move(input_vec, player.MAX_SPEED, player.AIR_SPEED_MOD, Vector3.ZERO)
	
	if player.stamina > 0 and Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_air_jump = true})
	
	if player.is_on_wall() and not Input.is_action_pressed("crouch"):
		state_machine.transition_to("Wall")
	elif player.stamina > 0 and Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")	
	# Landing. bug: air -> run -> air when jumping
	elif player.is_on_floor():
		if is_equal_approx(input_vec.length(), 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
