import gg
import math
import sokol.sapp

// handle_mouse_move handles all mouse movements in game.
fn handle_mouse_move(x f32, y f32, mut game Game) {
	if game.state == .playing {
		sapp.lock_mouse(true)
		println('Facing: ${game.player.facing()}')
		println('')

		mut camera := game.player.cameras[game.player.curr_cam]
		yaw := f32(game.delta_time) * game.mouse_sensitivity * game.g.mouse_dx * 360 / camera.width * 0.05
		pitch := f32(game.delta_time) * game.mouse_sensitivity * game.g.mouse_dy * 360 / camera.height * game.invert_y_axis * 0.05

		println('yaw degrees: ${yaw}')
		println(camera.rot.yaw)
		camera.rot.pitch -= pitch
		camera.rot.yaw += if camera.rot.yaw + yaw > 180 {
			-360 + yaw
		} else if camera.rot.yaw + yaw < -180 {
			360 + yaw
		} else {
			yaw
		}

		if game.player.rot.pitch > 90 {
			camera.rot.pitch = 90
		} else if camera.rot.pitch < -90 {
			camera.rot.pitch = -90
		}

		if camera.rot.roll > 90 {
			camera.rot.roll = 90
		} else if camera.rot.roll < -90 {
			camera.rot.roll = -90
		}
		// println(camera.rot)
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
