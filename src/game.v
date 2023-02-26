import arrays
import gg
import gx
import time
import sokol.sgl
import sokol.gfx

import src.textures

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

	width       int   = width
	half_width  int   = half_width
	height      int   = height
	half_height int   = half_height
	fps_queue   []f32 = []f32{len: 100}

	delta_time   i64
	last_time    i64 = time.now().unix_time_milli()
	current_time i64

	state    GameState = .mainmenu
	settings Settings

	key_is_down KeyDown

	offsetx f32
	offsety f32
	lastx   f32
	lasty   f32

	player &Player
	chunks []&Chunk

	textures map[string][]gfx.Image

	mainmenu MainMenu
	menu_background gg.Image
	logo gg.Image
}

type KeyDown = map[gg.KeyCode]bool

// GameState is all the available states the game can be in.
enum GameState {
	dead
	inventory
	loading
	mainmenu
	paused
	playing
	settings
}

// new_game instantiates a Game and returns a reference to it.
fn new_game() &Game {
	mut game := &Game{
		player: &Player{}
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
		font_bytes_normal: $embed_file('fonts/maple_mono/fonts/MapleMono-Regular.ttf').to_bytes()
	)
	game.player.cameras << new_camera(game.player, game.width, game.height, game.settings.fov)
	return game
}

// init is called before the game starts running.
fn init(mut game Game) {
	println('BEGIN INIT...')
	// disable vsync on Linux
	C._sapp_glx_swapinterval(0)

	{ // initialize pipeline
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

		// pipe_desc.cull_mode = .back
		game.pipeline = sgl.make_pipeline(&pipe_desc)
	}
	game.textures = textures.init()
	game.chunks << new_chunk(1)
	blocks := game.chunks[0].blocks
	println(blocks.len * blocks[0].len * blocks[0][0].len)

	// Camera does not update until mouse moves, so we want to do it
	// manually the first time before the mouse gets a chance to move.
	// mut cam := game.camera()
	// cam.on_mouse_move()

	game.menu_background = game.g.create_image_from_byte_array(textures.mainmenu_background_bytes)
	game.logo = game.g.create_image_from_byte_array(textures.logo_bytes)
	game.mainmenu = MainMenu{
		x: 210
		y: int(game.height/gg.dpi_scale() - 250)
		items: [
			MenuItem{
				label: 'Singleplayer'
				on_selected: fn [mut game] () {
					game.state = .playing
				}
			},
			MenuItem{
				label: 'Multiplayer'
				on_selected: fn () {}
			},
			MenuItem{
				label: 'Settings'
				on_selected: fn [mut game] () {
					game.state = .settings
				}
			},
			MenuItem{
				label: 'Quit'
				on_selected: fn [mut game] () {
					game.g.quit()
				}
			}
		]
	}

	println('END INIT')
}

// fps returns the current frames per second.
[inline]
fn (game Game) fps() int {
	sum := arrays.sum(game.fps_queue) or {
		println(err.msg())
		return -1
	}
	return int(sum) / game.fps_queue.len
}

// update updates the game according to what GameState it's currently in.
fn (mut game Game) update() {
	game.fps_queue.delete(0)
	game.fps_queue << 1000 / f32(game.delta_time)

	match game.state {
		.dead {}
		.inventory {}
		.loading {}
		.mainmenu { game.mainmenu.update(game.key_is_down, mut game) }
		.paused {}
		.playing { game.update_playing() }
		.settings {}
	}
}

// update_playing updates the game while in GameState.playing.
fn (mut game Game) update_playing() {
	game.player.on_key_down(game.key_is_down, f32(game.delta_time))
}

// draw updates the buffered image and draws it to the screen.
fn (mut game Game) draw() {
	match game.state {
		.dead {}
		.inventory {}
		.loading {}
		.mainmenu {
			game.init_2d()
			game.mainmenu.draw(mut game)
		}
		.paused {}
		.playing {
			game.init_3d()
			game.draw_skybox()
			for mut chunk in game.chunks {
				chunk.draw(mut game)
			}
			
			game.init_2d()
			game.draw_playing_ui()
			game.draw_debug()
		}
		.settings {}
	}
}

// draw_playing_ui draws the user interface to the screen
fn (mut game Game) draw_playing_ui() {
	{ // draw reticle
		reticle_size := 12
		reticle_color := gx.black
		x := game.half_width / gg.dpi_scale()
		y := game.half_height / gg.dpi_scale()
		game.g.draw_line(x, (y - reticle_size), x, (y + reticle_size), reticle_color)
		game.g.draw_line((x - reticle_size), y, (x + reticle_size), y, reticle_color)
	}
}

// draw_debug draws a debug menu to the screen
fn (mut game Game) draw_debug() {
	mut row := 0
	padding := 8
	size := 24
	bg := gx.hex(0x00000033)

	game.g.draw_rect_filled(7, 5, 300, 24 * 3 + 6, bg)

	fps := 'FPS: ${game.fps()}'
	game.g.draw_text(10, (row * size + padding), fps,
		size: size
		color: gx.white
	)

	row++
	pos := 'Position: X: ${int(game.player.pos.x)}, Y: ${int(game.player.pos.y)}, Z: ${int(game.player.pos.z)}'
	game.g.draw_text(10, (row * size + padding), pos,
		size: size
		color: gx.white
	)

	facing := 'Facing: ${game.player.facing().str().trim_left('.')}'
	row++
	game.g.draw_text(10, (row * size + padding), facing,
		size: size
		color: gx.white
	)
}

// aspect_ratio returns the aspect ratio of the Game.
[inline]
fn (mut game Game) aspect_ratio() f32 {
	return f32(game.width) / f32(game.height)
}

// perspective
[inline]
fn (mut game Game) perspective() {
	sgl.perspective(sgl.rad(game.camera().fov), game.aspect_ratio(), game.camera().near_plane,
		game.camera().far_plane)
}

// camera returns a reference to the current Camera being used.
[inline]
fn (mut game Game) camera() &Camera {
	return game.player.camera()
}

// draw_skybox draws the sky around the camera.
fn (mut game Game) draw_skybox() {
	sgl.defaults()
	sgl.load_pipeline(game.pipeline)

	sgl.enable_texture()
	sgl.texture(game.textures['misc'][0])
	sgl.push_matrix()

	sgl.matrix_mode_projection()

	// We need custom lookat here so the skybox doesn't move towards or away
	// from the Player, but still rotates.
	mut cam := game.camera()
	cam.perspective()
	// vmft off
	sgl.lookat(0, 0, 0, cam.front.x, cam.front.y, cam.front.z, cam.world_up.x, cam.world_up.y,
		cam.world_up.z)
	// vfmt on

	sgl.matrix_mode_modelview()
	sgl_draw_cube(32)
	sgl.end()

	sgl.pop_matrix()
	sgl.disable_texture()
}

// init_2d allows us to write and draw in 2D space
// without distorting text and shapes with the 3D view.
fn (mut game Game) init_2d() {
	sgl.matrix_mode_projection()
	sgl.load_identity()
	sgl.ortho(0.0, game.camera().width, game.camera().height, 0.0, -1.0, 10.0)
	sgl.matrix_mode_modelview()
	sgl.load_identity()
}

// init_3d allows us to draw in 3D space
// without interfering with the 2D draw functions.
fn (mut game Game) init_3d() {
	sgl.viewport(0, 0, game.camera().width, game.camera().height, true)
	sgl.matrix_mode_projection()
	sgl.load_identity()
	game.camera().perspective()
	sgl.matrix_mode_modelview()
	sgl.load_identity()
}