
from random import random_float64
import sys
from math.limit import inf
from utils import InlineArray
from collections import Optional, Set

from src.engine import Body, Joint, World
from src.engine_utils import *
from src.engine_utils import (
        i1_1,
        i1_0,
        Mat22,
        Vec2,
        mat_vec_mul
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


alias SCREENWIDTH: Int = 1280
alias SCREENHEIGHT: Int = 720
alias FPS = 60
alias width: Int = SCREENWIDTH
alias height: Int = SCREENHEIGHT
alias iterations = 10
alias gravity = Vec2(0.0, -10.0)

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


struct Engine:
    var raylib: RayLib
    var world: World
    var demos: List[fn(inout self: Engine) -> None]
    var bodies: InlineArray[Body, 200]
    var joints: InlineArray[Joint, 100]
    var bomb: Optional[UnsafePointer[Body]]

    var numBodies: Int
    var numJoints: Int
    var demoIndex: Int

    fn __init__(inout self):
        self.raylib = RayLib()
        self.world = World(gravity, iterations)
        self.demos = List(Self.Demo1, Self.Demo2)
        self.bodies = InlineArray[Body, 200](Body())
        self.joints = InlineArray[Joint, 100](Joint())
        self.bomb= None

        self.numBodies = 0
        self.numJoints = 0
        self.demoIndex = 0

    fn Demo1(inout self):
        # Set the first box
        self.bodies[0].set(Vec2(100.0, 10.0), inf[DType.float32]())
        self.bodies[0].position = Vec2(0.0, -0.5 * self.bodies[0].width.y)
        self.world.add(Reference(self.bodies[0]))
        self.numBodies += 1

        # Set the second box
        self.bodies[1].set(Vec2(1.0, 1.0), 200.0)
        self.bodies[1].position = Vec2(0.0, 4.0)
        self.world.add(Reference(self.bodies[1]))
        self.numBodies += 1


    fn Demo2(inout self):
        # Set the first box
        self.bodies[0].set(Vec2(100.0, 20.0), inf[DType.float32]())
        self.bodies[0].friction = 0.2
        self.bodies[0].position = Vec2(0.0, -0.5 * self.bodies[0].width.y)
        self.bodies[0].rotation = 0.0
        self.world.add(Reference(self.bodies[0]))

        # Set the second box
        self.bodies[1].set(Vec2(1.0, 1.0), 100.0)
        self.bodies[1].friction = 0.2
        self.bodies[1].position = Vec2(9.0, 11.0)
        self.bodies[1].rotation = 0.0
        self.world.add(Reference(self.bodies[1]))

        self.numBodies += 2

        self.joints[0].set(self.bodies[0], self.bodies[1], Vec2(0.0, 11.0))
        self.world.add(Reference(self.joints[0]))
        self.numJoints += 1

    fn init_demo(inout self, index: Int):
        print("trigger init demo")
        self.world.clear()
        self.numBodies = 0
        self.numJoints = 0
        self.bomb = None

        # self.Demo1()
        self.demos[index](self)

    fn launch_bomb(inout self):
        if self.bomb is None:
            self.bomb = UnsafePointer.address_of(self.bodies[self.numBodies])
            self.bomb.value()[][].set(Vec2(1.0, 1.0), 50.0)
            self.bomb.value()[][].friction = 0.2
            self.world.add(self.bomb.value()[])
            self.numBodies += 1

        self.bomb.value()[][].position = Vec2(random_float64(-15.0, 15.0), 15.0)
        self.bomb.value()[][].rotation = random_float64(-1.5, 1.5)
        self.bomb.value()[][].velocity = self.bomb.value()[][].position * -1.5
        self.bomb.value()[][].angularVelocity = random_float64(-20.0, 20.0)


    fn draw_body(self, body: UnsafePointer[Body]):
        # Calculate rotation matrix
        var R: Mat22 = Mat22(body[].rotation)
        var x: Vec2 = body[].position
        var h: Vec2 = body[].width * 0.5

        # Calculate vertices
        var v1 = x + R * Vec2(-h.x, -h.y)
        var v2 = x + R * Vec2( h.x, -h.y)
        var v3 = x + R * Vec2( h.x,  h.y)
        var v4 = x + R * Vec2(-h.x,  h.y)

        self.raylib.rl_begin(DrawModes.RL_LINES)
        # Choose color based on body
        if body == self.bomb.value()[]:
            self.raylib.rl_color_4ub(102, 229, 102, 255)
        else:
            self.raylib.rl_color_4ub(204, 204, 229, 255)

        self.raylib.rl_vertex_2f(v1.x, v1.y)
        self.raylib.rl_vertex_2f(v2.x, v2.y)

        self.raylib.rl_vertex_2f(v1.x, v1.y)
        self.raylib.rl_vertex_2f(v4.x, v4.y)

        self.raylib.rl_vertex_2f(v2.x, v2.y)
        self.raylib.rl_vertex_2f(v3.x, v3.y)

        self.raylib.rl_vertex_2f(v3.x, v3.y)
        self.raylib.rl_vertex_2f(v4.x, v4.y)

        self.raylib.rl_end()


    fn draw_joint(self, joint: UnsafePointer[Joint]):
        # Extract body data
        var b1 = joint[].body1
        var b2 = joint[].body2

        # Calculate rotation matrices
        var R1 = Mat22(b1[].rotation)
        var R2 = Mat22(b2[].rotation)

        # Calculate positions
        var x1 = b1[].position
        var p1 = x1 + mat_vec_mul(R1, joint[].localAnchor1)

        var x2 = b2[].position
        var p2 = x2 + mat_vec_mul(R2, joint[].localAnchor2)

        self.raylib.rl_color_4ub(102, 229, 102, 255)
        self.raylib.rl_begin(DrawModes.RL_LINES)

        self.raylib.rl_vertex_2f(x1.x, x1.y)
        self.raylib.rl_vertex_2f(p1.x, p1.y)
        self.raylib.rl_vertex_2f(x2.x, x2.y)
        self.raylib.rl_vertex_2f(p2.x, p2.y)

        self.raylib.rl_end()


    fn handle_keyboard_events(inout self) -> None:
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

        var key = int(self.raylib.get_key_pressed())

        if key == Keyboard.KEY_NULL:
            return

        if key in num_keys:
            self.init_demo(key - Keyboard.KEY_ONE)

        elif key == Keyboard.KEY_A:
            self.world.accumulate_impulses = not self.world.accumulate_impulses

        elif key == Keyboard.KEY_P:
            self.world.position_correction = not self.world.position_correction
            
        elif key == Keyboard.KEY_W:
            self.world.warm_starting = not self.world.warm_starting

        elif key == Keyboard.KEY_SPACE:
            self.launch_bomb()


    fn main_loop(inout self) raises:
        self.raylib.init_window(width, height, 'Hello Mojo')
        self.raylib.set_target_fps(60)

        var time_step: Float32 = 1.0 / 60.0

        var camera: Camera2D = Camera2D()
        camera.offset = Vec2( width / 2, height / 2 )
        camera.target = Vec2( 0, 0 )
        camera.rotation = 180.0
        # camera.zoom = 50.0
        camera.zoom = 20.0

        var black = BuiltinColors.BLACK
        var red = BuiltinColors.RED

        # Initialize the demo
        self.init_demo(0)

        while not self.raylib.window_should_close():
            self.handle_keyboard_events()

            self.raylib.begin_drawing()
            self.raylib.clear_background(Reference(black))
            self.raylib.begin_mode_2d(Reference(camera))
            
            # Update the world
            self.world.step(time_step)

            # Draw bodies and joints
            for i in range(self.numBodies):  
                self.draw_body(Reference(self.bodies[i]))

            for j in range(self.numJoints): 
                self.draw_joint(Reference(self.joints[j]))

            for item in self.world.arbiters.items():
                
                for i in range(len(item[].value.contacts)):
                    var p = item[].value.contacts[i].position
                    self.raylib.draw_circle_v(Reference(p), 0.1, Reference(red))

            self.raylib.end_mode_2d()

            # raylib.draw_text('This is a raylib example', 10, 40, 20, Reference(dark_gray))
            self.raylib.draw_fps(10, 10)

            self.raylib.end_drawing()

        self.raylib.close_window()



fn main() raises:
    var engine = Engine()

    engine.main_loop()

