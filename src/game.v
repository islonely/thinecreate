import arrays
import gg
import gx
import time
import sokol.sgl
import sokol.gfx

import bufferedimage as buffered

const (
	width       = 1920 // 1200
	half_width  = width / 2
	height      = 1080 // 860
	half_height = height / 2
)

// Game is a game.
[heap]
struct Game {
mut:
	g        &gg.Context = unsafe { nil }
	pipeline sgl.Pipeline
	img      &buffered.Image = unsafe { nil }

	width        int   = width
	half_width   int   = half_width
	height       int   = height
	half_height  int   = half_height
	aspect_ratio f32   = f32(width) / f32(height)
	fov          f32   = 90
	fps_queue    []int = []int{len: 100}

	delta_time   i64
	last_time    i64 = time.now().unix_time_milli()
	current_time i64

	state GameState = .playing

	key_is_down KeyDown

	mouse_sensitivity f32 = 0.5
	invert_y_axis     int = -1 // -1 for false, 1 for true
	player            Player

	block          Block
	skybox_texture gfx.Image
}

type KeyDown = map[gg.KeyCode]bool

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
	mut game := &Game{}
	// 4 for channels rgba
	game.img = buffered.new(game.width, game.height)
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
	game.player = new_player(new_camera(game.width, game.height, z: 5))
	return game
}

// fps returns the current frames per second.
[inline]
fn (game Game) fps() int {
	sum := arrays.sum(game.fps_queue) or {
		println(err.msg())
		return -1
	}
	return sum / game.fps_queue.len
}

// buffer_to_ggimg converts the BufferedImage at Game.img to gg.Image.
fn (mut game Game) buffer_to_ggimg() gg.Image {
	return game.g.create_image_from_memory(game.img.buffer, (game.img.width * game.img.height * game.img.channels))
}

// update updates the game according to what GameState it's currently in.
fn (mut game Game) update() {
	game.fps_queue.delete(0)
	game.fps_queue << if game.delta_time == 0 {
		game.fps_queue.last()
	} else {
		int(1000 / game.delta_time)
	}
	// I don't think this ^ is working correctly...

	match game.state {
		.dead {}
		.inventory {}
		.mainmenu {}
		.paused {}
		.playing {
			game.update_playing()
		}
		.settings {}
	}
}

// update_playing updates the game while in GameState.playing.
fn (mut game Game) update_playing() {
	game.player.on_key_down(game.key_is_down, f32(game.delta_time))
}

// draw updates the buffered image and draws it to the screen.
fn (mut game Game) draw() {
	game.img.zero()
	game.draw_ui()

	// game.gg_image.update_pixel_data(game.img.buffer)
	game.g.draw_image(0, 0, game.width, game.height, game.buffer_to_ggimg())

	game.g.begin()

	game.draw_skybox()
	game.block.draw(mut game)
	game.draw_debug()

	game.g.end()
}

// draw_ui draws the user interface to the screen
fn (mut game Game) draw_ui() {
	// draw reticle
	reticle_size := 10
	reticle_color := gx.hex(0x333333cc)
	game.img.draw_line(game.half_width, game.half_height - reticle_size, game.half_width,
		game.half_height + reticle_size, reticle_color)
	game.img.draw_line(game.half_width - reticle_size, game.half_height, game.half_width +
		reticle_size, game.half_height, reticle_color)
}

// draw_debug draws a debug menu to the screen
fn (mut game Game) draw_debug() {
	game.g.draw_text(20, 20, 'FPS: ${game.fps()}',
		size: 20
		color: gx.white
	)
}

// draw_skybox draws the sky around the camera.
fn (mut game Game) draw_skybox() {
	sgl.defaults()
	sgl.load_pipeline(game.pipeline)
	sgl.enable_texture()
	sgl.texture(game.skybox_texture)
	sgl.push_matrix()
	sgl.translate(0, 0, 0)
	game.player.cameras[game.player.curr_cam].sgl()
	sgl.matrix_mode_modelview()
	sgl_draw_cube(16)
	sgl.pop_matrix()
	sgl.disable_texture()
}
