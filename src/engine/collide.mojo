
from utils import InlineArray

from .arbiter import FeaturePair, Contact
from .body import Body
from src.engine_utils import (
        Vec2,
        Mat22,
        dot,
        mat_mul,
        sign
    )


# Box vertex and edge numbering:
#        ^ y
#        |
#        e1
#   v2 ------ v1
#    |        |
# e2 |        | e4  --> x
#    |        |
#   v3 ------ v4
#        e3


# Enum
struct Axis:
    alias FACE_A_X: UInt8 = 0
    alias FACE_A_Y: UInt8 = 1
    alias FACE_B_X: UInt8 = 2
    alias FACE_B_Y: UInt8 = 3

# Enum
struct EdgeNumbers:
    alias NO_EDGE: UInt8 = 0
    alias EDGE1: UInt8 = 1
    alias EDGE2: UInt8 = 2
    alias EDGE3: UInt8 = 3
    alias EDGE4: UInt8 = 4


@value
struct ClipVertex(CollectionElementNew):
    var v: Vec2
    var fp: FeaturePair

    fn __init__(inout self):
        self.v = Vec2(0, 0)  # Assuming Vec2 has a default constructor
        self.fp = FeaturePair()  # Assuming FeaturePair takes an integer in its constructor

    fn __init__(inout self, *, copy: Self):
        self.v = copy.v
        self.fp = copy.fp


fn flip(inout fp: FeaturePair):
    swap(fp[].in_edge1, fp[].in_edge2)
    swap(fp[].out_edge1, fp[].out_edge2)


fn clip_segment_to_line(
        inout v_out: InlineArray[ClipVertex, 2], 
        inout v_in: InlineArray[ClipVertex, 2], 
        normal: Vec2, 
        offset: Float32, 
        clip_edge: UInt8
    ) -> Int:

    var num_out: Int = 0
    var distance_0: Float32 = dot(normal, v_in[0].v) - offset
    var distance_1: Float32 = dot(normal, v_in[1].v) - offset

    if distance_0 <= 0.0:
        v_out[num_out] = v_in[0]
        num_out += 1

    if distance_1 <= 0.0: 
        v_out[num_out] = v_in[1]
        num_out += 1

    if distance_0 * distance_1 < 0.0:
        var interp: Float32 = distance_0 / (distance_0 - distance_1)

        v_out[num_out].v = v_in[0].v + (v_in[1].v - v_in[0].v) * interp
        if distance_0 > 0.0:
            v_out[num_out].fp = v_in[0].fp
            v_out[num_out].fp[].in_edge1 = clip_edge
            v_out[num_out].fp[].in_edge2 = EdgeNumbers.NO_EDGE

        else:
            v_out[num_out].fp = v_in[1].fp
            v_out[num_out].fp[].out_edge1 = clip_edge
            v_out[num_out].fp[].out_edge2 = EdgeNumbers.NO_EDGE
        num_out += 1

    return num_out


fn compute_incident_edge(inout c: InlineArray[ClipVertex, 2],h: Vec2, pos: Vec2, rot: Mat22, normal: Vec2):
    # The normal is from the reference box. Convert it
    # to the incident box's frame and flip sign.
    var rotT: Mat22 = rot.transpose()
    var n: Vec2 = -(rotT * normal)
    var nAbs: Vec2 = abs(n)

    if nAbs.x > nAbs.y:
        if sign(n.x) > 0.0:
            c[0].v = Vec2(h.x, -h.y)
            c[0].fp[].in_edge2 = EdgeNumbers.EDGE3
            c[0].fp[].out_edge2 = EdgeNumbers.EDGE4

            c[1].v = Vec2(h.x, h.y)
            c[1].fp[].in_edge2 = EdgeNumbers.EDGE4
            c[1].fp[].out_edge2 = EdgeNumbers.EDGE1
        else:
            c[0].v = Vec2(-h.x, h.y)
            c[0].fp[].in_edge2 = EdgeNumbers.EDGE1
            c[0].fp[].out_edge2 = EdgeNumbers.EDGE2

            c[1].v = Vec2(-h.x, -h.y)
            c[1].fp[].in_edge2 = EdgeNumbers.EDGE2
            c[1].fp[].out_edge2 = EdgeNumbers.EDGE3
    else:
        if sign(n.y) > 0.0:
            c[0].v = Vec2(h.x, h.y)
            c[0].fp[].in_edge2 = EdgeNumbers.EDGE4
            c[0].fp[].out_edge2 = EdgeNumbers.EDGE1

            c[1].v = Vec2(-h.x, h.y)
            c[1].fp[].in_edge2 = EdgeNumbers.EDGE1
            c[1].fp[].out_edge2 = EdgeNumbers.EDGE2
        else:
            c[0].v = Vec2(-h.x, -h.y)
            c[0].fp[].in_edge2 = EdgeNumbers.EDGE2
            c[0].fp[].out_edge2 = EdgeNumbers.EDGE3

            c[1].v = Vec2(h.x, -h.y)
            c[1].fp[].in_edge2 = EdgeNumbers.EDGE3
            c[1].fp[].out_edge2 = EdgeNumbers.EDGE4

    c[0].v = pos + rot * c[0].v 
    c[1].v = pos + rot * c[1].v


fn collide(
        inout contacts: InlineArray[Contact, 2],
        body_a: Reference[Body],
        body_b: Reference[Body]
    ) -> Int:

    # Setup
    var h_a: Vec2 = body_a[].width * 0.5
    var h_b: Vec2 = body_b[].width * 0.5

    var pos_a: Vec2 = body_a[].position
    var pos_b: Vec2 = body_b[].position

    var rot_a: Mat22 = Mat22(body_a[].rotation)
    var rot_b: Mat22 = Mat22(body_b[].rotation)

    var rot_a_t: Mat22 = rot_a.transpose()
    var rot_b_t: Mat22 = rot_b.transpose()

    var d_p: Vec2 = pos_b - pos_a
    var d_a: Vec2 = rot_a_t * d_p
    var d_b: Vec2 = rot_b_t * d_p

    var C: Mat22 = mat_mul(rot_a_t, rot_b)
    var abs_C: Mat22 = abs(C)
    var abs_C_t: Mat22 = abs_C.transpose()

    # Box A faces
    var face_a = abs(d_a) - h_a - abs_C * h_b
    if face_a.x > 0.0 or face_a.y > 0.0:
        return 0

    # Box B faces
    var face_b = abs(d_b) - abs_C_t * h_a - h_b
    if face_b.x > 0.0 or face_b.y > 0.0:
        return 0

    # Find best axis
    var axis = Axis.FACE_A_X
    var separation = face_a.x
    var normal = rot_a.col1 if d_a.x > 0.0 else -rot_a.col1

    alias relative_to_l: Float32 = 0.95
    alias absolute_to_l: Float32 = 0.01

    if face_a.y > relative_to_l * separation + absolute_to_l * h_a.y:
        axis = Axis.FACE_A_Y
        separation = face_a.y
        normal = rot_a.col2 if d_a.y > 0.0 else -rot_a.col2

    if face_b.x > relative_to_l * separation + absolute_to_l * h_b.x:
        axis = Axis.FACE_B_X
        separation = face_b.x
        normal = rot_b.col1 if d_b.x > 0.0 else -rot_b.col1

    if face_b.y > relative_to_l * separation + absolute_to_l * h_b.y:
        axis = Axis.FACE_B_Y
        separation = face_b.y
        normal = rot_b.col2 if d_b.y > 0.0 else -rot_b.col2

    var front_normal: Vec2
    var side_normal: Vec2
    var incident_edge = InlineArray[ClipVertex, 2](ClipVertex())
    var front: Float32
    var neg_side: Float32
    var pos_side: Float32
    var neg_edge: UInt8
    var pos_edge: UInt8

    # Compute the clipping lines and the line segment to be clipped.
    if axis == Axis.FACE_A_X:
        front_normal = normal
        front = dot(pos_a, front_normal) + h_a.x
        side_normal = rot_a.col2
        var side: Float32 = dot(pos_a, side_normal)
        neg_side = -side + h_a.y
        pos_side = side + h_a.y
        neg_edge = EdgeNumbers.EDGE3
        pos_edge = EdgeNumbers.EDGE1
        compute_incident_edge(incident_edge, h_b, pos_b, rot_b, front_normal)
    
    elif axis == Axis.FACE_A_Y:
        front_normal = normal
        front = dot(pos_a, front_normal) + h_a.y
        side_normal = rot_a.col1
        var side: Float32 = dot(pos_a, side_normal)
        neg_side = -side + h_a.x
        pos_side = side + h_a.x
        neg_edge = EdgeNumbers.EDGE2
        pos_edge = EdgeNumbers.EDGE4
        compute_incident_edge(incident_edge, h_b, pos_b, rot_b, front_normal)

    elif axis == Axis.FACE_B_X:
        front_normal = -normal
        front = dot(pos_b, front_normal) + h_b.x
        side_normal = rot_b.col2
        var side: Float32 = dot(pos_b, side_normal)
        neg_side = -side + h_b.y
        pos_side = side + h_b.y
        neg_edge = EdgeNumbers.EDGE3
        pos_edge = EdgeNumbers.EDGE1
        compute_incident_edge(incident_edge, h_a, pos_a, rot_a, front_normal)

    # elif axis == Axis.FACE_B_Y:
    else:
        front_normal = -normal
        front = dot(pos_b, front_normal) + h_b.y
        side_normal = rot_b.col1
        var side: Float32 = dot(pos_b, side_normal)
        neg_side = -side + h_b.x
        pos_side = side + h_b.x
        neg_edge = EdgeNumbers.EDGE2
        pos_edge = EdgeNumbers.EDGE4
        compute_incident_edge(incident_edge, h_a, pos_a, rot_a, front_normal)

    # clip other face with 5 box planes (1 face plane, 4 edge planes)
    var clip_points1 = InlineArray[ClipVertex, 2](ClipVertex())
    var clip_points2 = InlineArray[ClipVertex, 2](ClipVertex())
    var num_points: Int

    # Clip to box side 1
    num_points = clip_segment_to_line(clip_points1, incident_edge, -side_normal, neg_side, neg_edge)

    if num_points < 2:
        return 0

    # Clip to negative box side 1
    num_points = clip_segment_to_line(clip_points2, clip_points1, side_normal, pos_side, pos_edge)

    if num_points < 2:
        return 0

	# Now clipPoints2 contains the clipping points.
	# Due to roundoff, it is possible that clipping removes all points.
    var num_contacts = 0
    @parameter
    for i in range(2):
        var separation: Float32 = dot(front_normal, clip_points2[i].v) - front

        if separation <= 0:
            contacts[num_contacts].separation = separation
            contacts[num_contacts].normal = normal
            # slide contact point onto reference face (easy to cull)
            contacts[num_contacts].position = clip_points2[i].v - front_normal * separation
            contacts[num_contacts].feature = clip_points2[i].fp
            if axis == Axis.FACE_B_X or axis == Axis.FACE_B_Y:
                flip(contacts[num_contacts].feature)
            num_contacts += 1

    return num_contacts