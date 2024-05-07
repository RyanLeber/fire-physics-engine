
from src.engine import Body, Joint
from src.engine_utils import Vec2
from src.engine._arbiter import ArbiterKey
from utils import InlineArray
from sys import sizeof



fn main():
    var bodies = InlineArray[Body, 10](Body())
    var joints = InlineArray[Joint, 10](Joint())
    joints[0].set(Reference(bodies[0]), Reference(bodies[1]), Vec2(0.0, 11.0))

    print(UnsafePointer[Body].address_of(bodies[0]), UnsafePointer[Body].address_of(bodies[1]), sep="\n")

    var b1 = Reference(bodies[0])
    var b2 = Reference(bodies[1])
    var j1 = Reference(joints[0])

    b1[].mass = 100

    print(b1[].mass)
    print(j1[].body1[].mass)

    var vec = List[UnsafePointer[Body]]()

    vec.append(b1)

    var arb_key = ArbiterKey(b1, b2) 

    print(UnsafePointer[Body].address_of(b1), UnsafePointer[Body].address_of(b2), sep="\n")

    var v1 = int(UnsafePointer[Body].address_of(b1))
    var v2 = int(UnsafePointer[Body].address_of(b2))

    print("ptrs as ints:", v1, v2)
    print("ptrs added:  ", v1 + v2)


    print("body bytes", sizeof[Body]())

    



