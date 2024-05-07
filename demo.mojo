
from random import random_float64
import sys
from math.limit import inf
from utils import InlineArray
from collections import Optional, Set

from src.engine import Body, Joint, World
from src.engine_utils import (
        i1_1,
        i1_0,
        Mat22,
        Vec2,
    )

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
        DrawModes
    )

# # FOR DEV ONLY
# #%%%%%%%%%%%%%%%%%%%%%
# # define the location of the window to open
# x, y = 1200, -800
# import os
# os.environ['SDL_VIDEO_WINDOW_POS'] = "%d,%d" % (x,y)
# #%%%%%%%%%%%%%%%%%%%%%


alias SCREENWIDTH: Int = 1280
alias SCREENHEIGHT: Int = 720
alias FPS = 60

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

    alias origin = Vec2( SCREENWIDTH * 0.5, SCREENHEIGHT * 0.5)

    var red = BuiltinColors.RED
    var black = BuiltinColors.BLACK
    # var white = BuiltinColors.WHITE
    # var dark_gray = BuiltinColors.DARKGRAY

    var raylib = RayLib()

    var bodies = InlineArray[Body, 200](Body())
    var joints = InlineArray[Joint, 100](Joint())

    var bomb: Optional[UnsafePointer[Body]] = None

    var iterations: Int = 10
    var gravity: Vec2 = Vec2(0.0, -10.0)

    var numBodies: Int = 0
    var numJoints: Int = 0
    # var demoIndex: Int = 0

    var world = World(gravity, iterations)

    @parameter
    fn Demo1():
        # Set the first box
        bodies[0].set(Vec2(100.0, 20.0), inf[DType.float32]())
        bodies[0].position = Vec2(0.0, -0.5 * bodies[0].width.y)
        world.add(Reference(bodies[0]))
        numBodies += 1

        # Set the second box
        bodies[1].set(Vec2(1.0, 1.0), 200.0)
        bodies[1].position = Vec2(0.0, 4.0)
        world.add(Reference(bodies[1]))
        numBodies += 1


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

        numBodies += 2

        joints[0].set(bodies[0], bodies[1], Vec2(0.0, 11.0))
        world.add(Reference(joints[0]))
        numJoints += 1

    var demos = List[fn() capturing -> None](Demo1, Demo2)


    # A vertical stack
    @parameter
    fn Demo4():
        # Set the first box
        bodies[0].set(Vec2(100.0, 20.0), inf[DType.float32]())
        bodies[0].friction = 0.2
        bodies[0].position = Vec2(0.0, -0.5 * bodies[0].width.y)
        bodies[0].rotation = 0.0
        world.add(Reference(bodies[0]))
        numBodies += 1

        for i in range(1, 10):
            bodies[i].set(Vec2(1.0, 1.0), 1.0)
            bodies[i].friction = 0.2
            var x = random_float64(-0.1, 0.1)
            bodies[i].position = Vec2(x, 0.51 + 1.05 * i)
            world.add(Reference(bodies[i]))
            numBodies += 1


    @parameter
    fn init_demo(index: Int):
        print("trigger init demo")
        world.clear()
        numBodies = 0
        numJoints = 0
        bomb = None

        Demo2()
        # demos[index]()


    @parameter
    fn launch_bomb():
        if bomb is None:
            bomb = UnsafePointer.address_of(bodies[numBodies])
            bomb.value()[][].set(Vec2(1.0, 1.0), 50.0)
            bomb.value()[][].friction = 0.2
            world.add(bomb.value()[])
            numBodies += 1

        bomb.value()[][].position = Vec2(random_float64(-15.0, 15.0), 15.0)
        bomb.value()[][].rotation = random_float64(-1.5, 1.5)
        bomb.value()[][].velocity = bomb.value()[][].position * -1.5
        bomb.value()[][].angularVelocity = random_float64(-20.0, 20.0)

    @parameter
    fn draw_body(body: UnsafePointer[Body], i: Int):
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
        if body == bomb.value()[]:
            raylib.rl_color_4ub(102, 229, 102, 255)
        else:
            raylib.rl_color_4ub(204, 204, 229, 255)

        raylib.rl_vertex_2f(v1.x, v1.y)
        raylib.rl_vertex_2f(v2.x, v2.y)

        raylib.rl_vertex_2f(v1.x, v1.y)
        raylib.rl_vertex_2f(v4.x, v4.y)

        raylib.rl_vertex_2f(v2.x, v2.y)
        raylib.rl_vertex_2f(v3.x, v3.y)

        raylib.rl_vertex_2f(v3.x, v3.y)
        raylib.rl_vertex_2f(v4.x, v4.y)

        raylib.rl_end()


    @parameter
    fn draw_joint(joint: UnsafePointer[Joint]):
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
    fn handle_keyboard_events() -> None:
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
        camera.offset = Vec2( width / 2, height / 2 )
        camera.target = Vec2( 0, 0 )
        camera.rotation = 180.0
        # camera.zoom = 50.0
        camera.zoom = 20.0

        # Initialize the demo
        init_demo(0)

        while not raylib.window_should_close():
            handle_keyboard_events()

            raylib.begin_drawing()
            raylib.clear_background(Reference(black))
            raylib.begin_mode_2d(Reference(camera))
            
            # Update the world
            world.step(time_step)

            # Draw bodies and joints
            for i in range(numBodies):  
                draw_body(Reference(bodies[i]), i)

            for j in range(numJoints): 
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
    _ = bodies
    _ = joints
    _ = world
    _ = demos
