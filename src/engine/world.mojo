
from collections.dict import Dict

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

        self.arbiters = Dict[ArbiterKey, Arbiter]() # Using a dictionary for the map
        print("trigger __init__ World")

    fn add(inout self, body_ref: UnsafePointer[Body]):
        print("trigger add")
        self.bodies.append(body_ref)
        print("added")

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

                var new_arb = Arbiter(bi, bj)
                var key = ArbiterKey(bi, bj)
                
                if new_arb.num_contacts > 0:
                    self.arbiters[key] = new_arb
                        
                elif key in self.arbiters:
                    print("popping")
                    _ = self.arbiters.pop(key)


    fn step(inout self, dt: Float32) raises:
        var inv_dt = 1.0 / dt if dt > 0.0 else 0.0

        # Determine overlapping bodies and update contact points.
        self.broad_phase()

        if len(self.arbiters) > 2:
            # breakpoint()
            print("len arbiters:", len(self.arbiters))

        # Integrate forces.
        for i in range(len(self.bodies)):

            var b = self.bodies[i]

            if b[].invMass == 0.0:
                continue

            b[].velocity += (b[].force * b[].invMass + self.gravity) * dt
            b[].angularVelocity = b[].angularVelocity + (dt * b[].invI * b[].torque)

        # Perform pre-steps.
        for arb in self.arbiters.values():
            arb[].pre_step(inv_dt, self.position_correction, self.accumulate_impulses)

        for j in range(len(self.joints)):
            self.joints[j][].pre_step(inv_dt, self.warm_starting, self.position_correction)

        # Perform iterations
        for _ in range(self.iterations):
            for arb in self.arbiters.values():
                arb[].apply_impulse(self.accumulate_impulses)

            for j in range(len(self.joints)):
                self.joints[j][].apply_impulse()

        # Integrate Velocities
        for b in self.bodies:
            b[][].position += b[][].velocity * dt
            b[][].rotation += dt * b[][].angularVelocity

            b[][].force = Vec2(0,0)
            b[][].torque = 0.0

        # Integrate Velocities
        for i in range(len(self.bodies)):
            self.bodies[i][].position += self.bodies[i][].velocity * dt
            self.bodies[i][].rotation += dt * self.bodies[i][].angularVelocity

            self.bodies[i][].force = Vec2(0,0)
            self.bodies[i][].torque = 0.0