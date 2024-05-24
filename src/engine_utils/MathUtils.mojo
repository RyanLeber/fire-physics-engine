from math import rsqrt, cos, sin
from testing import assert_not_equal
from random import random_float64

alias K_PI = 3.14159265358979323846264

@register_passable
struct Vec2(Absable):
    @always_inline
    @staticmethod
    fn zero() -> Vec2:
        return Vec2(0,0)

    var data: SIMD[DType.float32, 2]

    @always_inline
    fn __init__(inout self, x: Float32, y: Float32):
        self.data = SIMD[DType.float32, 2](x, y)

    @always_inline
    fn __init__(inout self, data: SIMD[DType.float32, 2]):
        self.data = data

    @always_inline
    fn __copyinit__(inout self, other: Self):
        self.data = other.data

    @always_inline
    fn __getitem__(self, idx: Int) -> SIMD[DType.float32, 1]:
        return self.data[idx]

    @always_inline
    fn __setitem__(inout self, idx: Int, value: Float32):
        self.data[idx] = value

    @always_inline
    fn __setattr__[name: StringLiteral](inout self, val: Float32):
        @parameter
        if name == "x":
            self.data[0] = val
        elif name == "y":
            self.data[1] = val
        else:
            constrained[name == "x" or name == "y", "can only access with x or y members"]()

    @always_inline
    fn __getattr__[name: StringLiteral](borrowed self) -> Float32:
        @parameter
        if name == "x":
            return self.data[0]
        elif name == "y":
            return self.data[1]
        else:
            constrained[name == "x" or name == "y", "can only access with x or y members"]()
            return 0
        
    @always_inline
    fn __sub__(self, other: Vec2) -> Vec2:
        return self.data - other.data

    @always_inline
    fn __add__(self, other: Vec2) -> Vec2:
        return self.data + other.data

    @always_inline
    fn __matmul__(self, other: Vec2) -> Float32:
        return (self.data * other.data).reduce_add()

    @always_inline
    fn __mul__(self, k: Float32) -> Vec2:
        return self.data * k

    @always_inline
    fn __mul__(v: Self, m: Mat22) -> Vec2:
        return Vec2(m.col1.x * v.x + m.col2.x * v.y, m.col1.y * v.x + m.col2.y * v.y)

    @always_inline
    fn __iadd__(inout self, other: Vec2):
        self.data = self.data + other.data

    @always_inline
    fn __isub__(inout self, other: Vec2):
        self.data = self.data - other.data

    # @always_inline
    # fn __imul__(inout self, k: Float32):
    #     self.data = self.data * k

    @always_inline
    fn length(self) -> Float32:
        return rsqrt(self.data[0]**2 + self.data[1]**2)

    @always_inline
    fn __neg__(self) -> Vec2:
        return -self.data

    @always_inline
    fn __abs__(self) -> Vec2:
        return abs(self.data)

    fn __str__(self) -> String:
        return String(self.data)

    @always_inline
    fn normalize(self) -> Vec2:
        return self.data * rsqrt(self @ self)

    @always_inline
    fn cross(self, other: Vec2) -> Vec2:
        var self_zxy = self.data.shuffle[2, 0, 1, 3]()
        var other_zxy = other.data.shuffle[2, 0, 1, 3]()
        return (self_zxy * other.data - self.data * other_zxy).shuffle[
            2, 0, 1, 3
        ]()


@value
@register_passable
struct Mat22(Absable):
    var col1: Vec2
    var col2: Vec2

    @always_inline
    fn __init__(inout self):
        self.col1 = Vec2.zero()
        self.col2 = Vec2.zero()
        
    @always_inline
    fn __init__(inout self, col1: Vec2, col2: Vec2):
        self.col1 = col1
        self.col2 = col2

    @always_inline
    fn __init__(inout self, angle: Float32):
        var c: Float32 = cos(angle)
        var s: Float32 = sin(angle)

        self.col1 = Vec2(c, s)
        self.col2 = Vec2(-s, c)

    # @always_inline
    # fn __init__(inout self, angle: Float32):
    #     var c = cos(angle)
    #     var s = sin(angle)
    #     if abs(c) < abs(s):
    #         c = 0
    #         s = 1 * sign(s)
    #     else:
    #         c = 1 * sign(c)
    #         s = 0
    #     self.col1 = Vec2(c, s)
    #     self.col2 = Vec2(-s, c)

    @always_inline
    fn __mul__(A: Self, v: Vec2) -> Vec2:
        return Vec2(A.col1.x * v.x + A.col2.x * v.y, A.col1.y * v.x + A.col2.y * v.y)

    @always_inline
    fn __add__(self, other: Self) -> Self:
        return Self(self.col1 + other.col1, self.col2 + other.col2)

    @always_inline
    fn __abs__(self) -> Self:
        return Self(abs(self.col1), abs(self.col2))

    fn __str__(self) -> String:
        return "[col1: " + str(self.col1) + ", col2: " + str(self.col2) + " ]"

    fn transpose(self) -> Mat22:
        return Mat22(Vec2(self.col1.x, self.col2.x), Vec2(self.col1.y, self.col2.y))

    fn invert(self) -> Mat22:
        var a: Float32 = self.col1.x
        var b: Float32 = self.col2.x
        var c: Float32 = self.col1.y
        var d: Float32 = self.col2.y
        var det: Float32 = a * d - b * c
        debug_assert(det != 0.0, "Determinant is zero. Matrix is not invertible.")
        det = 1.0 / det
        return Mat22(Vec2(det * d, -det * c), Vec2(-det * b, det * a))


fn dot(a: Vec2, b: Vec2) -> Float32:
    return a.x * b.x + a.y * b.y

fn cross(a: Vec2, b: Vec2) -> Float32:
    return a.x * b.y - a.y * b.x

fn cross(v: Vec2, s: Float32) -> Vec2:
    return Vec2(s * v.y, -s * v.x)

fn cross(s: Float32, v: Vec2) -> Vec2:
    return Vec2(-s * v.y, s * v.x)

fn scalar_vec_mul(s: Float32, v: Vec2) -> Vec2:
    return v * s

fn mat_add(A: Mat22, B: Mat22) -> Mat22:
    return Mat22(A.col1 + B.col1, A.col2 + B.col2)

fn mat_mul(A: Mat22, B: Mat22) -> Mat22:
    return Mat22(A * B.col1, A * B.col2)

@always_inline
fn sign(x: Float32) -> Float32:
    return -1.0 if x < 0.0 else 1.0
