module main

import gg
import time

fn main() {
	mut game := new_game()
	game.g.run()
}

// Disables vsync, but only works on linux
[if linux]
fn C._sapp_glx_swapinterval(int)

// init is called before the game starts running.
fn init(mut game Game) {
	C._sapp_glx_swapinterval(0)

	game.init_textures() or {
		println('Error: failed to load textures.')
		println(err.msg())
		exit(0)
	}
	game.block = new_block(1, 'block_grass', x: half_width, y: half_height)

	game.buffered_image = game.g.get_cached_image_by_idx(game.g.new_streaming_image(game.width, game.height, 4, gg.StreamingImageConfig{}))
}

// frame gets called everytime a new frame is drawn to the screen.
fn frame(mut game Game) {
	game.current_time = time.now().unix_time_milli()
	game.delta_time = game.current_time - game.last_time
	game.last_time = game.current_time

	game.g.begin()
	game.update(game.delta_time)
	game.draw()
	game.g.end()
}