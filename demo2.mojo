
from random import random_float64
from math.limit import inf
from utils import InlineArray
from collections import Optional, Set, Dict

from src.engine import Body, Joint, World
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

alias SCREENWIDTH: Int = 1280
alias SCREENHEIGHT: Int = 720
alias FPS = 60

alias iterations: Int = 10
alias gravity: Vec2 = Vec2(0.0, -10.0)

alias demo_strings = Tuple(
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


fn main() raises:
    alias width: Int = SCREENWIDTH
    alias height: Int = SCREENHEIGHT

    var red = BuiltinColors.RED
    var black = BuiltinColors.BLACK

    var raylib = RayLib()

    var bodies = InlineArray[Body, 200](Body())
    var joints = InlineArray[Joint, 100](Joint())
    # var bomb: Reference[Body, i1_1, __lifetime_of(bodies)]
    var bomb = UnsafePointer[Body].get_null()

    var num_bodies: Int = 0
    var num_joints: Int = 0
    # var demo_index: Int = 0

    var world = World(gravity, iterations)

    @parameter
    fn Demo1():
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


    @parameter
    fn Demo2():
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


    # Varying friction coefficients
    @ parameter
    fn Demo3():
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
            i += j
            bodies[i].set(Vec2(0.5, 0.5), 25.0)
            bodies[i].friction = friction[i]
            bodies[i].position = Vec2(-7.5 + 2.0 * j, 14.0)
            world.add(Reference(bodies[i]))

        num_bodies = i


    # A vertical stack
    @parameter
    fn Demo4():
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
            bodies[i].position = Vec2(x, 0.51 + 1.05 * i)
            world.add(Reference(bodies[i]))
            num_bodies += 1


    @parameter
    fn init_demo(i: Int) raises:
        print("trigger init demo")
        world.clear()
        num_bodies = 0
        num_joints = 0
        bomb = UnsafePointer[Body].get_null()
        if i == 0: Demo1()
        if i == 1: Demo2()
        if i == 2: Demo3()
        if i == 3: Demo4()


    @parameter
    fn launch_bomb():
        if not bomb:
            bomb = UnsafePointer.address_of(bodies[num_bodies])
            bomb[].set(Vec2(1.0, 1.0), 50.0)
            bomb[].friction = 0.2
            world.add(bomb)
            num_bodies += 1

        bomb[].position = Vec2(random_float64(-15.0, 15.0), 15.0)
        bomb[].rotation = random_float64(-1.5, 1.5)
        bomb[].velocity = bomb[].position * -1.5
        bomb[].angularVelocity = random_float64(-20.0, 20.0)


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

    @parameter
    fn handle_keyboard_events() raises -> None:
        var num_keys = Set[Int](
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
            init_demo(key - Keyboard.KEY_ONE)

        elif key == Keyboard.KEY_A:
            world.accumulate_impulses = not world.accumulate_impulses

        elif key == Keyboard.KEY_P:
            world.position_correction = not world.position_correction
            
        elif key == Keyboard.KEY_W:
            world.warm_starting = not world.warm_starting

        elif key == Keyboard.KEY_SPACE:
            launch_bomb()
            return


    @parameter
    fn main_loop() raises:
        raylib.init_window(width, height, 'Hello Mojo')
        raylib.set_target_fps(60)

        var time_step: Float32 = 1.0 / 60.0

        var camera: Camera2D = Camera2D()
        camera.offset = Vec2( width * 0.5, height * .9 )
        camera.target = Vec2( 0, 0 )
        camera.rotation = 180.0
        # camera.zoom = 50.0
        camera.zoom = 35.0

        # Initialize the demo
        var i = 0
        init_demo(i)

        while not raylib.window_should_close():
            handle_keyboard_events()

            raylib.begin_drawing()
            raylib.clear_background(Reference(black))
            raylib.begin_mode_2d(Reference(camera))
            
            # Update the world
            world.step (time_step)

            # Draw bodies and joints
            for i in range(num_bodies):  
                draw_body(Reference(bodies[i]))

            for j in range(num_joints): 
                draw_joint(Reference(joints[j]))

            for item in world.arbiters.items():
                for i in range(len(item[].value.contacts)):
                    var p = item[].value.contacts[i].position
                    # print(i, p.x, p.y)
                    raylib.draw_circle_v(Reference(p), 0.1, Reference(red))

            raylib.end_mode_2d()

            # raylib.draw_text('This is a raylib example', 10, 40, 20, Reference(dark_gray))
            raylib.draw_fps(10, 10)

            raylib.end_drawing()

        raylib.close_window()

    main_loop()

    # _ = raylib
    # _ = bodies
    # _ = joints
    _ = world
    # _ = demos
