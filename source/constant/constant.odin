package constant

import "core:fmt"

import "../file"

import rl "vendor:raylib"


PhysicsFile :: struct {
    GRAVITY: f32,
    AIR_DENSITY: f32
}


PendulumFile :: struct {
    CART_MASS: f32,
    PENDULUM_MASS: f32,
    PENDULUM_LENGTH: f32,
    CART_WIDTH: f32,
    CART_HEIGHT: f32,
    CART_DEPTH: f32,
    PENDULUM_RADIUS: f32,
    RAIL_FRICTION: f32,
    BEARING_FRICTION: f32,
    CART_DRAG_COEFFICIENT: f32,
    PENDULUM_DRAG_COEFFICIENT: f32
}


SettingsFile :: struct {
    SCREEN_WIDTH: i32,
    SCREEN_HEIGHT: i32,
    FONT_SIZE: i32,
    PHYSICS_UPDATE_FREQUENCY_HZ : i32,
}


S_TO_MS : f32 = 1000.0


PHYSICS: PhysicsFile
PENDULUM: PendulumFile
SETTINGS: SettingsFile


init :: proc() {
    file.load_data("data/settings.json", &SETTINGS)
    file.load_data("data/physics.json", &PHYSICS)
    file.load_data("data/pendulum.json", &PENDULUM)
}
