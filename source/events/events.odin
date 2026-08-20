package events


import rl "vendor:raylib"


ButtonState :: struct {
    press: bool,
    hold: bool,
    release: bool,
}


MouseHandler :: struct {
    point: rl.Vector2,
    left: ButtonState,
    right: ButtonState,
}


KeyboardHandler :: struct {
    R: ButtonState,
    P: ButtonState,
    ESCAPE: ButtonState,
}


mouse: MouseHandler
keyboard: KeyboardHandler


@(private)
get_mouse_button_state :: proc(raylib_button: rl.MouseButton) -> (button_state: ButtonState) {
    
    button_state.press = rl.IsMouseButtonPressed(raylib_button)
    button_state.hold = rl.IsMouseButtonDown(raylib_button)
    button_state.release = rl.IsMouseButtonReleased(raylib_button)

    return
}


@(private)
get_keyboard_button_state :: proc(raylib_key: rl.KeyboardKey) -> (button_state: ButtonState) {
    
    button_state.press = rl.IsKeyPressed(raylib_key)
    button_state.hold = rl.IsKeyDown(raylib_key)
    button_state.release = rl.IsKeyReleased(raylib_key)

    return
}


init :: proc() {}


poll :: proc() {

    mouse.point = rl.GetMousePosition()
    mouse.left = get_mouse_button_state(rl.MouseButton.LEFT)
    mouse.right = get_mouse_button_state(rl.MouseButton.RIGHT)

    keyboard.P = get_keyboard_button_state(rl.KeyboardKey.P)
    keyboard.R = get_keyboard_button_state(rl.KeyboardKey.R)
    keyboard.ESCAPE = get_keyboard_button_state(rl.KeyboardKey.ESCAPE)

}