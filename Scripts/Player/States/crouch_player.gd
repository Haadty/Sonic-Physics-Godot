extends PlayerState
class_name CrouchPlayerState

func enter(player: Player):
	player.is_crouch = true
	player.set_bounds(1)

func step(player: Player, delta: float):
	player.handle_gravity(delta)
	
