from math import sqrt, cos, sin
from random import random_float64

@value
struct AABB:
    var min: Vec2
    var max: Vec2

    fn to_rect(self, screen_dimensions: Vec2) -> DRect[DType.float32]:
        var p1 = self.min
        var p2 = self.max
        var size = p2 - p1
        var pos = p1.world_to_screen(screen_dimensions)
        return DRect[DType.float32](pos.x, pos.y, size.x, size.y)

    fn to_rect(self) -> DRect[DType.float32]:
        var p1 = self.min
        var p2 = self.max
        var size = p2 - p1
        var pos = p1
        return DRect[DType.float32](pos.x, pos.y, size.x, size.y)


@register_passable
struct Vec2(Absable):
    var data: SIMD[DType.float32, 2]

    @always_inline
    fn __init__(inout self, x: Float32, y: Float32):
        self.data = SIMD[DType.float32, 2](x, y)

    # @always_inline
    # fn __init__(inout self, x: Float64, y: Float64):
    #     self.data = SIMD[DType.float32, 2](x, y)

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

    @always_inline
    fn length(self) -> Float32:
        return sqrt(self.data[0]**2 + self.data[1]**2)

    @always_inline
    fn __neg__(self) -> Vec2:
        return -self.data

    @always_inline
    fn __abs__(self) -> Vec2:
        return abs(self.data)

    fn __str__(self) -> String:
        return str(self.data)

    @always_inline
    fn normalize(self) -> Vec2:
        return self.data * sqrt(self @ self)

    @always_inline
    fn cross(self, other: Vec2) -> Vec2:
        var self_zxy = self.data.shuffle[2, 0, 1, 3]()
        var other_zxy = other.data.shuffle[2, 0, 1, 3]()
        return (self_zxy * other.data - self.data * other_zxy).shuffle[
            2, 0, 1, 3
        ]()

    fn world_to_screen(self, screen_dimensions: Vec2) -> Vec2:
        var half_screen_width = screen_dimensions.x / 2
        var half_screen_height = screen_dimensions.y / 2
        var res = self
        res[1] = -res[1]

        res[0] += half_screen_width
        res[1] += half_screen_height
        return res

    fn screen_to_world(self, screen_dimensions: Vec2) -> Vec2:
        var half_screen_width = screen_dimensions.x / 2
        var half_screen_height = screen_dimensions.y / 2
        var res = self

        res[0] -= half_screen_width
        res[1] -= half_screen_height
        res[1] = -res[1]
        return res

    fn rotate(self, radians: Float32) -> Vec2:
        var s = sin(radians)
        var c = cos(radians)
        return Vec2(c * self.x - s * self.y, s * self.x + c * self.y)


@register_passable
struct Vec3:
    var data: SIMD[DType.float32, 4]

    @always_inline
    fn __init__(inout self, x: Float32, y: Float32, z: Float32):
        self.data = SIMD[DType.float32, 4](x, y, z, 0)

    @always_inline
    fn __init__(inout self, data: SIMD[DType.float32, 4]):
        self.data = data

    @always_inline
    fn __copyinit__(inout self, other: Self):
        self.data = other.data

    @always_inline
    fn __getitem__(self, idx: Int) -> Float32:
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
        elif name == "z":
            self.data[2] = val
        else:
            constrained[name == "x" or name == "y" or name == "z", "can only access with x or y members"]()

    @always_inline
    fn __getattr__[name: StringLiteral](borrowed self) -> Float32:
        @parameter
        if name == "x":
            return self.data[0]
        elif name == "y":
            return self.data[1]
        elif name == "z":
            return self.data[2]
        else:
            constrained[name == "x" or name == "y" or name == "z", "can only access with x or y members"]()
            return 0


@value
@register_passable
struct Mat22(Absable):
    var col1: Vec2
    var col2: Vec2

    @always_inline
    fn __init__(inout self):
        self.col1 = Vec2(0, 0)
        self.col2 = Vec2(0, 0)
        
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

    @always_inline
    fn __mul__(A: Self, v: Vec2) -> Vec2:
        return Vec2(A.col1.x * v.x + A.col2.x * v.y, A.col1.y * v.x + A.col2.y * v.y)

    @always_inline
    fn __add__(self, other: Self) -> Self:
        return Self(self.col1 + other.col1, self.col2 + other.col2)

    @always_inline
    fn __abs__(self) -> Self:
        return Self(abs(self.col1), abs(self.col2))

    @always_inline
    fn __str__(self) -> String:
        return "[col1: " + str(self.col1) + ", col2: " + str(self.col2) + " ]"

    @always_inline
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


@always_inline
fn dot(a: Vec2, b: Vec2) -> Float32:
    return a.x * b.x + a.y * b.y

@always_inline
fn cross(a: Vec2, b: Vec2) -> Float32:
    return a.x * b.y - a.y * b.x

@always_inline
fn cross(v: Vec2, s: Float32) -> Vec2:
    return Vec2(s * v.y, -s * v.x)

@always_inline
fn cross(s: Float32, v: Vec2) -> Vec2:
    return Vec2(-s * v.y, s * v.x)

@always_inline
fn scalar_vec_mul(s: Float32, v: Vec2) -> Vec2:
    return v * s

@always_inline
fn mat_add(A: Mat22, B: Mat22) -> Mat22:
    return Mat22(A.col1 + B.col1, A.col2 + B.col2)

@always_inline
fn mat_mul(A: Mat22, B: Mat22) -> Mat22:
    return Mat22(A * B.col1, A * B.col2)

@always_inline
fn sign(x: Float32) -> Float32:
    return -1 if x < 0 else 1
