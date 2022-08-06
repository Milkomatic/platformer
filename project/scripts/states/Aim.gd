# Run.gd
extends PlayerState


func enter(_msg := {}) -> void:
	player.cam.spring_length = 1 #tween or anim
	player.Crossheir.visible = true

func physics_update(delta: float) -> void:
	player.play_anim("walk")
	player.do_recover()
	if not player.is_grounded():
		state_machine.transition_to("Air")
		return

	# We move the run-specific input code to the state.
	var input_vec: Vector3 = player.get_input_vec()
	player.do_momentum_move(input_vec, player.MAX_WALK_SPEED, player.WALK_SPEED_MOD)
	player.y_velo = -0.1
	
	player.cam.translate(Vector3(0.2, 0, 0))
	
	if Input.is_action_just_pressed("throw"):
		var target = player.ray_center_cam.get_collision_point()
		var normal = player.ray_center_cam.get_collision_normal()
		var hook = player.hook.instance()
		hook.look_at_from_position(target, player.translation, Vector3(0, 1, 0))
#		hook.look_at(target,  Vector3(0, 1, 0))
#		hook.translation = target + (normal*0.3)
		add_child(hook) 
		
	if Input.is_action_just_released("aim"):
		state_machine.transition_to("Idle")
	elif Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
	elif player.stamina > 0 and Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")		
		
func exit(_msg := {}) -> void:
	player.Crossheir.visible = false	
	player.cam.spring_length = 3 #tween or anim
