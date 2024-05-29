
from collections import Dict, Set

from src.engine_utils import Vec2
from .arbiterkey import ArbiterKey
from .arbiter import Arbiter
from .body import Body
from .joint import Joint


@value
struct World[gravity: Vec2, iterations: Int, bodies_lifetime: MutableLifetime, joints_lifetime: MutableLifetime]:
    var accumulate_impulses: Bool
    var warm_starting: Bool
    var position_correction: Bool
    var bodies: List[Reference[Body, True, bodies_lifetime]]
    var joints: List[Reference[Joint[bodies_lifetime], True, joints_lifetime]]
    var arbiters: Dict[ArbiterKey, Arbiter[bodies_lifetime]]

    fn __init__(inout self):
        self.accumulate_impulses = True
        self.warm_starting = True
        self.position_correction = True

        self.bodies = List[Reference[Body, True, bodies_lifetime]]()
        self.joints = List[Reference[Joint[bodies_lifetime], True, joints_lifetime]]()

        self.arbiters = Dict[ArbiterKey, Arbiter[bodies_lifetime]]()

    fn add(inout self, body_ref: Reference[Body, True, bodies_lifetime]):
        self.bodies.append(body_ref)

    fn add(inout self, joint_ref: Reference[Joint[bodies_lifetime], True, joints_lifetime]):
        self.joints.append(joint_ref)

    fn clear(inout self):
        self.bodies.clear()
        self.joints.clear()
        self.arbiters = Dict[ArbiterKey, Arbiter[bodies_lifetime]]()

    fn broad_phase(inout self) raises:
        # O(n^2) broad-phase
        for i in range(len(self.bodies)):

            var bi = self.bodies[i]

            for j in range(i+1, len(self.bodies)):

                var bj = self.bodies[j]

                if bi[].inv_mass == 0.0 and bj[].inv_mass == 0.0:
                    continue
                var key = ArbiterKey(int(UnsafePointer.address_of(bi)), int(UnsafePointer.address_of(bj)))
                var new_arb: Arbiter[bodies_lifetime] = Arbiter(bi, bj)

                if new_arb.num_contacts > 0:
                    if key in self.arbiters:
                        self.arbiters[key].update(new_arb.contacts, new_arb.num_contacts, self.warm_starting)

                    else:
                        self.arbiters[key] = new_arb
                else:
                    _ = self.arbiters.pop(key, new_arb)


    fn step(inout self, dt: Float32) raises:
        var inv_dt = 1.0 / dt if dt > 0.0 else 0.0

        # Determine overlapping bodies and update contact points.
        self.broad_phase()

        # Integrate forces.
        for i in range(len(self.bodies)):
            var b = self.bodies[i]

            if b[].inv_mass == 0.0:
                continue

            b[].velocity += (b[].force * b[].inv_mass + self.gravity) * dt
            b[].angular_velocity = b[].angular_velocity + (dt * b[].inv_i * b[].torque)

        # Perform pre-steps.
        for arb in self.arbiters.values():
            arb[].pre_step(inv_dt, self.position_correction, self.accumulate_impulses)

        for j in range(len(self.joints)):
            self.joints[j][].pre_step(inv_dt, self.warm_starting, self.position_correction)

        # Perform iterations
        @parameter
        for _ in range(self.iterations):
            for arb in self.arbiters.values():
                arb[].apply_impulse(self.accumulate_impulses)

            for j in range(len(self.joints)):
                self.joints[j][].apply_impulse()

        # Integrate Velocities
        for i in range(len(self.bodies)):
            var b = self.bodies[i]
            b[].position += b[].velocity * dt
            b[].rotation += dt * b[].angular_velocity

            b[].force = Vec2(0,0)
            b[].torque = 0.0               
