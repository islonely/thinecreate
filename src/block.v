import sokol.sgl
import sokol.gfx

// Block represents a block in the game.
struct Block {
pub:
	id      int
	name    string
	texture &BufferedImage = unsafe { nil }
mut:
	gfx_texture gfx.Image
pub mut:
	loc Location
}

// new_block instantiates a `Block`.
fn new_block(id int, name string, texture &BufferedImage, loc Location) &Block {
	mut block := &Block{
		id: id
		name: name
		texture: texture
		loc: loc
	}
	block.gfx_texture = bufferedimage_to_gfximage(block.texture, .nearest)
	return block
}

// draw renders the block to the screen
fn (mut block Block) draw(mut game Game) {
	sgl.defaults()
	sgl.load_pipeline(game.pipeline)

	sgl.enable_texture()
	sgl.texture(block.gfx_texture)
	sgl.push_matrix()

	sgl.matrix_mode_projection()
	sgl.perspective(sgl.rad(game.fov), game.aspect_ratio, 0.1, 1000.0)
	sgl.rotate(sgl.rad(-game.player.rot.yaw), 0.0, 1.0, 0.0)
	sgl.rotate(sgl.rad(-game.player.rot.pitch), 1.0, 0.0, 0.0)
	sgl.rotate(sgl.rad(-game.player.rot.roll), 0.0, 0.0, 1.0)
	x := block.loc.x + game.player.loc.x
	y := block.loc.y + game.player.loc.y
	z := block.loc.z + game.player.loc.z
	sgl.translate(x, y, z)

	sgl.matrix_mode_modelview()
	sgl_draw_cube(1)

	sgl.pop_matrix()
	sgl.disable_texture()
}
