import arrays
import gg
import gx
import time
import sokol.sgl
import sokol.gfx

const (
	width       = 1920//1200
	half_width  = width / 2
	height      = 1080//860
	half_height = height / 2
)

// Game is a game.
[heap]
struct Game {
mut:
	g         &gg.Context = unsafe { nil }
	pipeline  sgl.Pipeline
	img       &BufferedImage = unsafe { nil }

	width        int = width
	half_width   int = half_width
	height       int = height
	half_height  int = half_height
	aspect_ratio f32 = f32(width) / f32(height)
	fov f32 = 90
	fps_queue	 []int = []int{len: 100}

	delta_time   i64
	last_time    i64 = time.now().unix_time_milli()
	current_time i64

	state GameState = .playing

	key_is_down map[gg.KeyCode]bool

	mouse_sensitivity f32 = 0.5
	invert_y_axis	  int = -1	// -1 for false, 1 for true
	player            Player

	block Block
	skybox_texture	  gfx.Image
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
	mut game := &Game{}
	// 4 for channels rgba
	game.img = new_bufferedimage(game.width, game.height)
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

// update updates the game according to what GameState it's currently in.
fn (mut game Game) update() {
	game.fps_queue.delete(0)
	game.fps_queue << int(1000 / game.delta_time)

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
	forward_speed := if game.key_is_down[.left_control] {
		game.player.sneak_speed
	} else if game.key_is_down[.left_shift] {
		game.player.run_speed
	} else {
		game.player.walk_forwards_speed
	}
	backwards_speed := if game.key_is_down[.left_control] {
		game.player.sneak_speed
	} else {
		game.player.walk_backwards_speed
	}
	strafe_speed := if game.key_is_down[.left_control] {
		game.player.sneak_speed
	} else {
		game.player.strafe_speed
	}

	// if game.key_is_down[.w] {
	// 	game.player.move_forward(f32(delta) * forward_speed)
	// } else if game.key_is_down[.s] {
	// 	game.player.move_backwards(f32(delta) * backwards_speed)
	// }
	// if game.key_is_down[.a] {
	// 	game.player.move_left(f32(delta) * strafe_speed)
	// } else if game.key_is_down[.d] {
	// 	game.player.move_right(f32(delta) * strafe_speed)
	// }

	mut camera := game.player.cameras[game.player.curr_cam]
	d := f32(game.delta_time)
	
}

// draw updates the buffered image and draws it to the screen.
fn (mut game Game) draw() {
	game.img.zero()
	game.draw_ui()

	// game.gg_image.update_pixel_data(game.img.buffer)
	game.g.draw_image(0, 0, game.width, game.height, game.img.to_ggimage(mut game))

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
					size: 20, color: gx.white)
}

// draw_skybox draws the sky around the camera.
fn (mut game Game) draw_skybox() {
	sgl.defaults()
	sgl.load_pipeline(game.pipeline)
	sgl.enable_texture()
	sgl.texture(game.skybox_texture)
	sgl.push_matrix()
	sgl.translate(0,0,0)
	game.player.cameras[game.player.curr_cam].sgl()
	sgl.matrix_mode_modelview()
	sgl_draw_cube(16)
	sgl.pop_matrix()
	sgl.disable_texture()
}