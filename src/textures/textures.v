module textures

import sokol.gfx
import stbi

// byte data from the texture source files.
const (
	block_dirt_bytes  = $embed_file('src/img/block_dirt.png').to_bytes()
	block_glass_bytes = $embed_file('src/img/block_glass.png').to_bytes()
	block_grass_bytes = $embed_file('src/img/block_grass.png').to_bytes()
	block_stone_bytes = $embed_file('src/img/block_stone.png').to_bytes()
	block_test_bytes  = $embed_file('src/img/block_test.png').to_bytes()

	misc_skybox_bytes = $embed_file('src/img/skybox.png').to_bytes()
)

// init returns a map of all the textures. Sokol doesn't like it if you
// try to make a gfx.Image before a window is created. That's why
// these aren't just constants.
pub fn init() map[string][]gfx.Image {
	return {
		// Order corresponds to numeric value of BlockTypes enum.
		'blocks': [
			// NOTE: for invisible Blocks we use the test texture.
			// But it won't get rendered because the block is invisible.
			bytes_to_gfximage(textures.block_test_bytes, 'block_air'),
			bytes_to_gfximage(textures.block_dirt_bytes, 'block_dirt'),
			bytes_to_gfximage(textures.block_glass_bytes, 'block_glass'),
			bytes_to_gfximage(textures.block_grass_bytes, 'block_grass'),
			bytes_to_gfximage(textures.block_stone_bytes, 'block_stone'),
			bytes_to_gfximage(textures.block_test_bytes, 'block_test'),
		]
		'misc':   [
			bytes_to_gfximage(textures.misc_skybox_bytes, 'misc_skybox'),
		]
	}
}

// bytes_to_gfximage converts an array of bytes to a gfx.Image.
fn bytes_to_gfximage(bytes []u8, name string) gfx.Image {
	stb_img := stbi.load_from_memory(bytes.data, bytes.len) or {
		println('Failed to load textures: ${name}')
		exit(0)
	}
	mut img_desc := gfx.ImageDesc{
		width: stb_img.width
		height: stb_img.height
		num_mipmaps: 0
		min_filter: .nearest
		mag_filter: .nearest
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: &u8(0)
		d3d11_texture: 0
	}
	img_desc.data.subimage[0][0] = gfx.Range{
		ptr: stb_img.data
		size: usize(stb_img.width * stb_img.height * stb_img.nr_channels)
	}
	return gfx.make_image(&img_desc)
}
