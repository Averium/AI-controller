package pendulum

import "core:math"

import CONST "../constant"

PendulumState :: struct {
    q1  : f32,
    dq1 : f32,
    q2  : f32,
    dq2 : f32,
}

PendulumPose :: struct {
    x  : f32,
    fi : f32,
}

PendulumParams :: struct {
    m1  : f32,
    m2  : f32,
    L   : f32,
    b1  : f32,
    b2  : f32,
    Cd1 : f32,
    Cd2 : f32,
}


PARAMS: PendulumParams


init :: proc() {
    PARAMS.m1 = CONST.PENDULUM.CART_MASS
    PARAMS.m2 = CONST.PENDULUM.PENDULUM_MASS
    PARAMS.L = CONST.PENDULUM.PENDULUM_LENGTH
    PARAMS.b1 = CONST.PENDULUM.RAIL_FRICTION
    PARAMS.b2 = CONST.PENDULUM.BEARING_FRICTION
    PARAMS.Cd1 = 0.5 * CONST.PHYSICS.AIR_DENSITY * CONST.PENDULUM.CART_HEIGHT * CONST.PENDULUM.CART_DEPTH * CONST.PENDULUM.CART_DRAG_COEFFICIENT
    PARAMS.Cd2 = 0.5 * CONST.PHYSICS.AIR_DENSITY * math.PI * CONST.PENDULUM.PENDULUM_RADIUS * CONST.PENDULUM.PENDULUM_RADIUS * CONST.PENDULUM.PENDULUM_DRAG_COEFFICIENT
}


calculate_accelerations :: proc(p: ^PendulumState, F: f32) -> (ddx: f32, ddf: f32) {
    // 1. Keep pendulum angle wrapped inside [-PI, PI]
    p.q2 = math.mod(p.q2 + math.PI, 2.0 * math.PI) - math.PI

    // Trigonometric terms
    sin_q2 := math.sin(p.q2)
    cos_q2 := math.cos(p.q2)

    g := CONST.PHYSICS.GRAVITY

    // Pre-computed powers and products
    L_2      := PARAMS.L * PARAMS.L
    m2_2     := PARAMS.m2 * PARAMS.m2
    dq2_2    := p.dq2 * p.dq2
    sin_q2_2 := sin_q2 * sin_q2

    // Speeds (magnitudes)
    v1_mag := math.abs(p.dq1)

    // Guard against negative epsilon float underflow in sqrt: max(0.0, v2_sq)
    v2_sq  := L_2 * dq2_2 - 2.0 * PARAMS.L * cos_q2 * p.dq1 * p.dq2 + (p.dq1 * p.dq1)
    v2_mag := math.sqrt(math.max(f32(0.0), v2_sq))

    // Denominators
    common_den := PARAMS.m1 + PARAMS.m2 * sin_q2_2
    den_1      := PARAMS.L * common_den
    den_2      := L_2 * PARAMS.m2 * common_den

    // Simplified, factored numerators from SymPy
    num_1 := - PARAMS.Cd1 * PARAMS.L * v1_mag * p.dq1 \
             - PARAMS.Cd2 * PARAMS.L * v2_mag * p.dq1 * sin_q2_2 \
             + F * PARAMS.L \
             - L_2 * PARAMS.m2 * sin_q2 * dq2_2 \
             - PARAMS.L * PARAMS.b1 * p.dq1 \
             + PARAMS.L * CONST.PHYSICS.GRAVITY * PARAMS.m2 * sin_q2 * cos_q2 \
             - PARAMS.b2 * cos_q2 * p.dq2

    num_2 := - PARAMS.Cd1 * PARAMS.L * PARAMS.m2 * v1_mag * cos_q2 * p.dq1 \
             - PARAMS.Cd2 * L_2 * v2_mag * p.dq2 * common_den \
             + PARAMS.Cd2 * PARAMS.L * PARAMS.m1 * v2_mag * cos_q2 * p.dq1 \
             + F * PARAMS.L * PARAMS.m2 * cos_q2 \
             - L_2 * m2_2 * sin_q2 * cos_q2 * dq2_2 \
             - PARAMS.L * PARAMS.b1 * PARAMS.m2 * cos_q2 * p.dq1 \
             + PARAMS.L * CONST.PHYSICS.GRAVITY * PARAMS.m2 * (PARAMS.m1 + PARAMS.m2) * sin_q2 \
             - PARAMS.b2 * (PARAMS.m1 + PARAMS.m2) * p.dq2

    // Compute Accelerations
    ddx = num_1 / den_1
    ddf = num_2 / den_2
    return
}


// Integrates the state forward by dt using 4th-Order Runge-Kutta
update_ode4 :: proc(p: ^PendulumState, F: f32, dt: f32) {

    // k1 = f(y_n)
    k1_ddx, k1_ddf := calculate_accelerations(p, F)
    k1_dq1 := p.dq1
    k1_dq2 := p.dq2

    // k2 = f(y_n + 0.5 * dt * k1)
    state_k2 := PendulumState{
        q1  = p.q1  + 0.5 * dt * k1_dq1,
        dq1 = p.dq1 + 0.5 * dt * k1_ddx,
        q2  = p.q2  + 0.5 * dt * k1_dq2,
        dq2 = p.dq2 + 0.5 * dt * k1_ddf,
    }

    k2_ddx, k2_ddf := calculate_accelerations(&state_k2, F)
    k2_dq1 := state_k2.dq1
    k2_dq2 := state_k2.dq2

    // k3 = f(y_n + 0.5 * dt * k2)
    state_k3 := PendulumState{
        q1  = p.q1  + 0.5 * dt * k2_dq1,
        dq1 = p.dq1 + 0.5 * dt * k2_ddx,
        q2  = p.q2  + 0.5 * dt * k2_dq2,
        dq2 = p.dq2 + 0.5 * dt * k2_ddf,
    }

    k3_ddx, k3_ddf := calculate_accelerations(&state_k3, F)
    k3_dq1 := state_k3.dq1
    k3_dq2 := state_k3.dq2

    // k4 = f(y_n + dt * k3)
    state_k4 := PendulumState{
        q1  = p.q1  + dt * k3_dq1,
        dq1 = p.dq1 + dt * k3_ddx,
        q2  = p.q2  + dt * k3_dq2,
        dq2 = p.dq2 + dt * k3_ddf,
    }

    k4_ddx, k4_ddf := calculate_accelerations(&state_k4, F)
    k4_dq1 := state_k4.dq1
    k4_dq2 := state_k4.dq2

    // Combine k1, k2, k3, k4 with 1/6 weighting
    p.q1  += (dt / 6.0) * (k1_dq1 + 2.0 * k2_dq1 + 2.0 * k3_dq1 + k4_dq1)
    p.dq1 += (dt / 6.0) * (k1_ddx + 2.0 * k2_ddx + 2.0 * k3_ddx + k4_ddx)
    
    p.q2  += (dt / 6.0) * (k1_dq2 + 2.0 * k2_dq2 + 2.0 * k3_dq2 + k4_dq2)
    p.dq2 += (dt / 6.0) * (k1_ddf + 2.0 * k2_ddf + 2.0 * k3_ddf + k4_ddf)

    // Normalize final angle inside [-PI, PI]
    p.q2 = math.mod(p.q2 + math.PI, 2.0 * math.PI) - math.PI
}


get_pose :: proc(state: PendulumState) -> (pose: PendulumPose) {

    pose.x = state.q1
    pose.fi = state.q2
    
    return
}