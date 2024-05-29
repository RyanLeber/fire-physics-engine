<a name="readme-top"></a>
<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h2 align="center">Fire-Physics-Engine</h3>
  <p align="center">
    A 2D physics engine built in mojo. 🔥
  </p>
  ![pendulum gif](https://github.com/RyanLeber/fire-physics-engine/blob/main/assets/pendulum.gif)
</div>

# Overview
This project is currently just a demo to test out Mojo's capabilities. I plan to expand on it, and build a small game engine around it as mojo progresses. Feel free to message me with any questions.

Currently the largest constraint is ffi support in Mojo. The rendering is a bit janky as it uses raylib. Mojo's ffi is not great at calling functions from external libs and can't take structs directly. Also the DLHandle must be passed around anywhere raylib is needed. RayLib does not use pointers for most of its function calls, so the project contains a small set of bindings for compatibility.


## Roadmap (contributors welcome!):
- Replace broad phase collision detection.
- Allow for shapes other than rectangles.
- Better documentation
- Write graphics library with OpenGL, glfw
- General optimizations


## Requirements

Warning: This project uses the nightly build of Mojo, and has only been tested on WSL Ubuntu
- C, C Compiler
- CMake
- RayLib
- Mojo Nightly



## Getting Started

1. **RayLib installation guide:** [Install RayLib, Working on GNU Linux](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux)
    - Note: if you are using WSL and its built-in windowing server. When installing raylib set this flag in the cmake command `-DUSE_WAYLAND=ON`.
2. **Clone the repo**
    ```sh
    git clone https://github.com/RyanLeber/fire-physics-engine.git
    ```
3. **Build the raylib bindings:**
    ```sh
    cd fire-physics-engine/raylib_bindings
    mkdir build
    mkdir lib
    cd build
    cmake ..
    make
    ```
4. **Set the path to RayLib:**

    In `src/engine_utils/raylib_map.mojo` set `RAYLIB_PATH` to where you build RayLib. If you built RayLib as a shared library the path will most likely already be correct.

5. **Run demo:**

    There are 2 demos `demo.mojo` and `player_demo.mojo`. They both contain the same demos but `player_demo.mojo` has a controllable box.



## Contributing
  
Small fixes and improvements are much appreciated. If you are considering larger contributions, feel free to contact me. If you find a bug or have an idea for a feature, please use the issue tracker.

### Creating A Pull Request

1. Fork the Project
2. Create your Feature Branch
3. Commit your Changes
4. Push to the Branch
5. Open a Pull Request



## License

Distributed under the MIT License. See `LICENSE.txt` for more information.


## Acknowledgements
- Based on [Box2D-lite, by Erin Canto](https://github.com/erincatto/box2d-lite).
- Built with [Mojo](https://github.com/modularml/mojo) created by [Modular](https://github.com/modularml)