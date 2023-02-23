module textures

import sokol.gfx
import stbi

const block_size = 16

pub const (
	block_grass_bytes = $embed_file('src/img/block_grass.png').to_bytes()
	block_test_bytes = $embed_file('src/img/block_test.png').to_bytes()
	
	misc_skybox_bytes = $embed_file('src/img/skybox.png').to_bytes()
)

// pub const (
// 	// corresponds to numeric value of BlockTypes enum.
// 	blocks = [
// 		bytes_to_gfximage(block_grass_bytes, 'block_grass')
// 		bytes_to_gfximage(block_test_bytes, 'block_test')
// 	]

// 	misc = [
// 		bytes_to_gfximage(misc_skybox_bytes, 'misc_skybox')
// 	]
// )

pub fn init() map[string][]gfx.Image {
	return {
		// corresponds to numeric value of BlockTypes enum.
		'blocks': [
			textures.bytes_to_gfximage(textures.block_grass_bytes, 'block_grass'),
			textures.bytes_to_gfximage(textures.block_test_bytes, 'block_test')
		],
		'misc': [
			textures.bytes_to_gfximage(textures.misc_skybox_bytes, 'misc_skybox')
		]
	}
}

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