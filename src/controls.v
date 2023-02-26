import gg
import sokol.sapp

// handle_mouse_move handles all mouse movements in game.
fn handle_mouse_move(x f32, y f32, mut game Game) {
	if game.state == .playing {
		// sapp.show_mouse(false)

		game.offsetx = (game.g.mouse_pos_x - game.lastx) * f32(game.delta_time) * game.settings.mouse_sensitivity
		// Y coords go from bottom to top, so we must reverse
		game.offsety = (game.lasty - game.g.mouse_pos_y) * f32(game.delta_time) * game.settings.mouse_sensitivity * -game.settings.invert_y_axis
		game.lastx, game.lasty = x, y

		mut cam := game.player.camera()
		new_yaw := cam.yaw + game.offsetx
		new_pitch := cam.pitch + game.offsety
		cam.yaw += if new_yaw > 360 {
			game.offsetx - 360
		} else if new_yaw < 0 {
			game.offsetx + 360
		} else {
			game.offsetx
		}

		if new_pitch > 89 {
			cam.pitch = 89
		} else if new_pitch < -89 {
			cam.pitch = -89
		} else {
			cam.pitch = new_pitch
		}
		cam.on_mouse_move()

		{ // wraps mouse to other side of window if it passes
			// a certain threshold.
			// TODO: this ^
		}
	} else {
		sapp.show_mouse(true)
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

// handle_resize
fn handle_resize(evt &gg.Event, mut game Game) {
	game.resize()

	// main menu
	game.mainmenu.pos.y = int(game.height/dpi_scale(mut game) - 230)
	
}