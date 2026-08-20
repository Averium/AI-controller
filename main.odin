package main

import "core:math"
import "core:thread"
import "core:time"
import "core:sync"

import rl "vendor:raylib"

import "renderer"
import CONST "constant"
import "pendulum"


pendulum_state : pendulum.PendulumState
pendulum_pose  : pendulum.PendulumPose

mutex : sync.Mutex

running : bool =  true


sim_time: f32
render_time: f32


physics_loop :: proc(t: ^thread.Thread) {

    last_time:= time.now()
    dt: f32
    DT_TARGET: f32 = 1.0 / f32(CONST.SETTINGS.PHYSICS_UPDATE_FREQUENCY_HZ)

    for running {
        raw_elapsed := time.since(last_time)
        dt = f32(time.duration_seconds(raw_elapsed))

        if (dt >= DT_TARGET) {
            last_time = time.now()

            // Integrate forward using the measured real time
            pendulum.update_ode4(&pendulum_state, 0.0, dt)

            // Publish thread-safe pose and timing snapshot
            sync.mutex_lock(&mutex)
            pendulum_pose = pendulum.get_pose(pendulum_state)
            sim_time = dt * CONST.S_TO_MS
            sync.mutex_unlock(&mutex)
        }
        else {
            // Brief sleep to reduce CPU load while waiting for loop timer
            time.sleep(time.Microsecond * 100)
        }
    }
}


main :: proc() {

    CONST.init()

    rl.SetConfigFlags({.VSYNC_HINT, .MSAA_4X_HINT})
    rl.InitWindow(CONST.SETTINGS.SCREEN_WIDTH, CONST.SETTINGS.SCREEN_HEIGHT, "Game")
    defer rl.CloseWindow()

    pendulum.init()
    renderer.init()

    pendulum_state.q2 = 0.1

    physics_thread := thread.create(physics_loop)
    if physics_thread != nil {
        thread.start(physics_thread)
    }

    defer {
        running = false
        thread.destroy(physics_thread)
    }

    render_pose: pendulum.PendulumPose
    local_sim_time: f32

    for !rl.WindowShouldClose() {

        render_time = rl.GetFrameTime() * CONST.S_TO_MS

        sync.mutex_lock(&mutex)
        render_pose = pendulum_pose
        local_sim_time = sim_time
        sync.mutex_unlock(&mutex)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        renderer.draw_pendulum(render_pose)
        renderer.draw_debug_info("Simulation time [ms]: ", local_sim_time, color_2=rl.RED)
        renderer.draw_debug_info(" Rendering time [ms]: ", render_time)

        rl.EndDrawing()
    }
}