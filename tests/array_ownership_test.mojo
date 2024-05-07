
from utils import InlineArray

from src.engine import Body,Joint
from src.engine_utils import Vec2, i1_1, i1_0



@value
struct World[bodies_lifetime: AnyLifetime[i1_1].type, joints_lifetime: AnyLifetime[i1_1].type]:
    alias _body_ref_type = Reference[Body, i1_1, bodies_lifetime]
    alias _joint_ref_type = Reference[Joint[bodies_lifetime], i1_1, joints_lifetime]
    var bodies: List[Self._body_ref_type]
    var joints: List[Self._joint_ref_type]

    fn __init__(inout self):
        self.bodies = List[Self._body_ref_type]()
        self.joints = List[Self._joint_ref_type]()

    fn add(inout self, body_ref: Self._body_ref_type):
        self.bodies.append(body_ref)

    fn add(inout self, joint_ref: Self._joint_ref_type):
        self.joints.append(joint_ref)


# @value
# struct Engine:
#     var body_array: InlineArray[Body, 200]
#     var world: World[__lifetime_of(Self.body_array)]


#     fn __init__(inout self):
#         self.body_array = InlineArray[Body, 200](Body())


fn main():

    var body_array = InlineArray[Body, 200](Body())
    var joint_array = InlineArray[Joint[__lifetime_of(body_array)], 100](Joint[__lifetime_of(body_array)]())

    var world = World[__lifetime_of(body_array), __lifetime_of(joint_array)]()

    world.add(body_array[0])
    world.bodies[0][].mass = 100

    print(world.bodies[0][].mass)

    print(body_array[0].mass)

