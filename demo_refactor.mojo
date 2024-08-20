
from random import random_float64, seed, random_si64

from collections import Optional, Set, Dict, InlineArray

from src.engine import Body, Joint, World
from src.engine.arbiter import ArbiterKey
from src.engine_utils import (
        RayLib,
        Vector2,
        Vector3,
        Rectangle,
        Color,
        Camera3D,
        Camera2D,
        BuiltinColors,
        CameraMode,
        CameraProjection,
        Keyboard,
        DrawModes,
        Mat22,
        Vec2
    )


# MARK: Constants
alias SCREENWIDTH: Int = 1280
alias SCREENHEIGHT: Int = 720
alias FPS = 170
alias iterations: Int = 10
alias gravity= Vec2(0.0, -10.0)

alias K_PI: Float32 = 3.14159265358979323846264
alias INF = Float32.MAX

# MARK: Main
fn main() raises:
    alias width: Int = SCREENWIDTH
    alias height: Int = SCREENHEIGHT

    seed()

    var demo_strings = InlineArray[String, 10](
        "Demo 0: Platform",
        "Demo 1: A Single Box",
        "Demo 2: Simple Pendulum",
        "Demo 3: Varying Friction Coefficients",
        "Demo 4: Randomized Stacking",
        "Demo 5: Pyramid Stacking",
        "Demo 6: A Teeter",
        "Demo 7: A Suspension Bridge",
        "Demo 8: Dominos",
        "Demo 9: Multi-pendulum"
    )

    var red = BuiltinColors.RED
    var black = BuiltinColors.BLACK
    var light_red = Color(148, 68, 68, 255)

    var raylib = RayLib()

    var bodies = InlineArray[Body, 200](Body())
    var joints = InlineArray[Joint[__lifetime_of(bodies)], 100](Joint[__lifetime_of(bodies)]())

    var bomb = Optional[Reference[Body, __lifetime_of(bodies)]]()

    var num_bodies: Int = 0
    var num_joints: Int = 0
    var demo_index: Int = 0
    var time_step: Float32 = 1.0 / 60.0

    var world = World[gravity, iterations, __lifetime_of(bodies), __lifetime_of(joints)]() 

    # MARK: Platform
    @parameter
    fn demo_0():
        # Set the first box
        bodies[0].set(Vec2(100.0, 20.0), INF)
        bodies[0].position = Vec2(0.0, -0.5 * bodies[0].width.y)
        world.add(bodies[0])
        num_bodies += 1


    # MARK: demo_1, Single box
    @parameter
    fn demo_1():
        # Set the first box
        bodies[0].set(Vec2(100.0, 20.0), INF)
        bodies[0].position = Vec2(0.0, -0.5 * bodies[0].width.y)
        world.add(bodies[0])
        num_bodies += 1

        # Set the second box
        bodies[1].set(Vec2(1.0, 1.0), 200.0)
        bodies[1].position = Vec2(0.0, 4.0)
        world.add(bodies[1])
        num_bodies += 1


    # MARK: demo_2, A simple pendulum
    @parameter
    fn demo_2():
        # Set the first box
        bodies[0].set(Vec2(100.0, 20.0), INF)
        bodies[0].friction = 0.2
        bodies[0].position = Vec2(0.0, -0.5 * bodies[0].width.y)
        bodies[0].rotation = 0.0
        world.add(Reference(bodies[0]))

        # Set the second box
        bodies[1].set(Vec2(1.0, 1.0), 100.0)
        bodies[1].friction = 0.2
        bodies[1].position = Vec2(9.0, 11.0)
        bodies[1].rotation = 0.0
        world.add(bodies[1])

        num_bodies += 2

        joints[0].set(bodies[0], bodies[1], Vec2(0.0, 11.0))
        world.add(joints[0])
        num_joints += 1


    # MARK: demo_3, A vertical stack
    @parameter
    fn demo_3():
        var b = 0
        # Set the first box
        bodies[b].set(Vec2(100.0, 20.0), INF)
        bodies[b].friction = 0.2
        bodies[b].position = Vec2(0.0, -0.5 * bodies[b].width.y)
        bodies[b].rotation = 0.0
        world.add(bodies[b])
        b += 1

        for i in range(10):
            bodies[b].set(Vec2(1.0, 1.0), 1.0)
            bodies[b].friction = 0.2
            var x = random_float64(-0.1, 0.1).cast[DType.float32]()
            bodies[b].position = Vec2(x, 0.51 + 1.05 * Float32(i))
            world.add(bodies[b])
            b += 1

        num_bodies = b


    # MARK: init_demo
    @parameter
    fn init_demo(idx: Int):
        world.clear()
        for i in range(num_bodies):
            bodies[i].reset()
        for j in range(num_joints):
            joints[j].reset() 

        num_bodies = 0
        num_joints = 0
        bomb = None

        demo_index = idx

        if idx == 0: demo_0()
        if idx == 1: demo_1()
        if idx == 2: demo_2()
        if idx == 3: demo_3()


    # MARK: launch_bomb
    @parameter
    fn launch_bomb():
        if not bomb:
            bomb = Reference(bodies[num_bodies])
            bomb.value()[].set(Vec2(1.0, 1.0), 50.0)
            bomb.value()[].friction = 0.2
            world.add(bomb.value()[])
            num_bodies += 1

        bomb.value()[].position = Vec2(random_float64(-15.0, 15.0).cast[DType.float32](), 15.0)
        bomb.value()[].rotation = random_float64(-1.5, 1.5).cast[DType.float32]()
        bomb.value()[].velocity = bomb.value()[].position * -1.5
        bomb.value()[].angular_velocity = random_float64(-20.0, 20.0).cast[DType.float32]()

    # MARK: draw_body
    @parameter
    # fn draw_body(body: Reference[Body, _, _]):
    fn draw_body(body: Body ):
        # Calculate rotation matrix
        var R: Mat22 = Mat22(body.rotation)
        var x: Vec2 = body.position
        var h: Vec2 = body.width * 0.5

        # Calculate vertices
        var v1 = x + R * Vec2(-h.x, -h.y)
        var v2 = x + R * Vec2( h.x, -h.y)
        var v3 = x + R * Vec2( h.x,  h.y)
        var v4 = x + R * Vec2(-h.x,  h.y)

        raylib.rl_begin(DrawModes.RL_LINES)
        # Choose color based on body
        if bomb:
            if UnsafePointer.address_of(body) == UnsafePointer.address_of(bomb.value()[]):
                raylib.rl_color_4ub(102, 229, 102, 255)
            else:
                raylib.rl_color_4ub(204, 204, 229, 255)
        else:
            raylib.rl_color_4ub(204, 204, 229, 255)
            

        raylib.rl_vertex_2f(v2.x, v2.y)
        raylib.rl_vertex_2f(v1.x, v1.y)

        raylib.rl_vertex_2f(v1.x, v1.y)
        raylib.rl_vertex_2f(v4.x, v4.y)

        raylib.rl_vertex_2f(v2.x, v2.y)
        raylib.rl_vertex_2f(v3.x, v3.y)

        raylib.rl_vertex_2f(v3.x, v3.y)
        raylib.rl_vertex_2f(v4.x, v4.y)

        raylib.rl_end()


    # MARK: draw_joint
    @parameter
    # fn draw_joint(joint: Reference[Joint[__lifetime_of(bodies)], _, _]):
    fn draw_joint(joint: Joint):
        # Extract body data
        var b1 = joint.body1
        var b2 = joint.body2

        # Calculate rotation matrices
        var R1 = Mat22(b1.value()[].rotation)
        var R2 = Mat22(b2.value()[].rotation)

        # Calculate positions
        var x1 = b1.value()[].position
        var p1 = x1 + R1 * joint.local_anchor1

        var x2 = b2.value()[].position
        var p2 = x2 + R2 * joint.local_anchor2

        raylib.rl_color_4ub(102, 229, 102, 255)
        raylib.rl_begin(DrawModes.RL_LINES)

        raylib.rl_vertex_2f(x1.x, x1.y)
        raylib.rl_vertex_2f(p1.x, p1.y)
        raylib.rl_vertex_2f(x2.x, x2.y)
        raylib.rl_vertex_2f(p2.x, p2.y)

        raylib.rl_end()


    # MARK: keyboard_events
    @parameter
    fn handle_keyboard_events():
        var num_keys = Set[Int](
                Keyboard.KEY_ZERO,
                Keyboard.KEY_ONE,
                Keyboard.KEY_TWO,
                Keyboard.KEY_THREE,
                Keyboard.KEY_FOUR,
                Keyboard.KEY_FIVE,
                Keyboard.KEY_SIX,
                Keyboard.KEY_SEVEN,
                Keyboard.KEY_EIGHT,
                Keyboard.KEY_NINE
            )

        var key = int(raylib.get_key_pressed())

        if key == Keyboard.KEY_NULL:
            return

        if key in num_keys:
            init_demo(key - Keyboard.KEY_ZERO)

        elif key == Keyboard.KEY_A:
            world.accumulate_impulses = not world.accumulate_impulses

        elif key == Keyboard.KEY_P:
            world.position_correction = not world.position_correction
            
        elif key == Keyboard.KEY_W:
            world.warm_starting = not world.warm_starting

        elif key == Keyboard.KEY_SPACE:
            launch_bomb()


    # MARK: draw_info_box
    @parameter
    fn draw_info_box():
        var boarder = BuiltinColors.WHITE
        var font_size = 20
        var x = 20

        var a = "(A)ccumulation: YES" if world.accumulate_impulses else "(A)ccumulation: NO"
        var p = "(P)osition Correction: YES" if world.position_correction else "(P)osition Correction: NO"
        var w = "(W)arm Starting: YES" if world.warm_starting else "(W)arm Starting: NO"

        raylib.draw_rectangle_lines( 10, 10, 420, 170, UnsafePointer.address_of(boarder))
        raylib.draw_text(demo_strings[demo_index].unsafe_cstr_ptr(), x, 20, font_size, UnsafePointer.address_of(light_red))
        raylib.draw_text("Keys: 1-9 Demos, Space to Launch Bomb".unsafe_cstr_ptr(), x, 50, font_size, UnsafePointer.address_of(light_red))
        raylib.draw_text(a.unsafe_cstr_ptr(), x, 80, font_size, UnsafePointer.address_of(light_red))
        raylib.draw_text(p.unsafe_cstr_ptr(), x, 110, font_size, UnsafePointer.address_of(light_red))
        raylib.draw_text(w.unsafe_cstr_ptr(), x, 140, font_size, UnsafePointer.address_of(light_red))


    # MARK: main_loop
    @parameter
    fn main_loop() raises:
        raylib.init_window(width, height, 'Fire Physics Engine')
        raylib.set_target_fps(FPS)

        var camera: Camera2D = Camera2D()
        camera.offset = Vec2( Float32(width) * 0.5, Float32(height) * .9 )
        camera.target = Vec2( 0, 0 )
        camera.rotation = 180.0
        camera.zoom = 35.0

        # Initialize the demo
        var i = 1
        init_demo(i)

        while not raylib.window_should_close():
            raylib.begin_drawing()
            raylib.clear_background(UnsafePointer.address_of(black))
            raylib.begin_mode_2d(UnsafePointer.address_of(camera))
            
            # Update the world
            world.step(time_step)

            # Draw bodies and joints
            for i in range(num_bodies):
                draw_body(bodies[i])

            for j in range(num_joints): 
                draw_joint(joints[j])

            # draw contact points
            for item in world.arbiters.items():
                for i in range(item[].value.num_contacts):
                    var p = item[].value.contacts[i].position
                    raylib.draw_circle_v(UnsafePointer.address_of(p), 0.08, UnsafePointer.address_of(red))

            raylib.end_mode_2d()
            raylib.end_drawing()

            handle_keyboard_events()
            draw_info_box()

        raylib.close_window()


    main_loop()
    _ = world
