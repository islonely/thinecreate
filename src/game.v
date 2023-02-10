import gg
import math
import time

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

	rotation f32
}

enum GameState {
	dead
	inventory
	mainmenu
	pause
	playing
	settings
}

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
		keydown_fn: handle_key_down
		keyup_fn: handle_key_up
		window_title: 'ThineDesign'
		width: game.width
		height: game.height
	)
	$if debug || fps ? {
		game.g.fps.show = true
	}
	return game
}

fn (mut game Game) update(delta i64) {
	match game.state {
		.dead {}
		.inventory {}
		.mainmenu {}
		.pause {}
		.playing {
			game.update_playing(delta)
		}
		.settings {}
	}
}

fn (mut game Game) update_playing(delta i64) {
	game.rotation += 0.0001 * f32(delta)
}

[direct_array_access]
fn (mut game Game) draw() {
	for i := 0; i < game.width * game.height; i++ {
		unsafe {
			game.buffer[i] = 0
		}
	}

	game.draw_floor()

	game.buffered_image.update_pixel_data(game.buffer)
	game.g.draw_image(0, 0, game.width, game.height, game.buffered_image)
}

[direct_array_access]
fn (mut game Game) draw_floor() {
	for y in 0..game.height {
		ceiling := math.abs((y - f32(game.height) / 2.0) / f32(game.height))
		z := 8.0 / ceiling
		for x in 0..game.width {
			mut depth := (x - f32(game.width) / 2.0) / game.height
			depth *= z
			xx := int(depth * math.cos(game.rotation) + z * math.sin(game.rotation)) & 15 << 8
			yy := int(z * math.cos(game.rotation) - depth * math.sin(game.rotation)) & 15 << 8
			unsafe {
				game.buffer[x + y * game.width] = (xx * 16) | (-yy * 16) << 8
			}
		}
	}
}