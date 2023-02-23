import arrays
import gg
import gx
import math { sin, cos }
import time
import sokol.sgl
import sokol.gfx

import transform { Vector3 }

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

	width        int   = width
	half_width   int   = half_width
	height       int   = height
	half_height  int   = half_height
	fps_queue    []int = []int{len: 100}

	delta_time   i64
	last_time    i64 = time.now().unix_time_milli()
	current_time i64

	state GameState = .playing
	settings Settings

	key_is_down KeyDown

	offsetx			  f32
	offsety			  f32
	lastx 			  f32
	lasty			  f32

	player &Player
	block  Block
	chunk  Chunk

	textures map[string][]gfx.Image
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
	)
	game.player.cameras << new_camera(game.player, game.width, game.height, game.settings.fov, z: -2)
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
	game.g.begin()

	game.draw_ui()
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
	game.g.draw_line(game.half_width, game.half_height - reticle_size, game.half_width,
		game.half_height + reticle_size, reticle_color)
	game.g.draw_line(game.half_width - reticle_size, game.half_height, game.half_width +
		reticle_size, game.half_height, reticle_color)
}

// draw_debug draws a debug menu to the screen
fn (mut game Game) draw_debug() {
	game.g.draw_text(20, 20, 'FPS: ${game.fps()}',
		size: 20
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
	sgl.perspective(sgl.rad(game.camera().fov), game.aspect_ratio(), game.camera().near_plane, game.camera().far_plane)
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
	sgl.lookat(
		0, 0, 0,
		cam.front.x, cam.front.y, cam.front.z,
		cam.world_up.x, cam.world_up.y, cam.world_up.z
	)
	// vfmt on

	sgl.matrix_mode_modelview()
	sgl_draw_cube(32)
	sgl.end()
	
	sgl.pop_matrix()
	sgl.disable_texture()
}
