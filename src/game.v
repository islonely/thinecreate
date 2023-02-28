import arrays
import gg
import gx
import os
import time
import sokol.sapp
import sokol.sgl
import sokol.gfx
import src.textures
import src.transform { Vector2, Vector3 }

const (
	width       = 1920
	half_width  = width / 2
	height      = 1080
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

	mainmenu        MainMenu
	pausemenu		Menu
	menu_background gg.Image
	logo            gg.Image

	screenshot_path string = './screenshots'
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
		resized_fn: handle_resize
		leave_fn: handle_leave
		window_title: 'ThineDesign'
		width: game.width
		height: game.height
		font_bytes_normal: $embed_file('fonts/maple_mono/fonts/MapleMono-Regular.ttf').to_bytes()
		font_bytes_bold: $embed_file('fonts/maple_mono/fonts/MapleMono-Bold.ttf').to_bytes()
		font_bytes_italic: $embed_file('fonts/maple_mono/fonts/MapleMono-Italic.ttf').to_bytes()
		font_bytes_mono: $embed_file('fonts/maple_mono/fonts/MapleMono-Regular.ttf').to_bytes()
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
	game.chunks << new_chunk(1, Vector3{})

	// Camera does not update until mouse moves, so we want to do it
	// manually the first time before the mouse gets a chance to move.
	mut cam := game.camera()
	cam.on_mouse_move()

	// main menu
	game.menu_background = game.g.create_image_from_byte_array(textures.mainmenu_background_bytes)
	game.logo = game.g.create_image_from_byte_array(textures.logo_bytes)
	game.mainmenu = MainMenu{
		pos: Vector2{
			x: 190
			y: int(game.height / dpi_scale(mut game) - 230)
		}
		items: [
			MenuItem{
				label: 'Singleplayer'
				on_selected: fn [mut game] () {
					game.state = .playing
				}
			},
			MenuItem{
				label: 'Multiplayer'
				clickable: false
				disabled: true
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
			},
		]
	}
	
	// settings menu
	$if debug {
		game.settings.debug = true
	}
	game.settings.menu = Menu{
		step: false
		pos: Vector2{100, 100}
		text_size: 30
		italic: false
		items: [
			MenuItem{
				clickable: false
				disabled: true
				label: 'Resolution: ${game.width}x${game.height}'
				// TODO: Add ability to change resolution.
			},
			MenuItem{
				label: 'Fullscreen: disabled'
				on_selected: fn [mut game] () {
					game.settings.menu.items[1].label = if gg.is_fullscreen() {
						'Fullscreen: disabled'
					} else {
						'Fullscreen: enabled'
					}
					gg.toggle_fullscreen()
				}
			},
			MenuItem{
				label: 'Invert Y Axis: false'
				on_selected: fn [mut game] () {
					game.settings.menu.items[2].label = if game.settings.invert_y_axis == -1 {
						'Invert Y Axis: true'
					} else {
						'Invert Y Axis: false'
					}
					game.settings.invert_y_axis *= -1
				}
			},
			MenuItem{
				label: $if debug { 'Debug Overlay: true' } $else { 'Debug Overlay: false' }
				on_selected: fn [mut game] () {
					game.settings.menu.items[3].label = if game.settings.debug {
						'Debug Overlay: false'
					} else {
						'Debug Overlay: true'
					}
					game.settings.debug = !game.settings.debug
				}
			},
			MenuItem{
				label: 'Back'
				on_selected: fn [mut game] () {
					game.state = .mainmenu
				}
			}
		]
	}

	// pause menu
	game.pausemenu = Menu{
		step: false
		center_horizontal: true
		center_vertical: true
		text_size: 64
		items: [
			MenuItem{
				label: 'Resume'
				on_selected: fn [mut game] () {
					game.state = .playing
				}
			},
			MenuItem{
				label: 'Quit'
				on_selected: fn [mut game] () {
					game.state = .mainmenu
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

// resize refreshes the width and height of the Game and Cameras.
fn (mut game Game) resize() {
	new_size := real_window_size(mut game)
	for mut cam in game.player.cameras {
		cam.width = new_size.width
		cam.height = new_size.height
	}
	game.width = int(new_size.width)
	game.height = int(new_size.height)
	game.half_width = game.width / 2
	game.half_height = game.height / 2
}

// export_screenshot saves a screenshot of the game to the system.
fn (mut game Game) export_screenshot() {
	if !os.exists(game.screenshot_path) {
		os.mkdir(game.screenshot_path) or {
			println('Failed to create screenshot directory.')
			return
		}
	}

	filename := time.now().custom_format('YYYY-MM-DD hh:mm:ss') + '.png'
	path := game.screenshot_path + os.path_separator + filename
	sapp.screenshot(path) or {
		println('Failed to save screenshot.')
		return
	}

	println('Screenshot saved to ${path}.')
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
		.paused { game.pausemenu.update(game.key_is_down, mut game) }
		.playing { game.update_playing() }
		.settings { game.settings.menu.update(game.key_is_down, mut game) }
	}
}

// update_playing updates the game while in GameState.playing.
fn (mut game Game) update_playing() {
	game.player.on_key_down(game.key_is_down, f32(game.delta_time))

	if game.key_is_down[.escape] {
		game.state = .paused
	}

	if game.key_is_down[.f12] {
		game.export_screenshot()
		game.key_is_down[.f12] = false
	}
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
		.paused {
			game.draw_playing()
			game.init_2d()
			game.g.draw_rect_filled(0, 0, (game.width / dpi_scale(mut game)), (game.height / dpi_scale(mut game)), gx.hex(0x111111c0))
			game.pausemenu.draw(mut game)
		}
		.playing {
			game.draw_playing()
		}
		.settings {
			game.init_2d()
			game.settings.draw(mut game)
		}
	}
}

// draw_playing draws the game while in the playing or paused GameState.
fn (mut game Game) draw_playing() {
	game.init_3d()
	game.draw_skybox()
	for mut chunk in game.chunks {
		chunk.draw(mut game)
	}

	game.init_2d()
	game.draw_playing_ui()

	if game.settings.debug {
		game.draw_debug()
	}
}

// draw_playing_ui draws the user interface to the screen
fn (mut game Game) draw_playing_ui() {
	// TODO: switch to draw_filled_rect so we can adjust the line thickness
	{ // draw reticle
		reticle_size := 12
		reticle_color := gx.black
		x := game.half_width / dpi_scale(mut game)
		y := game.half_height / dpi_scale(mut game)
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

	fps := 'FPS: ${game.fps()}'
	pos := 'Position: X: ${int(game.player.pos.x)}, Y: ${int(game.player.pos.y)}, Z: ${int(game.player.pos.z)}'
	facing := 'Facing: ${game.player.facing().str().trim_left('.')}'
	game.g.set_text_cfg(size: size)
	w, mut h := game.g.text_size(pos)
	h *= 3
	h += 3 * padding

	game.g.draw_rounded_rect_filled(15-padding, 15-padding, w+padding*2, h, 5.0, bg)
	game.g.draw_text(15, (row * size + padding), fps,
		size: size
		color: gx.white
	)
	row++
	game.g.draw_text(15, (row * size + padding), pos,
		size: size
		color: gx.white
	)
	row++
	game.g.draw_text(15, (row * size + padding), facing,
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
