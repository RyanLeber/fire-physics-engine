
from random import random_float64
import sys
from math.limit import inf
from utils import InlineArray
from collections import Optional, Set

from src.engine import Joint, World
from src.engine_utils import (
        i1_1,
        i1_0,
        Mat22,
        Vec2,
        mat_vec_mul,
        RayLib,
        CameraMode,
        CameraProjection,
        Camera3D,
        Camera2D,
        Vector2,
        Vector3,
        DrawModes,
        Rectangle,
        Color,
        BuiltinColors,
        Keyboard
    )

@value
struct Body:
    var position: Vec2
    var width: Vec2
    var rotation: Float32


alias SCREENWIDTH: Int = 1280
alias SCREENHEIGHT: Int = 720
alias FPS = 60


fn main() raises:
    alias width: Int = SCREENWIDTH
    alias height: Int = SCREENHEIGHT

    alias origin = Vec2( SCREENWIDTH * 0.5, SCREENHEIGHT * 0.5)

    var white = BuiltinColors.WHITE
    var black = BuiltinColors.BLACK
    var dark_gray = BuiltinColors.DARKGRAY

    # Body: Color
    # var body_color: Color

    var raylib = RayLib()

    # var timeStep: Float32 = 1.0 / 60.0

    # @parameter
    # fn Demo1_edits():
    #     print("trigger demo 1")
    #     # Set the first box, PLATFORM
    #     bodies[0].set(Vec2(1000.0, 20.0), inf[DType.float32]())
    #     bodies[0].position = Vec2(0.0, SCREENHEIGHT - (0.5 * bodies[0].width.y))
    #     # bodies[0].position = Vec2(600.0, 700) 
    #     world.add(Reference(bodies[0]))
    #     numBodies += 1

    #     # Set the second box, PHYSICS BODY
    #     bodies[1].set(Vec2(100.0, 100.0), 200.0)
    #     bodies[1].position = Vec2(0.0, 4.0)
    #     world.add(Reference(bodies[1]))
    #     numBodies += 1

    @parameter
    fn handle_mouse_events():
        var mouse_pos = raylib.get_mouse_delta()
        var x_pos = raylib.get_mouse_x()
        var y_pos = raylib.get_mouse_y()
        # print("Mouse pos, X:", x_pos, "Y:", y_pos)

    @parameter
    fn draw_body(body: UnsafePointer[Body]):
        # Calculate rotation matrix
        var R: Mat22 = Mat22(body[].rotation)
        var x: Vec2 = body[].position
        var h: Vec2 = body[].width * 0.5

        # print("pre-transform, body,", i, "X:", x.x, "Y:", x.y)

        # x[0] += origin.x
        # x[1] = abs(x[1])

        # print("post-transform, body,", i, "X:", x.x, "Y:", x.y)

        # Calculate vertices
        var v1 = x + R * Vec2(-h.x, -h.y)
        var v2 = x + R * Vec2( h.x, -h.y)
        var v3 = x + R * Vec2( h.x,  h.y)
        var v4 = x + R * Vec2(-h.x,  h.y)
        # print("Vertices, body,", i)
        print("v1, X:", v1.x, "Y:", v1.y)
        print("v2, X:", v2.x, "Y:", v2.y)
        print("v3, X:", v3.x, "Y:", v3.y)
        print("v4, X:", v4.x, "Y:", v4.y)

        # Texture2D texShapes = { 1, 1, 1, 1, 7 };                // Texture used on shapes drawing (white pixel loaded by rlgl)
        # Rectangle texShapesRec = { 0.0f, 0.0f, 1.0f, 1.0f };    // Texture source rectangle used on shapes drawing
        var white = BuiltinColors.WHITE
        var point = BuiltinColors.RED

        raylib.draw_circle_v(Reference(v1), 0.1, Reference(white))

        raylib.rl_color_4ub(white.r, white.g, white.b, white.a)
        raylib.rl_begin(DrawModes.RL_LINES)

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
    fn drawing_test(body: UnsafePointer[Body], color: UnsafePointer[Color]):
        var pos = body[].position
        var width = body[].width
        raylib.draw_rectangle_v(Reference(pos), Reference(width), color)

    @parameter
    fn main_loop() raises:

        raylib.init_window(width, height, 'Hello Mojo')
        raylib.set_target_fps(60)

        var time_step: Float32 = 1.0 / 60.0

        var camera: Camera2D = Camera2D()
        camera.offset = Vec2( width / 2, height / 2 )
        camera.target = Vec2( 0, 0 )
        camera.rotation = 180.0
        camera.zoom = 50.0

        # var b1 = Body(Vec2(0, 0), Vec2(1.0, 1.0), 0)
        # b1.position = Vec2(0.0, 4.0)

        var b1 = Body(Vec2(0, 0), Vec2(1.0, 1.0), 0)
        b1.position = Vec2(0.0, 4.0)


        var rect_size = Vec2(1, 1)

        var b2_color = BuiltinColors.RED
        var b2 = Body(Vec2(0, 0), Vec2(100.0, 20.0), 0)
        b2.position = Vec2(0.0, -0.75 * b2.width.y)

        while not raylib.window_should_close():

            # var time_step = raylib.get_frame_time()
            # handle_mouse_events()

            # raylib.update_camera_2d(Reference(camera), CameraMode.CAMERA_ORBITAL)

            raylib.begin_drawing()

            raylib.clear_background(Reference(black))

            raylib.begin_mode_2d(Reference(camera))

            draw_body(Reference(b1))
            draw_body(Reference(b2))
            # drawing_test(Reference(b2), Reference(b2_color))
            # raylib.draw_rectangle_v(Reference(rect_pos), Reference(rect_size), Reference(rect_color))

            raylib.end_mode_2d()

            raylib.draw_fps(10, 10)

            raylib.end_drawing()

        raylib.close_window()
        # _ = b1

    main_loop()

