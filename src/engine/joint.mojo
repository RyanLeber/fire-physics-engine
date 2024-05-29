
from collections import Optional

from .body import Body
from .world import World
from src.engine_utils import (
    Vec2,
    Mat22,
    scalar_vec_mul,
    mat_add,
    cross
    )


@value
struct Joint[lifetime: MutableLifetime](CollectionElement):
    """An object to define a Physics Joint in 2D.

    Attributes:
    ```
        var M: Mat22
        var local_anchor1: Vec2
        var local_anchor2: Vec2
        var r1: Vec2
        var r2: Vec2
        var bias: Vec2
        var P: Vec2
        var bias_factor: Float32
        var softness: Float32
        var body1: Self._ref_type
        var body2: Self._ref_type
    ```
    """
    var M: Mat22
    var local_anchor1: Vec2
    var local_anchor2: Vec2
    var r1: Vec2
    var r2: Vec2
    var bias: Vec2
    var P: Vec2
    var bias_factor: Float32
    var softness: Float32
    var body1: Optional[Reference[Body, True, lifetime]]
    var body2: Optional[Reference[Body, True, lifetime]]


    fn __init__(inout self):
        self.M = Mat22(Vec2(0.0, 0.0),Vec2(0.0, 0.0))
        self.local_anchor1 = Vec2(0.0, 0.0)
        self.local_anchor2 = Vec2(0.0, 0.0)
        self.r1 = Vec2(0.0, 0.0)
        self.r2 = Vec2(0.0, 0.0)
        self.bias = Vec2(0.0, 0.0)
        self.P = Vec2(0.0, 0.0)
        self.bias_factor = 0.0
        self.softness = 0.0

        self.body1 = None
        self.body2 = None

    fn reset(inout self):
        self.M = Mat22(Vec2(0.0, 0.0),Vec2(0.0, 0.0))
        self.local_anchor1 = Vec2(0.0, 0.0)
        self.local_anchor2 = Vec2(0.0, 0.0)
        self.r1 = Vec2(0.0, 0.0)
        self.r2 = Vec2(0.0, 0.0)
        self.bias = Vec2(0.0, 0.0)
        self.P = Vec2(0.0, 0.0)
        self.bias_factor = 0.0
        self.softness = 0.0

        self.body1 = None
        self.body2 = None

    fn set(inout self, b1: Reference[Body, True, lifetime], b2: Reference[Body, True, lifetime], anchor: Vec2):
        self.body1 = b1
        self.body2 = b2

        var Rot1T = Mat22(b1[].rotation).transpose()
        var Rot2T = Mat22(b2[].rotation).transpose()

        self.local_anchor1 = Rot1T * (anchor - b1[].position)
        self.local_anchor2 = Rot2T * (anchor - b2[].position)

        self.P = Vec2(0.0, 0.0)
        self.softness = 0.0
        self.bias_factor = 0.2

    fn pre_step(inout self, inv_dt: Float32, world_warm_start: Bool, world_pos_cor: Bool):
        var body1 = self.body1.value()[]
        var body2 = self.body2.value()[]

        self.r1 = Mat22(body1[].rotation) * self.local_anchor1
        self.r2 = Mat22(body2[].rotation) * self.local_anchor2

        # Compute K matrix
        var K1 = Mat22()
        K1.col1[0] = body1[].inv_mass + body2[].inv_mass
        K1.col1[1] = 0.0

        K1.col2[0] = 0.0
        K1.col2[1] = body1[].inv_mass + body2[].inv_mass

        var K2 = Mat22()
        K2.col1[0] =  body1[].inv_i * self.r1[1] * self.r1[1]
        K2.col1[1] = -body1[].inv_i * self.r1[0] * self.r1[1]

        K2.col2[0] = -body1[].inv_i * self.r1[0] * self.r1[1]
        K2.col2[1] =  body1[].inv_i * self.r1[0] * self.r1[0]

        var K3 = Mat22()
        K3.col1[0] =  body2[].inv_i * self.r2[1] * self.r2[1]
        K3.col1[1] = -body2[].inv_i * self.r2[0] * self.r2[1]

        K3.col2[0] = -body2[].inv_i * self.r2[0] * self.r2[1]
        K3.col2[1] =  body2[].inv_i * self.r2[0] * self.r2[0]

        var K = K1 + K2 + K3
        K.col1[0] += self.softness
        K.col2[1] += self.softness

        self.M = K.invert()

        var p1 = body1[].position + self.r1
        var p2 = body2[].position + self.r2
        var dp = p2 - p1

        # World::positionCorrection check, represented as a global variable or constant
        if world_pos_cor:
            self.bias = dp * (-self.bias_factor * inv_dt)
        else:
            self.bias = Vec2(0.0, 0.0)

        # World::warmStarting check, represented as a global variable or constant
        if world_warm_start:
            body1[].velocity -= self.P * body1[].inv_mass
            body1[].angular_velocity -= body1[].inv_i * cross(self.r1, self.P)

            body2[].velocity += self.P * body2[].inv_mass
            body2[].angular_velocity += body2[].inv_i * cross(self.r2, self.P)

        else:
            self.P = Vec2(0.0, 0.0)

    fn apply_impulse(inout self):
        var body1 = self.body1.value()[]
        var body2 = self.body2.value()[]
        var dv = body2[].velocity + cross(body2[].angular_velocity, self.r2) - body1[].velocity - cross(body1[].angular_velocity, self.r1)

        var impulse = self.M * (self.bias - dv - self.P * self.softness)

        body1[].velocity -= impulse * body1[].inv_mass
        body1[].angular_velocity -= body1[].inv_i * cross(self.r1, impulse)

        body2[].velocity += impulse * body2[].inv_mass
        body2[].angular_velocity += body2[].inv_i * cross(self.r2, impulse)

        self.P += impulse

    fn __str__(self) -> String:
        return (
            "\n  M:          " + str(self.M) +
            "\n  anchor1:    " + str(self.local_anchor1) +
            "\n  anchor2:    " + str(self.local_anchor2) +
            "\n  r1:         " + str(self.r1) +
            "\n  r2:         " + str(self.r2) +
            "\n  bias:       " + str(self.bias) +
            "\n  P:          " + str(self.P) +
            "\n  bias_factor: " + str(self.bias_factor) +
            "\n  softness:   " + str(self.softness) +
            "\n  body1: " + str(UnsafePointer.address_of(self.body1.value()[]))+ "\n" + str(self.body1.value()[][]) +
            "\n  body2: " + str(UnsafePointer.address_of(self.body2.value()[]))+ "\n" + str(self.body2.value()[][]) 
        )
