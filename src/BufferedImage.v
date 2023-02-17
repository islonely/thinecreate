import gx
import math

// BufferedImage is exactly what it says it is.
[heap]
struct BufferedImage {
mut:
	buffer &u32 = unsafe { nil }
	width u32
	height u32
}

// new_bufferedimage instantiates a `BufferedImage` from a provided
// width and height and allocates memory for the image data.
fn new_bufferedimage(width u32, height u32) &BufferedImage {
	mut img := &BufferedImage{
		width: width
		height: height
	}
	unsafe {
		img.buffer = malloc(img.width * img.height * 4)
	}
	return img
}

// zero sets the image data to 0s by reallocating the memory.
// NOTE: I'm not sure if this is the optimal way to do this :| 
[direct_array_access]
fn (mut img BufferedImage) zero() {
	unsafe {
		img.buffer = malloc(img.width * img.height * 4)
	}
}

// draw_pixel draws a pixel to the image data at (x, y).
[direct_array_access]
fn (mut img BufferedImage) draw_pixel(x int, y int, color gx.Color) {
	if (x < 0 || y < 0) || (x > img.width || y > img.width) {
		return
	}
	unsafe {
		img.buffer[u32(x) + u32(y) * img.width] = u32(color.abgr8())
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