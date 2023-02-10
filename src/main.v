module main

import gg
import time

fn main() {
	mut game := new_game()
	game.g.run()
}

// Disables vsync but only works on linux
[if linux]
fn C._sapp_glx_swapinterval(int)

[direct_array_access]
fn init(mut game Game) {
	C._sapp_glx_swapinterval(0)
	game.buffered_image = game.g.get_cached_image_by_idx(game.g.new_streaming_image(game.width, game.height, 4, gg.StreamingImageConfig{}))
}

fn frame(mut game Game) {
	game.current_time = time.now().unix_time_milli()
	game.delta_time = game.current_time - game.last_time
	game.last_time = game.current_time

	game.g.begin()
	game.update(game.delta_time)
	game.draw()
	game.g.end()
}