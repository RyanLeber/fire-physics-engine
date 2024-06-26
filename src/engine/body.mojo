
from math import isinf
from memory import memcmp

from src.engine_utils import Vec2

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

    fn __str__(self) -> String:
        return (
            "    position:        " + str(self.position) +
            "\n    velocity:        " + str(self.velocity) +
            "\n    rotation:        " + str(self.rotation) +
            "\n    angular_velocity: " + str(self.angular_velocity) +
            "\n    force:           " + str(self.force) +
            "\n    torque:          " + str(self.torque) +
            "\n    friction:        " + str(self.friction) +
            "\n    width:           " + str(self.width) +
            "\n    mass:            " + str(self.mass) +
            "\n    inv_mass:         " + str(self.inv_mass) +
            "\n    I:               " + str(self.I) +
            "\n    inv_i:            " + str(self.inv_i)
        )


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
