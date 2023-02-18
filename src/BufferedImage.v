import gx
import math
import stbi

// BufferedImage is exactly what it says it is.
[heap]
struct BufferedImage {
mut:
	buffer &int = unsafe { nil }
	width int
	height int
}

// new_bufferedimage instantiates a `BufferedImage` from a provided
// width and height and allocates memory for the image data.
fn new_bufferedimage(width int, height int) &BufferedImage {
	if width < 0 || height < 0 {
		return 0
	}
	mut img := &BufferedImage{
		width: width
		height: height
	}
	unsafe {
		img.buffer = malloc(img.width * img.height * 4)
	}
	return img
}

fn new_bufferedimage_from_memory(b &u8, size int) !&BufferedImage {
	stb_img := stbi.load_from_memory(b, size)!
	mut img := &BufferedImage{
		width: stb_img.width
		height: stb_img.height
		buffer: stb_img.data
	}
	return img
}

fn new_bufferedimage_from_bytes(b []u8) !&BufferedImage {
	return new_bufferedimage_from_memory(b.data, b.len)!
}

// zero sets the image data to 0s by reallocating the memory.
// NOTE: I'm not sure if this is the optimal way to do this :| 
fn (mut img BufferedImage) zero() {
	unsafe {
		img.buffer = malloc(img.width * img.height * 4)
	}
}

// draw_pixel draws a pixel to the image data at (x, y).
fn (mut img BufferedImage) draw_pixel(x int, y int, color gx.Color) {
	if (x < 0 || y < 0) || (x > img.width || y > img.width) {
		return
	}
	unsafe {
		img.buffer[x + y * img.width] = color.abgr8()
	}
}

fn (mut img BufferedImage) draw_pixel_int(x int, y int, color int) {
	if (x < 0 || y < 0) || (x > img.width || y > img.width) {
		return
	}
	unsafe {
		img.buffer[x + y * img.width] = color
	}
}

// draw_line draws a line to the image data from (x0, y0) to (x1, y1).
fn (mut img BufferedImage) draw_line(x0 int, y0 int, x1 int, y1 int, color gx.Color) {
	mut x := x0
	mut y := y0
	mut dx := x1 - x0
	mut dy := y1 - y0
	mut sx := int(math.sign(dx))
	mut sy := int(math.sign(dy))
	dx = int(math.abs(dx))
	dy = int(math.abs(dy))

	mut interchange := false
	if dy > dx {
		tmp := dx
		dx = dy
		dy = tmp
		interchange = true
	}

	mut error := 2 * dy - dx

	for _ in 0..dx {
		img.draw_pixel(x, y, color)
		for error > 0 {
			if interchange {
				x += sx
			} else {
				y += sy
			}
			error -= 2 * dx
		}
		if interchange {
			y += sy
		} else {
			x += sx
		}
		error += 2 * dy
	}
}

fn (mut img BufferedImage) draw_triangle(x0 int, y0 int, x1 int, y1 int, x2 int, y2 int, color gx.Color) {
	img.draw_line(x0, y0, x1, y1, color)	
	img.draw_line(x1, y1, x2, y2, color)	
	img.draw_line(x2, y2, x0, y0, color)
}

fn (mut img BufferedImage) draw_filled_rectangle(x0 int, y0 int, x1 int, y1 int, color gx.Color) {
	for x in x0..x1 {
		img.draw_line(x, y0, x, y1, color)
	}
}

fn (mut img BufferedImage) draw_filled_square(x int, y int, size int, color gx.Color) {
	img.draw_filled_rectangle(x, y, x+size, y+size, color)
}