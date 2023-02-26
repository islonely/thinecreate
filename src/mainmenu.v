import gg
import gx

import src.transform { Vector2 }

// MainMenu
[heap]
struct MainMenu {
mut:
	x int
	y int
	text_size int = 44
	text_shadow bool = true
	text_color gx.Color = gx.white
	padding int = 15
	step bool = true
	step_size int = 35
	step_dir StepDirection = .left
	
	selector_pos Vector2
	selector_target Vector2
	selector_velocity Vector2
	selector_speed f32 = 35	// lower value = faster speed
	selected int
	selected_color gx.Color = gx.hex(0xff2c80ff)
	items []MenuItem
}

// MenuItem represents an individual item in the MainMenu.
struct MenuItem {
	on_selected fn()
	label string = '<label_not_set>'
}

// StepDirection
enum StepDirection {
	left
	right
}

// update updates the menu.
fn (mut menu MainMenu) update(keydown KeyDown, mut game Game) {
	if keydown[.enter] {
		menu.items[menu.selected].on_selected()
		return
	}

	if keydown[.up] {
		if menu.selected == 0 {
			menu.selected = menu.items.len-1
		} else {
			menu.selected--
		}
		game.key_is_down[.up] = false
	} else if keydown[.down] {
		if menu.selected == menu.items.len-1 {
			menu.selected = 0
		} else {
			menu.selected++
		}
		game.key_is_down[.down] = false
	}

	if menu.selector_pos < menu.selector_target {
		menu.selector_pos += menu.selector_velocity
	}
}

// draw draws the MainMenu to the screen.
fn (mut menu MainMenu) draw(mut game Game) {
	game.g.draw_image(0, 0, (game.width/gg.dpi_scale()), (game.height/gg.dpi_scale()), game.menu_background)
	logo_scale := f32(0.33)
	logo_scaled_width := f32(game.logo.width) * logo_scale
	logo_scaled_height := f32(game.logo.height) * logo_scale
	logo_x := game.width/gg.dpi_scale()/2 - logo_scaled_width/2
	game.g.draw_image(logo_x, 50, logo_scaled_width, logo_scaled_height, game.logo)

	for i, item in menu.items {
		step := (i * menu.step_size)
		x := if menu.step {
			menu.x + if menu.step_dir == .right {
				step
			} else {
				-step
			}
		} else {
			menu.x
		}
		y := menu.y + (i * menu.text_size + menu.padding)

		mut color := menu.text_color
		if i == menu.selected {
			color = menu.selected_color
			w, h := game.g.text_size(item.label)
			menu.selector_target = Vector2{x, (y+h/2+5)}
			menu.selector_velocity = Vector2{
				(menu.selector_target.x - menu.selector_pos.x) / menu.selector_speed,
				(menu.selector_target.y - menu.selector_pos.y) / menu.selector_speed
			}
			game.g.draw_rounded_rect_filled(menu.selector_pos.x, menu.selector_pos.y, w, 2.5, 500, color)
		}

		game.g.draw_text(x, y, item.label,
			size: menu.text_size
			vertical_align: .middle
			align: if menu.step_dir == .right {
				.right
			} else {
				.left
			}
			mono: true
			color: color
		)
	}
}