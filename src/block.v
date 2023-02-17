import gx

const block_size = 128
const half_block_size = block_size / 2

// Block represents a block in the game.
struct Block {
	id int
	name string
mut:
	vertices []Vertex = []Vertex{cap: 8}
	edges [][]int = [][]int{cap: 4}
	relative_size u8 = 1
pub mut:
	loc Location
	rot Rotation = Rotation{0.004, 0.002, 0.008}
}

// new_block instantiates a `Block` with the given
// texture and location.
fn new_block(id int, name string, loc Location) &Block {
	mut block := &Block{
		id: id
		name: name
		loc: loc
	}
	block.vertices = [
		Vertex{
			x: (block.loc.x - half_block_size),
			y: (block.loc.y - half_block_size),
			z: (block.loc.z - half_block_size)
		},
		Vertex{
			x: (block.loc.x + half_block_size),
			y: (block.loc.y - half_block_size),
			z: (block.loc.z - half_block_size)
		},
		Vertex{
			x: (block.loc.x + half_block_size),
			y: (block.loc.y + half_block_size),
			z: (block.loc.z - half_block_size)
		},
		Vertex{
			x: (block.loc.x - half_block_size),
			y: (block.loc.y + half_block_size),
			z: (block.loc.z - half_block_size)
		},
		Vertex{
			x: (block.loc.x - half_block_size),
			y: (block.loc.y - half_block_size),
			z: (block.loc.z + half_block_size)
		},
		Vertex{
			x: (block.loc.x + half_block_size),
			y: (block.loc.y - half_block_size),
			z: (block.loc.z + half_block_size)
		},
		Vertex{
			x: (block.loc.x + half_block_size),
			y: (block.loc.y + half_block_size),
			z: (block.loc.z + half_block_size)
		},
		Vertex{
			x: (block.loc.x - half_block_size),
			y: (block.loc.y + half_block_size),
			z: (block.loc.z + half_block_size)
		}
	]
	block.edges = [
		[0, 1], [1, 2], [2, 3], [3, 0], // back face
		[4, 5], [5, 6], [6, 7], [7, 4], // front face
		[0, 4], [1, 5], [2, 6], [3, 7]	// connecting sides
	]
	return block
}

// draw draws the block to the buffered image.
fn (mut block Block) draw(mut img BufferedImage) {
	center := block.center()
	for mut v in block.vertices {
		v.x -= center.x
		v.y -= center.y
		v.z -= center.z
		v.rotate(block.rot)
		v.x += center.x
		v.y += center.y
		v.z += center.z
	}
	for edge in block.edges {
		// game.g.draw_line_with_config(
		// 	block.vertices[edge[0]].x, block.vertices[edge[0]].y,
		// 	block.vertices[edge[1]].x, block.vertices[edge[1]].y,
		// 	thickness: 2
		// 	color: gx.red
		// )
		x1 := int(block.vertices[edge[0]].x)
		y1 := int(block.vertices[edge[0]].y)
		x2 := int(block.vertices[edge[1]].x)
		y2 := int(block.vertices[edge[1]].y)
		img.draw_line(x1, y1, x2, y2, gx.red)
	}
}

// center returns a `Vertex` coresponding to the center of the block.
fn (mut block Block) center() Vertex {
	mut c := Vertex{}
	for v in block.vertices {
		c.x += v.x
		c.y += v.y
		c.z += v.z
	}
	c.x /= block.vertices.len
	c.y /= block.vertices.len
	c.z /= block.vertices.len
	return c
}