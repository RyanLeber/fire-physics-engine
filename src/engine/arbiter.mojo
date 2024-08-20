
from math import sqrt
from utils import Variant
from collections import InlineArray

from src.engine_utils import Vec2, Mat22, mat_add, scalar_vec_mul, cross, dot
from .body import Body
from .collide import collide
from .arbiterkey import ArbiterKey

@value
struct FeaturePair(CollectionElement):
    var e: Variant[Int32, Edges]

    fn __init__(inout self):
        self.e = Int32(0)

    fn __getitem__(inout self) -> ref [__lifetime_of(self)] Edges:
        if not self.e.isa[Edges]():
            self.e = Edges()
        return self.e[Edges]

    fn __getattr__[name: StringLiteral](self) -> Int32:
        if name == "value":
            return self.e.unsafe_get[Int32]()[]
        else:
            constrained[name == "value", "can only access value member"]()
            return 0

    fn __eq__(self, other: Self) -> Bool:
        if self.e.unsafe_get[Int32]()[] == other.e.unsafe_get[Int32]()[]:
                return True
        else: return False

    fn __str__(self) -> String:
        var val = self.value
        return "value: " + str(val) + ", edges: "+ str(SIMD[DType.int32, 4](val & 0xFF, (val >> 8) & 0xFF, (val >> 16) & 0xFF, (val >> 24) & 0xFF))



@value
struct Edges(CollectionElement):
    var in_edge1: UInt8
    var out_edge1: UInt8
    var in_edge2: UInt8
    var out_edge2: UInt8

    fn __init__(inout self):
        self.in_edge1 = 0
        self.out_edge1 = 0
        self.in_edge2 = 0
        self.out_edge2 = 0


@value
struct Contact(CollectionElementNew):
    var position: Vec2
    var normal: Vec2
    var r1: Vec2
    var r2: Vec2
    var separation: Float32
    var Pn: Float32
    var Pt: Float32
    var Pnb: Float32
    var mass_normal: Float32
    var mass_tangent: Float32
    var bias: Float32
    var feature: FeaturePair

    fn __init__(inout self):
        self.position = Vec2(0, 0)
        self.normal = Vec2(0, 0)
        self.r1 = Vec2(0, 0)
        self.r2 = Vec2(0, 0)
        self.separation = 0.0
        self.Pn = 0.0
        self.Pt = 0.0
        self.Pnb = 0.0
        self.mass_normal = 0.0
        self.mass_tangent = 0.0
        self.bias = 0.0
        self.feature = FeaturePair()

    fn __init__(inout self, *, copy:Self):
        self.position = copy.position
        self.normal = copy.normal
        self.r1 = copy.r1
        self.r2 = copy.r2
        self.separation = copy.separation
        self.Pn = copy.Pn
        self.Pt = copy.Pt
        self.Pnb = copy.Pnb
        self.mass_normal = copy.mass_normal
        self.mass_tangent = copy.mass_tangent
        self.bias = copy.bias
        self.feature = copy.feature

    
    fn __str__(self) -> String:
        return (
            "\n position:    " + str(self.position) +
            "\n normal:      " + str(self.normal) +
            "\n r1:          " + str(self.r1) +
            "\n r2           " + str(self.r2) +
            "\n separation:  " + str(self.separation) +
            "\n Pn:          " + str(self.Pn) +
            "\n Pt:          " + str(self.Pt) +
            "\n Pnb:         " + str(self.Pnb) +
            "\n mass_normal:  " + str(self.mass_normal) +
            "\n massTanget:  " + str(self.mass_tangent) +
            "\n bias:        " + str(self.bias) +
            "\n featurePair: " + str(self.feature)
        )


@value
struct Arbiter[lifetime: MutableLifetime](CollectionElement):
    alias MAX_POINTS = 2
    alias array_type = InlineArray[Contact, Self.MAX_POINTS]
    var contacts: Self.array_type
    var num_contacts: Int32
    var friction: Float32

    var b1: Reference[Body, lifetime]
    var b2: Reference[Body, lifetime]

    fn __init__(inout self, b1: Reference[Body, lifetime], b2: Reference[Body, lifetime]):
        var b1_ptr = UnsafePointer[Body].address_of(b1[])
        var b2_ptr = UnsafePointer[Body].address_of(b2[])
        if b1_ptr < b2_ptr:
            self.b1 = b1
            self.b2 = b2
        else:
            self.b1 = b2
            self.b2 = b1

        self.contacts = InlineArray[Contact, Self.MAX_POINTS](Contact())
        self.num_contacts = collide(self.contacts, self.b1, self.b2)

        self.friction = sqrt(self.b1[].friction * self.b2[].friction)


    fn update(
            inout self,
            inout new_contacts: InlineArray[Contact, Self.MAX_POINTS],
            num_new_contacts: Int32,
            world_warm_start: Bool):
        var merged_contacts = InlineArray[Contact, Self.MAX_POINTS](Contact())

        for i in range(num_new_contacts):
            var c_new = Reference(new_contacts[i])

            var k: Int = -1
            for j in range(self.num_contacts):

                var c_old = Reference(self.contacts[j])

                if c_new[].feature == c_old[].feature:
                    k = j
                    break

            if k > -1:
                var c = Reference(merged_contacts[i])
                var c_old = Reference(self.contacts[k])
                c[] = c_new[]

                if world_warm_start:
                    c[].Pn = c_old[].Pn
                    c[].Pt = c_old[].Pt
                    c[].Pnb = c_old[].Pnb
                else:
                    c[].Pn, c[].Pt, c[].Pnb = Float32(0.0), Float32(0.0), Float32(0.0)

            else:
                merged_contacts[i] = new_contacts[i]

        for i in range(num_new_contacts):
            self.contacts[i] = merged_contacts[i]

        self.num_contacts = num_new_contacts


    fn pre_step(inout self, inv_dt: Float32, world_pos_cor: Bool, accumulate_impulses: Bool):
        var k_allowedPenetration: Float32 = 0.01
        var k_biasFactor: Float32 = Float32(0.2) if world_pos_cor else 0

        var b1 = Reference(self.b1[])
        var b2 = Reference(self.b2[])

        for i in range(self.num_contacts):

            var c = Reference(self.contacts[i])

            var r1: Vec2 = c[].position - b1[].position
            var r2: Vec2 = c[].position - b2[].position

            # Precompute normal mass, tangent mass, and bias.
            var rn1: Float32 = dot(r1, c[].normal)
            var rn2: Float32 = dot(r2, c[].normal)
            var kNormal: Float32 = b1[].inv_mass + b2[].inv_mass

            kNormal += b1[].inv_i * (dot(r1, r1) - rn1 * rn1) + b2[].inv_i * (dot(r2, r2) - rn2 * rn2)
            c[].mass_normal = 1.0 / kNormal

            var tangent: Vec2 = cross(c[].normal, 1.0)
            var rt1: Float32 = dot(r1, tangent)
            var rt2: Float32 = dot(r2, tangent)
            var kTangent: Float32 = self.b1[].inv_mass + self.b2[].inv_mass
            kTangent += b1[].inv_i * (dot(r1, r1) - rt1 * rt1) + b2[].inv_i * (dot(r2, r2) - rt2 * rt2)
            c[].mass_tangent = 1.0 / kTangent

            c[].bias = -k_biasFactor * inv_dt * min(0, c[].separation + k_allowedPenetration)

            if accumulate_impulses:
                # Apply normal + friction impulse
                var P: Vec2 = (c[].normal * c[].Pn) + (tangent * c[].Pt)

                b1[].velocity -= P * b1[].inv_mass
                b1[].angular_velocity -= b1[].inv_i * cross(r1, P)

                b2[].velocity += P * b2[].inv_mass
                b2[].angular_velocity += b2[].inv_i * cross(r2, P)


    fn apply_impulse(inout self, accumulate_impulses: Bool):
        var b1 = Reference(self.b1[])
        var b2 = Reference(self.b2[])
        for i in range(self.num_contacts):
            var c = Reference(self.contacts[i])
            c[].r1 = c[].position - b1[].position
            c[].r2 = c[].position - b2[].position

            # Relative velocity at contact
            var dv = b2[].velocity + cross(b2[].angular_velocity, c[].r2) - b1[].velocity - cross(b1[].angular_velocity, c[].r1)

            # Compute normal impulse
            var vn: Float32 = dot(dv, c[].normal)
            var dPn: Float32 = c[].mass_normal * (-vn + c[].bias)

            if accumulate_impulses:
                # Clamp the accumulated impulse
                var Pn0: Float32 = c[].Pn
                c[].Pn = max(Pn0 + dPn, 0.0)
                dPn = c[].Pn - Pn0
            else:
                dPn = max(dPn, 0.0)

            # Apply contact impulse
            var Pn: Vec2 = c[].normal * dPn

            b1[].velocity -= Pn * b1[].inv_mass
            b1[].angular_velocity -= b1[].inv_i * cross(c[].r1, Pn)

            b2[].velocity += Pn * b2[].inv_mass
            b2[].angular_velocity += b2[].inv_i * cross(c[].r2, Pn)

            # Relative velocity at contact
            dv = b2[].velocity + cross(b2[].angular_velocity, c[].r2) - b1[].velocity - cross(b1[].angular_velocity, c[].r1)

            var tangent: Vec2 = cross(c[].normal, 1.0)
            var vt: Float32 = dot(dv, tangent)
            var dPt = c[].mass_tangent * (-vt)

            if accumulate_impulses:
                # Compute friction impulse
                var maxPt: Float32 = self.friction * c[].Pn

                # Clamp friction
                var old_tangent_impulse: Float32 = c[].Pt
                c[].Pt = (old_tangent_impulse + dPt).clamp(-maxPt, maxPt)
                dPt = c[].Pt - old_tangent_impulse
            else:
                var maxPt: Float32 = self.friction * dPn
                dPt = dPt.clamp( -maxPt, maxPt)

            # Apply contact impulse
            var Pt: Vec2 = tangent * dPt

            b1[].velocity -= Pt * b1[].inv_mass
            b1[].angular_velocity -= b1[].inv_i * cross(c[].r1, Pt)

            b2[].velocity += Pt * b2[].inv_mass
            b2[].angular_velocity += b2[].inv_i * cross(c[].r2, Pt)


    fn __str__(self) -> String:
        return (
            "\n friction:    " + str(self.friction) +
            "\n numContacts: " + str(self.num_contacts) +
            "\n contact1:\n" + str(self.contacts[0]) +
            "\n contact2:\n" + str(self.contacts[1]) +
            "\n  body1: " + str(UnsafePointer.address_of(self.b1[]))+ "\n" + str(self.b1[]) +
            "\n  body2: " + str(UnsafePointer.address_of(self.b2[]))+ "\n" + str(self.b2[]) 
        )
