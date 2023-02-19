import gg
import sokol.sapp

// handle_mouse_move handles all mouse movements in game.
fn handle_mouse_move(x f32, y f32, mut game Game) {
	if game.state == .playing {
		sapp.lock_mouse(true)

		yaw := (game.mouse_sensitivity * game.g.mouse_dx * 360) / game.width
		game.player.rot.yaw += yaw

		pitch := (game.mouse_sensitivity * game.g.mouse_dy * 360) / game.height
		game.player.rot.pitch += pitch

		if game.player.rot.pitch > 90 {
			game.player.rot.pitch = 90
		} else if game.player.rot.pitch < -90 {
			game.player.rot.pitch = -90
		}

		if game.player.rot.roll > 90 {
			game.player.rot.roll = 90
		} else if game.player.rot.roll < -90 {
			game.player.rot.roll = -90
		}
		// println(game.player.rot)
	} else {
		sapp.lock_mouse(false)
	}
}

// handle_key_down sets the key down to true in game.
fn handle_key_down(key gg.KeyCode, mod gg.Modifier, mut game Game) {
	game.key_is_down[key] = true
}

// handle_key_up sets the key down to false in game.
fn handle_key_up(key gg.KeyCode, mod gg.Modifier, mut game Game) {
	game.key_is_down[key] = false
}

// NOTE: this does not seem to activate on unfocus like it's suppose to.
// Might just be a Windows thing. I have yet to test on another machine.
fn handle_unfocus(evt &gg.Event, mut game Game) {
	game.key_is_down = map[gg.KeyCode]bool{}
}
