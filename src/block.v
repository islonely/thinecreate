import sokol.sgl
import src.transform { Vector3, Vertex }

const (
	block_size = f32(0.5)
)

// vfmt off
const (
	block_vertices = [
		//          X            Y            Z          COLOR      U      V
		// back face
		Vertex{-block_size,  block_size, -block_size, 0xFFFFFF_FF, 1.0,  third},
		Vertex{ block_size,  block_size, -block_size, 0xFFFFFF_FF, 0.75, third},
		Vertex{ block_size, -block_size, -block_size, 0xFFFFFF_FF, 0.75, third2},
		Vertex{-block_size, -block_size, -block_size, 0xFFFFFF_FF, 1.0,  third2},
		// front face
		Vertex{-block_size, -block_size,  block_size, 0xFFFFFF_FF, 0.25, third2},
		Vertex{ block_size, -block_size,  block_size, 0xFFFFFF_FF, 0.5,  third2},
		Vertex{ block_size,  block_size,  block_size, 0xFFFFFF_FF, 0.5,  third},
		Vertex{-block_size,  block_size,  block_size, 0xFFFFFF_FF, 0.25, third},
		// left face
		Vertex{-block_size,  block_size,  block_size, 0xFFFFFF_FF, 0.25, third},
		Vertex{-block_size,  block_size, -block_size, 0xFFFFFF_FF, 0.0,  third},
		Vertex{-block_size, -block_size, -block_size, 0xFFFFFF_FF, 0.0,  third2},
		Vertex{-block_size, -block_size,  block_size, 0xFFFFFF_FF, 0.25, third2},
		// right face
		Vertex{ block_size, -block_size,  block_size, 0xFFFFFF_FF, 0.5,  third2},
		Vertex{ block_size, -block_size, -block_size, 0xFFFFFF_FF, 0.75, third2},
		Vertex{ block_size,  block_size, -block_size, 0xFFFFFF_FF, 0.75, third},
		Vertex{ block_size,  block_size,  block_size, 0xFFFFFF_FF, 0.5,  third},
		// bottom face
		Vertex{ block_size, -block_size, -block_size, 0xFFFFFF_FF, 0.5,  1.0},
		Vertex{ block_size, -block_size,  block_size, 0xFFFFFF_FF, 0.5,  third2},
		Vertex{-block_size, -block_size,  block_size, 0xFFFFFF_FF, 0.25, third2},
		Vertex{-block_size, -block_size, -block_size, 0xFFFFFF_FF, 0.25, 1.0},
		// top face
		Vertex{-block_size,  block_size, -block_size, 0xFFFFFF_FF, 0.25,  0.0},
		Vertex{-block_size,  block_size,  block_size, 0xFFFFFF_FF, 0.25,  third},
		Vertex{ block_size,  block_size,  block_size, 0xFFFFFF_FF, 0.5,   third},
		Vertex{ block_size,  block_size, -block_size, 0xFFFFFF_FF, 0.5,   0.0}
	]
	block_indices = [
		u16(00), 01, 02, 00, 02, 03, // back face
		    06,  05, 04, 07, 06, 04, // front face
		    08,  09, 10, 08, 10, 11, // left face
		    14,  13, 12, 15, 14, 12, // right face
		    16,  17, 18, 16, 18, 19, // bottom face
		    22,  21, 20, 23, 22, 20  // top face
	]
)
// vfmt on

// Block represents a block in the game.
struct Block {
pub:
	typ        BlockType = .test
	name       string
pub mut:
	pos Vector3
	invisible  bool
	collision  bool = true
	suffocates bool = true
	is_active  bool = true
}

[params]
struct BlockProperties {
	invisible  bool
	collision  bool = true
	suffocates bool = true
}

// new_block instantiates a Block.
[inline]
fn new_block(typ BlockType, name string, pos Vector3, props BlockProperties) &Block {
	return &Block{
		typ: typ
		name: name
		pos: pos
		invisible: props.invisible
		collision: props.collision
		suffocates: props.suffocates
	}
}

// new_air_block instantiates an air Block.
[inline]
fn new_air_block(pos Vector3) &Block {
	return new_block(.air, 'block_air', pos, invisible: true, collision: false, suffocates: false)
}

// draw renders the block to the screen.
[direct_array_access]
fn (mut block Block) draw(mut game Game) {
	if block.invisible {
		return
	}

	sgl.defaults()
	sgl.load_pipeline(game.pipeline)

	sgl.enable_texture()
	sgl.texture(game.textures['blocks'][int(block.typ)])
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
