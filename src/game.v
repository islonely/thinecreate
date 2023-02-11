import gg
import math
import time

// Game is a game.
struct Game {
mut:
	g &gg.Context = unsafe { nil }
	buffer &int	= unsafe { nil }	// int for 4 channels: rgba
	buffered_image &gg.Image = unsafe { nil }

	width int
	height int

	delta_time i64
	last_time i64 = time.now().unix_time_milli()
	current_time i64

	state GameState = .playing

	key_is_down map[gg.KeyCode]bool

	mouse_sensitivity f32 = 1.0
	player Player
}

// GameState is all the available states the game can be in.
enum GameState {
	dead
	inventory
	mainmenu
	paused
	playing
	settings
}

// new_game instantiates a Game and returns a reference to it.
fn new_game() &Game {
	mut game := &Game{
		width: 1200
		height: 860
	}
	// 4 for channels rgba
	game.buffer = unsafe {
		malloc(game.width * game.height * 4)
	}
	game.g = gg.new_context(
		user_data: game
		init_fn: init
		frame_fn: frame
		move_fn: handle_mouse_move
		keydown_fn: handle_key_down
		keyup_fn: handle_key_up
		leave_fn: handle_unfocus
		window_title: 'ThineDesign'
		width: game.width
		height: game.height
	)
	$if debug || fps ? {
		game.g.fps.show = true
	}
	return game
}

// update updates the game according to what GameState it's currently in.
fn (mut game Game) update(delta i64) {
	match game.state {
		.dead {}
		.inventory {}
		.mainmenu {}
		.paused {}
		.playing {
			game.update_playing(delta)
		}
		.settings {}
	}
}

// update_playing updates the game while in GameState.playing.
fn (mut game Game) update_playing(delta i64) {
	forward_speed := if game.key_is_down[.left_control] { game.player.sneak_speed }
					 else if game.key_is_down[.left_shift] { game.player.run_speed }
					 else { game.player.walk_forwards_speed }
	backwards_speed := if game.key_is_down[.left_control] { game.player.sneak_speed }
					   else { game.player.walk_backwards_speed }
	strafe_speed := if game.key_is_down[.left_control] { game.player.sneak_speed }
					else { game.player.strafe_speed }

	if game.key_is_down[.w] {
		game.player.move_forward(f32(delta) * forward_speed)
	} else if game.key_is_down[.s] {
		game.player.move_backwards(f32(delta) * backwards_speed)
	}
	if game.key_is_down[.a] {
		game.player.move_left(f32(delta) * strafe_speed)
	} else if game.key_is_down[.d] {
		game.player.move_right(f32(delta) * strafe_speed)
	}
}

// clear_buffer zeros out the pixel buffer.
[direct_array_access; inline]
fn (mut game Game) clear_buffer() {
	for i := 0; i < game.width * game.height; i++ {
		unsafe {
			game.buffer[i] = 0
		}
	}
}

// draw updates the buffered image and draws it to the screen.
fn (mut game Game) draw() {
	game.clear_buffer()
	
	game.draw_floor()

	game.buffered_image.update_pixel_data(game.buffer)
	game.g.draw_image(0, 0, game.width, game.height, game.buffered_image)
}

// draw_floor draw the floor and ceiling to the pixel buffer.
[direct_array_access]
fn (mut game Game) draw_floor() {
	cosine := math.cos(game.player.rot.yaw)
	sine := math.sin(game.player.rot.yaw)
	for y in 0..game.height {
		ceiling := math.abs((y - f32(game.height) / 2.0) / f32(game.height))
		z := 12.0 / ceiling
		for x in 0..game.width {
			if z > 400 {
				continue
			}

			mut depth := (x - f32(game.width) / 2.0) / game.height
			depth *= z
			mut xx := int(depth * cosine + z * sine - int(game.player.loc.x)) & 15 << 8
			mut yy := int(z * cosine - depth * sine + int(game.player.loc.y)) & 15 << 8

			unsafe {
				game.buffer[x + y * game.width] = (xx * 16) | (-yy * 16) << 8
			}
		}
	}
}