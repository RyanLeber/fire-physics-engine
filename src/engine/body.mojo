
from math.limit import inf
from math import isinf
from memory import memcmp

from src.engine_utils import Vec2


@value
struct Body(CollectionElement):
    """
    An object to define a Physics Body in 2D.\n
    Attributes:\n
        var rotation: Float32
        var position: Vec2
        var velocity: Vec2
        var angularVelocity: Float32
        var force: Vec2
        var torque: Float32
        var friction: Float32
        
        var width: Vec2
        var mass: Float32
        var invMass: Float32
        var I: Float32
        var invI: Float32
    """
    var rotation: Float32
    var position: Vec2
    var velocity: Vec2
    var angularVelocity: Float32
    var force: Vec2
    var torque: Float32
    var friction: Float32
    
    var width: Vec2
    var mass: Float32
    var invMass: Float32
    var I: Float32
    var invI: Float32

    fn __init__(inout self):
        self.rotation = 0.0
        self.velocity = Vec2.zero()
        self.angularVelocity = 0.0
        self.force = Vec2.zero()
        self.torque = 0.0
        self.friction = 0.2
        self.position = Vec2.zero()
        self.width = Vec2(1.0, 1.0)
        self.mass = inf[DType.float32]()
        self.invMass = 0.0
        self.I = inf[DType.float32]()
        self.invI = 0.0

    # @always_inline
    # fn __eq__(self, rhs: Self) -> Bool:
    #     return memcmp(LegacyPointer.address_of(self), LegacyPointer.address_of(rhs), 1)

    @always_inline
    fn add_force(inout self, force: Vec2):
        self.force += force

    fn set(inout self, width: Vec2, mass: Float32):
        self.width = width
        self.mass = mass

        if not isinf(mass):  # Checking if mass is not infinity
            self.invMass = 1.0 / mass
            self.I = mass * (width.x * width.x + width.y * width.y) / 12.0
            self.invI = 1.0 / self.I
        else:
            self.invMass = 0.0
            self.I = inf[DType.float32]()
            self.invI = 0.0
