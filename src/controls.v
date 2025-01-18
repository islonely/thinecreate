import gg
import sokol.sapp

// handle_mouse_move handles all mouse movements in game.
fn handle_mouse_move(window_x f32, window_y f32, mut game Game) {
	if game.state == .playing {
		sapp.show_mouse(false)

		game.offsetx = (window_x - game.lastx) * f32(game.delta_time) * game.settings.mouse_sensitivity / 10
		// Y coords go from bottom to top, so we must reverse
		game.offsety = (game.lasty - window_y) * f32(game.delta_time) * game.settings.mouse_sensitivity / 10 * -game.settings.invert_y_axis
		game.lastx, game.lasty = window_x, window_y

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

		{ // wraps mouse to other side of window if it passes a certain threshold.
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

// handle_resize adjusts how the game is rendered when the window size
// changes.
fn handle_resize(evt &gg.Event, mut game Game) {
	game.resize()

	// main menu
	game.mainmenu.pos.y = int(game.height / dpi_scale(mut game) - 230)
}

// handle_leave controls what happens when the mouse pointer leaves
// the area of the window.
fn handle_leave(evt &gg.Event, mut game Game) {
	// don't let the mouse leave the window if the game is being played.
	if game.state == .playing {
		screen_size := gg.screen_size()
		center_x, center_y := screen_size.width / 2, screen_size.height / 2
		game.lastx, game.lasty = center_x, center_y
		// Mouse.set_pos(center_x, center_y)
	}
}
