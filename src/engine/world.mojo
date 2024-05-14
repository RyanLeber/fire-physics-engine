
from collections import Dict, Set

from src.engine_utils import Vec2
from .arbiter import Arbiter, ArbiterKey
from .body import Body
from .joint import Joint


@value
struct World:
    var gravity: Vec2
    var iterations: Int
    var accumulate_impulses: Bool
    var warm_starting: Bool
    var position_correction: Bool
    var bodies: List[UnsafePointer[Body]]
    var joints: List[UnsafePointer[Joint]]
    var arbiters: Dict[ArbiterKey, Arbiter]

    fn __init__(inout self, gravity: Vec2, iterations: Int):
        self.accumulate_impulses = True
        self.warm_starting = True
        self.position_correction = True

        self.gravity = gravity
        self.iterations = iterations
        self.bodies = List[UnsafePointer[Body]]()
        self.joints = List[UnsafePointer[Joint]]()

        self.arbiters = Dict[ArbiterKey, Arbiter]()

    fn add(inout self, body_ref: UnsafePointer[Body]):
        self.bodies.append(body_ref)

    fn add(inout self, joint_ref: UnsafePointer[Joint]):
        self.joints.append(joint_ref)

    fn clear(inout self):
        self.bodies.clear()
        self.joints.clear()
        self.arbiters = Dict[ArbiterKey, Arbiter]()

    fn broad_phase(inout self) raises:
        # O(n^2) broad-phase
        for i in range(len(self.bodies)):

            var bi = self.bodies[i]

            for j in range(i+1, len(self.bodies)):

                var bj = self.bodies[j]

                if bi[].invMass == 0.0 and bj[].invMass == 0.0:
                    continue

                # if bj[].velocity.y  > 10: # MARK: Velocity Check
                #     print("high velocity!")

                var key = ArbiterKey(int(bi), int(bj))
                var new_arb: Arbiter = Arbiter(bi, bj)

                if new_arb.num_contacts > 0:
                    if key in self.arbiters:
                        self.arbiters[key].update(new_arb.contacts, new_arb.num_contacts, self.warm_starting)

                    else:
                        self.arbiters[key] = new_arb
                        
                else:
                    _ = self.arbiters.pop(key, new_arb)

        # print("len arbiters:",len(self.arbiters))


    fn step(inout self, dt: Float32) raises:
        var inv_dt = 1.0 / dt if dt > 0.0 else 0.0

        # Determine overlapping bodies and update contact points.
        self.broad_phase()

        # Integrate forces.
        for i in range(len(self.bodies)):
            var b = self.bodies[i]

            if b[].invMass == 0.0:
                continue

            b[].velocity += (b[].force * b[].invMass + self.gravity) * dt
            b[].angularVelocity = b[].angularVelocity + (dt * b[].invI * b[].torque)


        var loop_iter = 0
        # Perform pre-steps.
        for arb in self.arbiters.values():

            loop_iter += 1
            if loop_iter == 2: 
                print("\n\n\n\npre-step, x:", arb[].b2[].velocity.x, "y:", arb[].b2[].velocity.y, "           NUM_CONTACTS:", arb[].num_contacts)
                # bomb_vel += str("pre-step, x: " + str(arb[].b2[].velocity.x) + " y: " + arb[].b2[].velocity.y + "\n")

            arb[].pre_step(inv_dt, self.position_correction, self.accumulate_impulses)

        for j in range(len(self.joints)):
            self.joints[j][].pre_step(inv_dt, self.warm_starting, self.position_correction)

        # Perform iterations
        for _ in range(self.iterations):
            var n = 0
            for arb in self.arbiters.values():
                # n += 1
                # if n == 2: 
                #     print("\nAply-imp, x:", arb[].b2[].velocity.x, "y:", arb[].b2[].velocity.y)
                #     for j in range(arb[].num_contacts):
                #         print("contact", j, ":",arb[].contacts[0])

                arb[].apply_impulse(self.accumulate_impulses)

            for j in range(len(self.joints)):
                self.joints[j][].apply_impulse()

        # Integrate Velocities
        for i in range(len(self.bodies)):
            var b = self.bodies[i]

            # if b[].velocity.y  > 10: # MARK: Velocity Check
            #     print("high velocity!")

            b[].position += b[].velocity * dt
            b[].rotation += dt * b[].angularVelocity

            b[].force = Vec2(0,0)
            b[].torque = 0.0               
