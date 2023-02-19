module main

import gg
import time
import sokol.gfx
import sokol.sgl

fn main() {
	mut game := new_game()
	game.g.run()
}

// Disables vsync, but only works on linux
[if linux]
fn C._sapp_glx_swapinterval(int)

// init is called before the game starts running.
fn init(mut game Game) {
	println('BEGIN INIT...')
	// disable vsync on Linux
	C._sapp_glx_swapinterval(0)

	// initialize pipeline
	game.init_flag = true
	mut pipe_desc := gfx.PipelineDesc{}
	unsafe {
		vmemset(&pipe_desc, 0, int(sizeof(pipe_desc)))
	}

	pipe_desc.colors[0] = gfx.ColorState{
		blend: gfx.BlendState{
			enabled: true
			src_factor_rgb: .src_alpha
			dst_factor_rgb: .one_minus_src_alpha
		}
	}

	pipe_desc.depth = gfx.DepthState{
		write_enabled: true
		compare: .less_equal
	}

	pipe_desc.cull_mode = .back
	game.pipeline = sgl.make_pipeline(&pipe_desc)

	// textures
	game.init_textures() or {
		println('Error: failed to load textures.')
		println(err.msg())
		exit(0)
	}

	// temp block
	game.block = new_block(1, 'block_grass', texture_block_grass, x: 0, y: 0)

	// cache buffered image
	game.gg_image = game.g.get_cached_image_by_idx(game.g.new_streaming_image(game.width,
		game.height, 4, gg.StreamingImageConfig{}))

	println('END INIT')
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
