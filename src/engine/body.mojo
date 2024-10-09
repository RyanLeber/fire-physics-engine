
from math import isinf

alias INF = Float32.MAX

@value
struct Body(CollectionElementNew):
    """
    An object to define a Physics Body in 2D.\n
    Attributes:\n
        var rotation: Float32
        var position: Vec2
        var velocity: Vec2
        var angular_velocity: Float32
        var force: Vec2
        var torque: Float32
        var friction: Float32
        
        var width: Vec2
        var mass: Float32
        var inv_mass: Float32
        var I: Float32
        var inv_i: Float32
    """
    var rotation: Float32
    var position: Vec2
    var velocity: Vec2
    var angular_velocity: Float32
    var force: Vec2
    var torque: Float32
    var friction: Float32
    
    var width: Vec2
    var mass: Float32
    var inv_mass: Float32
    var I: Float32
    var inv_i: Float32

    fn __init__(inout self):
        self.rotation = 0.0
        self.velocity = Vec2(0, 0)
        self.angular_velocity = 0.0
        self.force = Vec2(0, 0)
        self.torque = 0.0
        self.friction = 0.2
        self.position = Vec2(0, 0)
        self.width = Vec2(1.0, 1.0)
        self.mass = INF
        self.inv_mass = 0.0
        self.I = INF
        self.inv_i = 0.0

    fn __init__(inout self, *, copy: Self):
        self.rotation = copy.rotation
        self.velocity = copy.velocity
        self.angular_velocity = copy.angular_velocity
        self.force = copy.force
        self.torque = copy.torque
        self.friction = copy.friction
        self.position = copy.position
        self.width = copy.width
        self.mass = copy.mass
        self.inv_mass = copy.inv_mass
        self.I = copy.I
        self.inv_i = copy.inv_i

    fn reset(inout self):
        self.rotation = 0.0
        self.velocity = Vec2(0, 0)
        self.angular_velocity = 0.0
        self.force = Vec2(0, 0)
        self.torque = 0.0
        self.friction = 0.2
        self.position = Vec2(0, 0)
        self.width = Vec2(1.0, 1.0)
        self.mass = INF
        self.inv_mass = 0.0
        self.I = INF
        self.inv_i = 0.0
        

    @always_inline
    fn add_force(inout self, force: Vec2):
        self.force += force

    fn set(inout self, width: Vec2, mass: Float32, *, rotation: Bool=True):
        self.width = width
        self.mass = mass

        if not isinf(mass) and rotation:  # Checking if mass is not infinity
            self.inv_mass = 1.0 / mass
            self.I = mass * (width.x * width.x + width.y * width.y) / 12.0
            self.inv_i = 1.0 / self.I
        elif not isinf(mass) and not rotation:
            self.inv_mass = 1.0 / mass
            self.I = INF
            self.inv_i = 0.0
        else:
            self.inv_mass = 0.0
            self.I = INF
            self.inv_i = 0.0

    fn draw(self, camera: Camera, renderer: Renderer, color: Color) raises:
        # Calculate rotation matrix
        var R: Mat22 = Mat22(self.rotation)
        var x: Vec2 = self.position
        var h: Vec2 = self.width * 0.5

        # Calculate vertices
        var v1 = x + R * Vec2(-h.x, -h.y)
        var v2 = x + R * Vec2( h.x, -h.y)
        var v3 = x + R * Vec2( h.x,  h.y)
        var v4 = x + R * Vec2(-h.x,  h.y)

        renderer.set_color(color)

        renderer.draw_line(v2.x, v2.y, v1.x, v1.y)
        renderer.draw_line(v1.x, v1.y, v4.x, v4.y)
        renderer.draw_line(v2.x, v2.y, v3.x, v3.y)
        renderer.draw_line(v3.x, v3.y, v4.x, v4.y)

    fn draw(self, camera: Camera, renderer: Renderer, color: Color, screen_dimensions: Vec2) raises:
        # Calculate rotation matrix
        var R: Mat22 = Mat22(self.rotation)
        # var x: Vec2 = self.position.world_to_screen(screen_dimensions)
        var x: Vec2 = self.position
        var h: Vec2 = self.width * 0.5

        # Calculate vertices
        var v1 = (x + R * Vec2(-h.x, -h.y)).world_to_screen(screen_dimensions)
        var v2 = (x + R * Vec2( h.x, -h.y)).world_to_screen(screen_dimensions)
        var v3 = (x + R * Vec2( h.x,  h.y)).world_to_screen(screen_dimensions)
        var v4 = (x + R * Vec2(-h.x,  h.y)).world_to_screen(screen_dimensions)

        # var v1 = x + R * Vec2(-h.x, -h.y)
        # var v2 = x + R * Vec2( h.x, -h.y)
        # var v3 = x + R * Vec2( h.x,  h.y)
        # var v4 = x + R * Vec2(-h.x,  h.y)

        renderer.set_color(color)

        renderer.draw_line(v2.x, v2.y, v1.x, v1.y)
        renderer.draw_line(v1.x, v1.y, v4.x, v4.y)
        renderer.draw_line(v2.x, v2.y, v3.x, v3.y)
        renderer.draw_line(v3.x, v3.y, v4.x, v4.y)