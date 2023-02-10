import gg

fn handle_key_down(key gg.KeyCode, mod gg.Modifier, mut game Game) {
	game.key_is_down[key] = true
}

fn handle_key_up(key gg.KeyCode, mod gg.Modifier, mut game Game) {
	game.key_is_down[key] = false
}