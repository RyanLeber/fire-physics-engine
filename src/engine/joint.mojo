
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
struct Joint(CollectionElement):
    """An object to define a Physics Joint in 2D.

    Attributes:
    ```
        var M: Mat22
        var localAnchor1: Vec2
        var localAnchor2: Vec2
        var r1: Vec2
        var r2: Vec2
        var bias: Vec2
        var P: Vec2
        var biasFactor: Float32
        var softness: Float32
        var body1: Self._ref_type
        var body2: Self._ref_type
    ```
    """
    var M: Mat22
    var localAnchor1: Vec2
    var localAnchor2: Vec2
    var r1: Vec2
    var r2: Vec2
    var bias: Vec2
    var P: Vec2
    var biasFactor: Float32
    var softness: Float32
    var body1: UnsafePointer[Body]
    var body2: UnsafePointer[Body]


    fn __init__(inout self):
        self.M = Mat22(Vec2(0.0, 0.0),Vec2(0.0, 0.0))
        self.localAnchor1 = Vec2(0.0, 0.0)
        self.localAnchor2 = Vec2(0.0, 0.0)
        self.r1 = Vec2(0.0, 0.0)
        self.r2 = Vec2(0.0, 0.0)
        self.bias = Vec2(0.0, 0.0)
        self.P = Vec2(0.0, 0.0)
        self.biasFactor = 0.0
        self.softness = 0.0

        self.body1 = UnsafePointer[Body].get_null()
        self.body2 = UnsafePointer[Body].get_null()

    fn reset(inout self):
        self.M = Mat22(Vec2(0.0, 0.0),Vec2(0.0, 0.0))
        self.localAnchor1 = Vec2(0.0, 0.0)
        self.localAnchor2 = Vec2(0.0, 0.0)
        self.r1 = Vec2(0.0, 0.0)
        self.r2 = Vec2(0.0, 0.0)
        self.bias = Vec2(0.0, 0.0)
        self.P = Vec2(0.0, 0.0)
        self.biasFactor = 0.0
        self.softness = 0.0

        self.body1 = UnsafePointer[Body].get_null()
        self.body2 = UnsafePointer[Body].get_null()

    fn set(inout self, b1: Reference[Body], b2: Reference[Body], anchor: Vec2):
        self.body1 = b1
        self.body2 = b2

        var Rot1T = Mat22(self.body1[].rotation).transpose()
        var Rot2T = Mat22(self.body2[].rotation).transpose()

        self.localAnchor1 = Rot1T * anchor - self.body1[].position
        self.localAnchor2 = Rot2T * anchor - self.body2[].position

        self.P = Vec2(0.0, 0.0)
        self.softness = 0.0
        self.biasFactor = 0.2

    fn pre_step(inout self, inv_dt: Float32, world_warm_start: Bool, world_pos_cor: Bool):

        self.r1 = Mat22(self.body1[].rotation) * self.localAnchor1
        self.r2 = Mat22(self.body2[].rotation) * self.localAnchor2
        # Compute K matrix
        var K1 = Mat22()
        K1.col1[0] = self.body1[].invMass + self.body2[].invMass
        K1.col2[0] = 0.0
        K1.col1[1] = 0.0
        K1.col2[1] = self.body1[].invMass + self.body2[].invMass

        var K2 = Mat22()
        K2.col1[0] = self.body1[].invI * self.r1[1] * self.r1[1]
        K2.col2[0] = -self.body1[].invI * self.r1[0] * self.r1[1]

        K2.col1[1] = -self.body1[].invI * self.r1[0] * self.r1[1]
        K2.col2[1] = self.body1[].invI * self.r1[0] * self.r1[0]

        var K3 = Mat22()
        K3.col1[0] = self.body2[].invI * self.r2[1] * self.r2[1]
        K3.col2[0] = -self.body2[].invI * self.r2[0] * self.r2[1]

        K3.col1[1] = -self.body2[].invI * self.r2[0] * self.r2[1]
        K3.col2[1] = self.body2[].invI * self.r2[0] * self.r2[0]

        var K = K1 + K2 + K3
        K.col1[0] += self.softness
        K.col2[1] += self.softness

        self.M = K.invert()

        var p1 = self.body1[].position + self.r1
        var p2 = self.body2[].position + self.r2
        var dp = p2 - p1

        # World::positionCorrection check, represented as a global variable or constant
        if world_pos_cor:
            self.bias = dp * (-self.biasFactor * inv_dt)
        else:
            self.bias = Vec2(0.0, 0.0)

        # World::warmStarting check, represented as a global variable or constant
        if world_warm_start:
            self.body1[].velocity -= self.P * self.body1[].invMass
            self.body1[].angularVelocity -= self.body1[].invI * cross(self.r1, self.P)
            self.body2[].velocity += self.P * self.body2[].invMass
            self.body2[].angularVelocity += self.body2[].invI * cross(self.r2, self.P)
        else:
            self.P = Vec2(0.0, 0.0)

    fn apply_impulse(inout self):
        var dv = self.body2[].velocity + cross(self.body2[].angularVelocity, self.r2) -
            self.body1[].velocity + cross(self.body1[].angularVelocity, self.r1)

        var impulse = self.M * (self.bias - dv - self.P * self.softness)

        self.body1[].velocity -= impulse * self.body1[].invMass
        self.body1[].angularVelocity -= self.body1[].invI * cross(self.r1, impulse)

        self.body2[].velocity += impulse * self.body2[].invMass
        self.body2[].angularVelocity += self.body2[].invI * cross(self.r2, impulse)

        self.P += impulse

    fn __str__(self) -> String:
        return (
            "\n  M:          " + str(self.M) +
            "\n  anchor1:    " + str(self.localAnchor1) +
            "\n  anchor2:    " + str(self.localAnchor2) +
            "\n  r1:         " + str(self.r1) +
            "\n  r2:         " + str(self.r2) +
            "\n  bias:       " + str(self.bias) +
            "\n  P:          " + str(self.P) +
            "\n  biasFactor: " + str(self.biasFactor) +
            "\n  softness:   " + str(self.softness) +
            "\n  body1: " + str(self.body1)+ "\n" + str(self.body1[]) +
            "\n  body2: " + str(self.body2)+ "\n" + str(self.body2[]) 
        )
