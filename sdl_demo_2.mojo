
from random import random_float64, seed, random_si64
from math import sin, cos

import sdl
import infrared 

from src import *


# MARK: Constants
# alias SCREENWIDTH: Int = 1280
# alias SCREENHEIGHT: Int = 720
# alias FPS = 170
alias iterations: Int = 10
alias GRAVITY = Vec2(0.0, -100.0)

alias K_PI: Float32 = 3.14159265358979323846264
alias INF = Float32.MAX
alias background_clear = Color(12, 8, 6, 0)

alias scale = 1
alias screen_width = 1600
alias screen_height = 1000
alias scene_width = screen_width // scale
alias scene_height = screen_height // scale

alias keys = sdl.Keys

struct Scene[gravity: Vec2, iterations: Int, screen_width: Int, screen_height: Int]:
    var bodies: InlineArray[Body, 200]
    var joints: InlineArray[Joint, 100]
    var world: World[gravity, iterations]
    var _cameras: List[Camera]

    var num_bodies: Int
    var num_joints: Int


    fn __init__(inout self, renderer: Renderer) raises:
        self.bodies = InlineArray[Body, 200](Body())
        self.joints = InlineArray[Joint, 100](Joint())

        self.world = World[gravity, iterations]()
        
        self._cameras = List[Camera](capacity=1000)
        self._cameras.append(Camera(renderer, g2.Multivector(1, g2.Vector(800, 500)), g2.Vector(800, 500), DRect[DType.float32](0, 0, 1, 1)))

        self.num_bodies = 0
        self.num_joints = 0


    fn draw(self, renderer: Renderer) raises:
        renderer.set_color(background_clear)
        renderer.clear()
        for camera in self._cameras:
            camera[].draw(self.world, renderer, Vec2(screen_width, screen_height))

    fn add_body(inout self, pos: Tuple[Int, Int]):
        self.bodies[self.num_bodies].set(Vec2(50.0, 50.0), 200.0)
        self.bodies[self.num_bodies].position = Vec2(pos[0], pos[1]).screen_to_world(Vec2(screen_width, screen_height))
        self.world.add(UnsafePointer[Body].address_of(self.bodies[self.num_bodies]))
        self.num_bodies += 1

    fn demo_1(inout self):
        var y_offset = sin(K_PI/4) * 500
        # Set the floor
        self.bodies[self.num_bodies].set(Vec2(1000.0, 20.0), INF)
        self.bodies[self.num_bodies].position = Vec2(0.0, -y_offset)
        self.world.add(UnsafePointer[Body].address_of(self.bodies[self.num_bodies]))
        self.num_bodies += 1

        # Set the left wall
        self.bodies[self.num_bodies].set(Vec2(1000.0, 20.0), INF)
        self.bodies[self.num_bodies].position = Vec2(-500.0 + -y_offset, 0)
        self.bodies[self.num_bodies].rotation = 3 * K_PI / 4
        self.world.add(UnsafePointer[Body].address_of(self.bodies[self.num_bodies]))
        self.num_bodies += 1

        # Set the right wall
        self.bodies[self.num_bodies].set(Vec2(1000.0, 20.0), INF)
        self.bodies[self.num_bodies].position = Vec2(500.0 + y_offset, 0)
        self.bodies[self.num_bodies].rotation = K_PI / 4 
        self.world.add(UnsafePointer[Body].address_of(self.bodies[self.num_bodies]))
        self.num_bodies += 1

        # Set the second box
        self.bodies[self.num_bodies].set(Vec2(50.0, 50.0), 200.0)
        self.bodies[self.num_bodies].position = Vec2(0.0, 4.0)
        self.world.add(UnsafePointer[Body].address_of(self.bodies[self.num_bodies]))
        self.num_bodies += 1


    fn update(inout self, time_step: Float32, renderer: Renderer) raises:
        self.world.step(time_step)
        self.draw(renderer)


    fn init_demo(inout self):
        self.world.clear()
        for i in range(self.num_bodies):
            self.bodies[i].reset()
        for j in range(self.num_joints):
            self.joints[j].reset() 

        print("bodies and joints reset")

        self.num_bodies = 0
        self.num_joints = 0

        self.demo_1()



def main():
    var mojo_sdl = sdl.SDL(video=True, timer=True, events=True)
    var window = sdl.Window(mojo_sdl, "Thermo", screen_width, screen_height)
    var keyboard = sdl.Keyboard(mojo_sdl)
    var mouse = sdl.Mouse(mojo_sdl)
    var renderer = sdl.Renderer(window^, flags = sdl.RendererFlags.SDL_RENDERER_ACCELERATED)
    var clock = sdl.Clock(mojo_sdl, 1000)
    var running = True

    # sdl._sdl.render_set_scale(renderer._renderer_ptr, scale, scale)

    var scene = Scene[GRAVITY, iterations, scene_width, scene_height](renderer)
    scene.init_demo()
    var time_step: Float32 = 1.0 / 60.0
    # var rect = AABB(Vec2(-50, 200), Vec2(50, 100)).to_rect(Vec2(screen_width, screen_height))
    # var test_color = Color(255, 0, 0)

    # var x1 = Vec2(-500, 0).world_to_screen(Vec2(screen_width, screen_height))
    # var x2 = Vec2(500, 0).world_to_screen(Vec2(screen_width, screen_height))

    # var y1 = Vec2(0, 500).world_to_screen(Vec2(screen_width, screen_height))
    # var y2 = Vec2(0, -500).world_to_screen(Vec2(screen_width, screen_height))

    # var test_color2 = Color(0, 255, 0)
    # var rot = sin(K_PI/4) * -500
    # var p1 = Vec2(-500, rot).world_to_screen(Vec2(screen_width, screen_height))
    # var p2 = Vec2(500, rot).world_to_screen(Vec2(screen_width, screen_height))

    var spawn = False
    
    while running:
        for event in mojo_sdl.event_list():
            if event[].isa[sdl.events.QuitEvent]():
                running = False
            if event[].isa[sdl.events.MouseButtonEvent]():
                if event[].unsafe_get[sdl.events.MouseButtonEvent]()[].clicks == 1 and event[].unsafe_get[sdl.events.MouseButtonEvent]()[].state == 1:
                    scene.add_body(mouse.get_position())
                    spawn = True
                elif event[].unsafe_get[sdl.events.MouseButtonEvent]()[].state == 0:
                    spawn = False
            if event[].isa[sdl.events.KeyDownEvent]():
                if event[].unsafe_get[sdl.events.KeyDownEvent]()[].key == keys.n1:
                    scene.init_demo()
                    
        clock.tick()

        # var screen_cursor = mouse.get_position()
        # if spawn:
        #     scene.add_body(mouse.get_position())

        scene.update(time_step, renderer)

        # renderer.draw_rect(rect)

        # renderer.set_color(test_color)
        # renderer.draw_line(x1.x, x1.y, x2.x, x2.y)
        # renderer.draw_line(y1.x, y1.y, y2.x, y2.y)

        # renderer.set_color(test_color2)
        # renderer.draw_line(p1.x, p1.y, p2.x, p2.y)

        renderer.present()