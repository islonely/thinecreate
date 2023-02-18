import gg
import gx
import math
import time
import sokol.sgl

const(
	width = 1200
	half_width = width/2
	height = 860
	half_height = height/2
)

// Game is a game.
[heap]
struct Game {
mut:
	g &gg.Context = unsafe { nil }
	pipeline sgl.Pipeline
	init_flag bool
	img &BufferedImage = unsafe { nil }
	gg_image &gg.Image = unsafe { nil }

	width int = width
	half_width int = half_width
	height int = height
	half_height int = half_height
	aspect_ratio f32 = f32(width) / f32(height)

	delta_time i64
	last_time i64 = time.now().unix_time_milli()
	current_time i64

	state GameState = .playing

	key_is_down map[gg.KeyCode]bool

	mouse_sensitivity f32 = 0.5
	player Player

	textures []&BufferedImage

	block Block

	fov f32 = 60
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
	$if debug || fps ? {
		game.g.fps.show = true
	}
	return game
}

fn (mut game Game) init_textures() ! {
	game.textures << new_bufferedimage_from_bytes($embed_file('./img/block_grass_bottom.png').to_bytes())!
	game.textures << new_bufferedimage_from_bytes($embed_file('./img/block_grass_side.png').to_bytes())!
	game.textures << new_bufferedimage_from_bytes($embed_file('./img/block_grass_top.png').to_bytes())!
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

// clear_buffer sets the pixel buffer to the default value.
// fn (mut game Game) clear_buffer() {
// 	for i := 0; i < game.width * game.height; i++ {
// 		unsafe {
// 			// my numbers are backwards (abgr instead of rgba)
// 			// I think it has something to do with endian, but
// 			// I don't code that low level usually so idk *shrug*
// 			game.buffer[i] = 0xffff9020
// 		}
// 	}
// }

// draw updates the buffered image and draws it to the screen.
fn (mut game Game) draw() {
	game.img.zero()
	
	// game.draw_floor()
	game.draw_ui()

	game.gg_image.update_pixel_data(game.img.buffer)
	game.g.draw_image(0, 0, game.width, game.height, game.gg_image)
	// anything drawn with gg.Context instead of drawing to the pixel buffer must
	// being invoked after this here. I confused myself for a minute, so I'm just
	// leaving a note.
	game.block.draw(mut game)
}

// draw_ui draws the user interface to the screen
fn (mut game Game) draw_ui() {
	// draw reticle
	reticle_size := 10
	reticle_color := gx.hex(0x333333cc)
	game.img.draw_line(game.half_width, game.half_height - reticle_size,
					 game.half_width, game.half_height + reticle_size,
					 reticle_color)
	game.img.draw_line(game.half_width - reticle_size, game.half_height,
					 game.half_width + reticle_size, game.half_height,
					 reticle_color)
}

// draw_floor draw the floor and ceiling to the pixel buffer.
[direct_array_access]
fn (mut game Game) draw_floor() {
	grass := game.textures[2].buffer
	cosine := math.cos(game.player.rot.yaw)
	sine := math.sin(game.player.rot.yaw)
	for y in 0..game.height {
		// temp solution to remove ceiling
		if y < game.height/2 {
			continue
		}

		ceiling := math.abs((y - f32(game.height) / 2.0) / f32(game.height))
		mut z := 16.0 / ceiling
		for x in 0..game.width {
			if z > 400 {
				continue
			}

			mut depth := (x - f32(game.width) / 2.0) / game.height
			depth *= z
			mut xx := int(depth * cosine + z * sine - int(game.player.loc.x))
			mut yy := int(z * cosine - depth * sine + int(game.player.loc.y))

			unsafe {
				game.img.buffer[x + y * game.width] = grass[(xx & 7) + (yy & 7) * 16]
			}
		}
	}
}