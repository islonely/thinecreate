import sokol.sgl
import src.transform { Vector3 }

// Block represents a block in the game.
struct Block {
pub:
	typ  BlockType = .test
	name string
pub mut:
	pos        Vector3
	invisible  bool
	collision  bool = true
	suffocates bool = true
	is_active  bool = true
}

@[params]
struct BlockProperties {
	invisible  bool
	collision  bool = true
	suffocates bool = true
}

// new_block instantiates a Block.
@[inline]
fn new_block(typ BlockType, name string, pos Vector3, props BlockProperties) &Block {
	return &Block{
		typ:        typ
		name:       name
		pos:        pos
		invisible:  props.invisible
		collision:  props.collision
		suffocates: props.suffocates
	}
}

// new_air_block instantiates an air Block.
@[inline]
fn new_air_block(pos Vector3) &Block {
	return new_block(.air, 'block_air', pos, invisible: true, collision: false, suffocates: false)
}

// draw renders the block to the screen.
@[direct_array_access]
fn (mut block Block) draw(mut game Game) {
	if block.invisible {
		return
	}

	sgl.defaults()
	sgl.load_pipeline(game.pipeline)

	sgl.enable_texture()
	sgl.texture(game.textures['blocks'][int(block.typ)], game.default_sampler)
	sgl.push_matrix()

	sgl.matrix_mode_projection()
	mut cam := game.camera()
	cam.update()

	sgl.matrix_mode_modelview()
	sgl_draw_cube(0.5)
	sgl.translate(block.pos.x, block.pos.y, block.pos.z)
	sgl.end()

	sgl.pop_matrix()
	sgl.disable_texture()
}

// BlockType is every different type of block available.
enum BlockType {
	air
	dirt
	dust
	glass
	grass
	juniper
	redwood
	slate
	stone
	test
	block_count
}
