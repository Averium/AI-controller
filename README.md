# AI Controller: Inverted Pendulum Simulation & Neural Network from Scratch

A high-performance, multithreaded inverted pendulum (cart-pole) simulation built in **Odin** using **Raylib**. The goal of this project is to simulate parallel pendulum environments and implement a Reinforcement Learning (RL) framework—including dense neural network architectures, forward/backward propagation, and training algorithms—entirely **from scratch**.

## Features

- **Physics Engine:** 4th-order Runge-Kutta (RK4) ODE numerical integration.
- **Thread-Safe Architecture:** Mutex-locked snapshotting separating physics updates from rendering to prevent data races and tearing.
- **Adaptive Timestep:** Real-time variable loop handling with safety bounds against integration explosions.
- **Data-Driven Configuration:** Built-in JSON loader using Odin's dynamic reflection (`any` type) for loading physics constants and runtime params.
- **Custom Visualizer:** Real-time GUI rendering using Raylib with crisp debug metric overlays.
- **Zero External Machine Learning Dependencies:** Neural network primitives and reinforcement learning algorithms built natively in Odin.

## Project Structure

| Path | Description |
|---|---|
| `constant/` | Global constants and simulation parameters |
| `pendulum/` | Physical state structures, dynamics, and RK4 integration |
| `renderer/` | Raylib visualization and debug metric overlays |
| `simulation/` | Simulation setup, environment management, and JSON configuration loading |
| `pendulum.json` | Inverted pendulum physical parameters |
| `physics.json` | Physics and numerical simulation parameters |
| `settings.json` | General application and runtime settings |
| `main.odin` | Application entry point and main event loops |

## Getting Started

### Prerequisites

- [Odin Compiler](https://odin-lang.org/) (latest release)
- Raylib (included out-of-the-box via Odin's standard library vendor collection)

### Running the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/Averium/AI-controller.git
   cd AI-controller
   ```

2. Build and run with optimization:
   ```bash
   odin run . -speed
   ```

## Roadmap

- [x] Multi-threaded RK4 inverted pendulum simulation
- [x] Thread-safe rendering pipeline
- [x] JSON configuration loader
- [ ] Gym-style environment wrapper (`step`, `reset`, observation states)
- [ ] Custom matrix library and Neural Network layers
- [ ] Deep Reinforcement Learning implementation (Policy Gradient / Deep Q-Learning)
- [ ] Parallelized environment batching for rapid training
