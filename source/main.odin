package main

import "core:math"
import "core:thread"
import "core:time"
import "core:sync"

import rl "vendor:raylib"

import "renderer"
import CONST "constant"
import "pendulum"
import "events"


ApplicationState :: struct {
    application_running: bool,
    simulation_paused: bool,
}


application_state: ApplicationState

pendulum_state : pendulum.PendulumState
pendulum_pose  : pendulum.PendulumPose

mutex : sync.Mutex

sim_time: f32
render_time: f32


physics_loop :: proc(t: ^thread.Thread) {

    last_time:= time.now()
    dt: f32
    DT_TARGET: f32 = 1.0 / f32(CONST.SETTINGS.PHYSICS_UPDATE_FREQUENCY_HZ)

    for application_state.application_running {

        // continue if the application is paused //
        if application_state.simulation_paused {
            last_time = time.now()
            time.sleep(time.Microsecond * 100)
            continue
        }

        // measure time and dt //
        raw_elapsed := time.since(last_time)
        dt = f32(time.duration_seconds(raw_elapsed))

        // continue if the delta time is smaller than the simulation target //
        if (dt < DT_TARGET) {
            time.sleep(time.Microsecond * 100)
            continue
        }

        // update time measurement and pendulum state // 
        last_time = time.now()
        pendulum.update_ode4(&pendulum_state, 0.0, dt)

        sync.mutex_lock(&mutex)
        pendulum_pose = pendulum.get_pose(pendulum_state)
        sim_time = dt * CONST.S_TO_MS
        sync.mutex_unlock(&mutex)
    }
}


render_loop :: proc() {
    
    render_pose: pendulum.PendulumPose
    local_sim_time: f32

    for application_state.application_running {

        render_time = rl.GetFrameTime() * CONST.S_TO_MS

        events.poll()

        if events.keyboard.ESCAPE.press || rl.WindowShouldClose() {
            application_state.application_running = false
        }

        if events.keyboard.P.press {
            application_state.simulation_paused = !application_state.simulation_paused
        }

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


main :: proc() {

    CONST.init()

    rl.SetConfigFlags({.VSYNC_HINT, .MSAA_4X_HINT})
    rl.InitWindow(CONST.SETTINGS.SCREEN_WIDTH, CONST.SETTINGS.SCREEN_HEIGHT, "Pendulum")
    defer rl.CloseWindow()

    pendulum.init()
    renderer.init()
    events.init()

    pendulum_state.q2 = 0.1

    application_state.application_running = true
    application_state.simulation_paused = false

    physics_thread := thread.create(physics_loop)
    if physics_thread != nil {
        thread.start(physics_thread)
    }
    defer thread.destroy(physics_thread)

    render_loop()

}