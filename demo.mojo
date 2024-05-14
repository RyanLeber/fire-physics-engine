
from random import random_float64, seed, random_si64
from math.limit import inf
from utils import InlineArray
from collections import Optional, Set, Dict

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
        i1_1,
        i1_0,
        Mat22,
        Vec2
    )


# MARK: Constants
alias SCREENWIDTH: Int = 1280
alias SCREENHEIGHT: Int = 720
alias FPS = 60
alias iterations: Int = 10
alias gravity: Vec2 = Vec2(0.0, -10.0)

alias K_PI = 3.14159265358979323846264

# MARK: Main
fn main() raises:
    alias width: Int = SCREENWIDTH
    alias height: Int = SCREENHEIGHT

    # seed()

    var demo_strings = InlineArray[StringLiteral, 9](
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
    var maroon = BuiltinColors.MAROON
    var light_red = Color(148, 68, 68, 255)

    var raylib = RayLib()

    var bodies = InlineArray[Body, 200](Body())
    var joints = InlineArray[Joint, 100](Joint())
    var bomb = UnsafePointer[Body].get_null()

    var num_bodies: Int = 0
    var num_joints: Int = 0
    var demo_index: Int = 0
    var time_step: Float32 = 1.0 / 60.0

    var ptr_set = List[Int]()
    print("[", end=" ")
    for i in range(15):
        var ptr = UnsafePointer.address_of(bodies[i])
        ptr_set.append(int(ptr))
        print(ptr, end=" ")
    print("]")

    var world = World(gravity, iterations) 

    # MARK: Platform
    @parameter
    fn demo_0():
        # Set the first box
        bodies[0].set(Vec2(100.0, 20.0), inf[DType.float32]())
        bodies[0].position = Vec2(0.0, -0.5 * bodies[0].width.y)
        world.add(Reference(bodies[0]))
        num_bodies += 1


    # MARK: demo_1, Single box
    @parameter
    fn demo_1():
        # Set the first box
        bodies[0].set(Vec2(100.0, 20.0), inf[DType.float32]())
        bodies[0].position = Vec2(0.0, -0.5 * bodies[0].width.y)
        world.add(Reference(bodies[0]))
        num_bodies += 1

        # Set the second box
        bodies[1].set(Vec2(1.0, 1.0), 200.0)
        bodies[1].position = Vec2(0.0, 4.0)
        world.add(Reference(bodies[1]))
        num_bodies += 1


    # MARK: demo_2, A simple pendulum
    @parameter
    fn demo_2():
        # Set the first box
        bodies[0].set(Vec2(100.0, 20.0), inf[DType.float32]())
        bodies[0].friction = 0.2
        bodies[0].position = Vec2(0.0, -0.5 * bodies[0].width.y)
        bodies[0].rotation = 0.0
        world.add(Reference(bodies[0]))

        # Set the second box
        bodies[1].set(Vec2(1.0, 1.0), 100.0)
        bodies[1].friction = 0.2
        bodies[1].position = Vec2(9.0, 11.0)
        bodies[1].rotation = 0.0
        world.add(Reference(bodies[1]))

        num_bodies += 2

        joints[0].set(bodies[0], bodies[1], Vec2(0.0, 11.0))
        world.add(Reference(joints[0]))
        num_joints += 1


    # MARK: demo_3, Varying friction coefficients
    @ parameter
    fn demo_3():
        var i = 0
        bodies[i].set(Vec2(100.0, 20.0), inf[DType.float32]())
        bodies[i].position = Vec2(0.0, -0.5 * bodies[i].width.y)
        world.add(Reference(bodies[i]))
        i += 1

        bodies[i].set(Vec2(13.0, 0.25), inf[DType.float32]())
        bodies[i].position = Vec2(-2.0, 11.0)
        bodies[i].rotation = -0.25
        world.add(Reference(bodies[i]))
        i += 1

        bodies[i].set(Vec2(0.25, 1.0), inf[DType.float32]())
        bodies[i].position = Vec2(5.25, 9.5)
        world.add(Reference(bodies[i]))
        i += 1

        bodies[i].set(Vec2(13.0, 0.25), inf[DType.float32]())
        bodies[i].position = Vec2(2.0, 7.0)
        bodies[i].rotation = 0.25
        world.add(Reference(bodies[i]))
        i += 1

        bodies[i].set(Vec2(0.25, 1.0), inf[DType.float32]())
        bodies[i].position = Vec2(-5.25, 5.5)
        world.add(Reference(bodies[i]))
        i += 1

        bodies[i].set(Vec2(13.0, 0.25), inf[DType.float32]())
        bodies[i].position = Vec2(-2.0, 3.0)
        bodies[i].rotation = -0.25
        world.add(Reference(bodies[i]))
        i += 1

        var friction = InlineArray[Float32, 5](0.75, 0.5, 0.35, 0.1, 0.0)
        for j in range(5):
            bodies[i].set(Vec2(0.5, 0.5), 25.0)
            bodies[i].friction = friction[j]
            bodies[i].position = Vec2(-17.5 + 2.0 * i, 16.0)
            world.add(Reference(bodies[i]))
            i += 1

        num_bodies = i


    # MARK: demo_4, A vertical stack
    @parameter
    fn demo_4():
        # Set the first box
        bodies[0].set(Vec2(100.0, 20.0), inf[DType.float32]())
        bodies[0].friction = 0.2
        bodies[0].position = Vec2(0.0, -0.5 * bodies[0].width.y)
        bodies[0].rotation = 0.0
        world.add(Reference(bodies[0]))
        num_bodies += 1

        for i in range(1, 10):
            bodies[i].set(Vec2(1.0, 1.0), 1.0)
            bodies[i].friction = 0.2
            var x = random_float64(-0.1, 0.1)
            bodies[i].position = Vec2(x, i)
            # bodies[i].position = Vec2(x, 0.51 + 1.05 * i)
            world.add(Reference(bodies[i]))
            num_bodies += 1

    # MARK: demo_7
    # A suspension bridge
    @parameter
    fn demo_7():
        var i: Int = 0
        bodies[i].set(Vec2(100.0, 20.0), inf[DType.float32]())
        bodies[i].friction = 0.2
        bodies[i].position = Vec2(0.0, -0.5 * bodies[i].width.y)
        bodies[i].rotation = 0.0
        world.add(Reference(bodies[0]))
        i += 1

        var num_planks: Int = 15
        var mass: Float32 = 50.0

        for _ in range(num_planks):
            i += 1
            bodies[i].set(Vec2(1.0, 0.25), mass)
            bodies[i].friction = 0.2
            bodies[i].position = Vec2(-8.5 + 1.25 * i, 5.0)
            world.add(Reference(bodies[i]))

        # Tuning
        var frequencyHz: Float32 = 2.0
        var dampingRatio: Float32 = 0.7

        # frequency in radians
        var omega = 2.0 * K_PI * frequencyHz

        # damping coefficient
        var d = 2.0 * mass * dampingRatio * omega

        # spring stifness
        var k = mass * omega * omega

        # magic formulas
        var softness: Float32 = 1.0 / (d + time_step * k)
        var biasFactor: Float32 = time_step * k / (d + time_step * k)

        var j: Int = 0
        for _ in range(num_planks):
            joints[j].set(bodies[j+1], bodies[j+2], Vec2(-9.125 + 1.25 * i, 5.0))
            joints[j].softness = softness
            joints[j].biasFactor = biasFactor
            world.add(Reference(joints[j]))
            j += 1


        joints[j].set(Reference(bodies[num_planks]), Reference(bodies[i]), Vec2(-9.125 + 1.25 * num_planks, 5.0))
        joints[j].softness = softness
        joints[j].biasFactor = biasFactor
        world.add(Reference(joints[j]))
        j += 1



    # MARK: init_demo
    @parameter
    fn init_demo(idx: Int) raises:
        world.clear()
        for i in range(num_bodies):
            bodies[i].reset()
        for j in range(num_joints):
            joints[j].reset() 

        num_bodies = 0
        num_joints = 0
        bomb = UnsafePointer[Body].get_null()

        demo_index = idx

        if idx == 0: demo_0()
        if idx == 1: demo_1()
        if idx == 2: demo_2()
        if idx == 3: demo_3()
        if idx == 4: demo_4()
        # if idx == 5: demo_5()
        # if idx == 6: demo_6()
        if idx == 7: demo_7()


    # MARK: launch_bomb
    @parameter
    fn launch_bomb():
        if not bomb:
            bomb = UnsafePointer.address_of(bodies[num_bodies])
            bomb[].set(Vec2(1.0, 1.0), 50.0)
            bomb[].friction = 0.2
            world.add(bomb)
            num_bodies += 1

        bomb[].position = Vec2(0, 15.0)
        # bomb[].position = Vec2(random_float64(-15.0, 15.0), 15.0)
        bomb[].rotation = random_float64(-1.5, 1.5)
        bomb[].velocity = bomb[].position * -1.5
        bomb[].angularVelocity = random_float64(-20.0, 20.0)


    # MARK: draw_body
    @parameter
    fn draw_body(body: Reference[Body, _, _]):
        # Calculate rotation matrix
        var R: Mat22 = Mat22(body[].rotation)
        var x: Vec2 = body[].position
        var h: Vec2 = body[].width * 0.5

        # Calculate vertices
        var v1 = x + R * Vec2(-h.x, -h.y)
        var v2 = x + R * Vec2( h.x, -h.y)
        var v3 = x + R * Vec2( h.x,  h.y)
        var v4 = x + R * Vec2(-h.x,  h.y)

        raylib.rl_begin(DrawModes.RL_LINES)
        # Choose color based on body
        if UnsafePointer.address_of(body) == bomb:
            raylib.rl_color_4ub(102, 229, 102, 255)
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
    fn draw_joint(joint: Reference[Joint, _, _]):
        # Extract body data
        var b1 = joint[].body1
        var b2 = joint[].body2

        # Calculate rotation matrices
        var R1 = Mat22(b1[].rotation)
        var R2 = Mat22(b2[].rotation)

        # Calculate positions
        var x1 = b1[].position
        var p1 = x1 + R1 * joint[].localAnchor1

        var x2 = b2[].position
        var p2 = x2 + R2 * joint[].localAnchor2

        raylib.rl_color_4ub(102, 229, 102, 255)
        raylib.rl_begin(DrawModes.RL_LINES)

        raylib.rl_vertex_2f(x1.x, x1.y)
        raylib.rl_vertex_2f(p1.x, p1.y)
        raylib.rl_vertex_2f(x2.x, x2.y)
        raylib.rl_vertex_2f(p2.x, p2.y)

        raylib.rl_end()


    # MARK: keyboard_events
    @parameter
    fn handle_keyboard_events() raises -> None:
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
            return


    # MARK: draw_info_box
    @parameter
    fn draw_info_box():
        var boarder = BuiltinColors.WHITE
        var font_size = 20
        var x = 20

        var a = "(A)ccumulation: YES" if world.accumulate_impulses else "(A)ccumulation: NO"
        var p = "(P)osition Correction: YES" if world.position_correction else "(P)osition Correction: NO"
        var w = "(W)arm Starting: YES" if world.warm_starting else "(W)arm Starting: NO"

        raylib.draw_rectangle_lines( 10, 10, 420, 170, Reference(boarder))
        raylib.draw_text(demo_strings[demo_index].unsafe_ptr(), x, 20, font_size, Reference(light_red))
        raylib.draw_text("Keys: 1-9 Demos, Space to Launch Bomb".unsafe_ptr(), x, 50, font_size, Reference(light_red))
        raylib.draw_text(a.unsafe_ptr(), x, 80, font_size, Reference(light_red))
        raylib.draw_text(p.unsafe_ptr(), x, 110, font_size, Reference(light_red))
        raylib.draw_text(w.unsafe_ptr(), x, 140, font_size, Reference(light_red))


    # MARK: main_loop
    @parameter
    fn main_loop() raises:
        raylib.init_window(width, height, 'Hello Mojo')
        raylib.set_target_fps(60)

        var camera: Camera2D = Camera2D()
        camera.offset = Vec2( width * 0.5, height * .9 )
        camera.target = Vec2( 0, 0 )
        camera.rotation = 180.0
        camera.zoom = 35.0

        # Initialize the demo
        var i = 1
        init_demo(i)

        var arb_colors = Dict[ArbiterKey, Color]()

        while not raylib.window_should_close():

            raylib.begin_drawing()
            raylib.clear_background(Reference(black))
            raylib.begin_mode_2d(Reference(camera))
            
            # Update the world
            world.step(time_step)

            # Draw bodies and joints
            for i in range(num_bodies):  
                draw_body(Reference(bodies[i]))

            for j in range(num_joints): 
                draw_joint(Reference(joints[j]))

            for item in world.arbiters.items():
                if not item[].key in arb_colors:
                    var g = random_si64(0, 255).cast[DType.uint8]()
                    var b = random_si64(0, 255).cast[DType.uint8]()
                    var point = Color(230, g, b, 255 )
                    arb_colors[item[].key] = point

                for i in range(item[].value.num_contacts):
                    var p = item[].value.contacts[i].position
                    var tmp = arb_colors[item[].key]
                    raylib.draw_circle_v(Reference(p), 0.08, Reference(tmp))

            raylib.end_mode_2d()

            raylib.draw_fps(SCREENWIDTH - 90, 10)

            raylib.end_drawing()

            handle_keyboard_events()
            draw_info_box()

        raylib.close_window()

    main_loop()

    _ = bodies
    _ = joints
    _ = world
    _ = raylib
