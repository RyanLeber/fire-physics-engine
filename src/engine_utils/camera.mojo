
from sdl.keyboard import Keyboard, KeyCode

alias background_clear = Color(12, 8, 6, 0)

@value
struct Camera:
    var transform: g2.Multivector
    var pivot: g2.Vector
    var target: Texture
    var frame_count: Int
    var viewport: DRect[DType.float32]
    var is_main_camera: Bool

    fn __init__(
        inout self, renderer: Renderer, transform: g2.Multivector[], pivot: g2.Vector[], viewport: DRect) raises:
        self.transform = transform
        self.pivot = pivot
        var size = renderer.get_output_size()
        self.target = Texture(renderer, sdl.TexturePixelFormat.RGBA8888, sdl.TextureAccess.TARGET, int(size[0] * viewport.w), int(size[1] * viewport.h))
        self.frame_count = 0
        self.viewport = viewport.cast[DType.float32]()
        self.is_main_camera = False

    fn __eq__(self, other: Self) -> Bool:
        return Reference(self) == Reference(other)

    fn __ne__(self, other: Self) -> Bool:
        return Reference(self) != Reference(other)

    fn cam2field(self, pos: g2.Vector[]) -> g2.Vector[]:
        return ((pos - self.pivot) * self.transform.rotor()) + (self.transform.v - self.pivot)

    fn field2cam(self, pos: g2.Vector[]) -> g2.Vector[]:
        return ((pos - (self.transform.v - self.pivot)) / self.transform.rotor()) + self.pivot


    # +------( Update )------+ #
    #
    fn update(inout self, delta_time: Float64, keyboard: Keyboard):

        if not self.is_main_camera:
            return

        # rotation
        var angle = 0
        alias rot_speed = 0.5

        if keyboard.state[KeyCode.Q]:
            angle -= 1
        if keyboard.state[KeyCode.E]:
            angle += 1

        # zoom
        var zoom = 0

        if keyboard.state[KeyCode.LSHIFT]:
            zoom -= 1
        if keyboard.state[KeyCode.SPACE]:
            zoom += 1

        var rot = g2.Rotor(
            angle=angle * delta_time * rot_speed
        ) * (1 + (zoom * delta_time))

        # position
        var mov = g2.Vector()
        alias mov_speed = 1000

        if keyboard.state[KeyCode.A]:
            mov.x -= 1
        if keyboard.state[KeyCode.D]:
            mov.x += 1
        if keyboard.state[KeyCode.W]:
            mov.y -= 1
        if keyboard.state[KeyCode.S]:
            mov.y += 1

        if not mov.is_zero():
            mov = (mov / mov.nom()) * self.transform.rotor() * delta_time * mov_speed

        self.transform = self.transform.trans(mov + rot)

    # +------( Draw )------+ #
    #
    fn draw(self, world: World, renderer: Renderer, screen_dimensions: Vec2) raises:
        renderer.set_target(self.target)
        renderer.set_color(background_clear)
        renderer.clear()

        var body_color = Color(204, 204, 229)
        var joint_color = Color(102, 229, 102)

        for body in world.bodies:
            body[][].draw(self, renderer, body_color, screen_dimensions)

        for joint in world.joints:
            joint[][].draw(self, renderer, joint_color, screen_dimensions)


        # var point_color = Color(255, 0, 0)
        # # draw contact points
        # for item in world.arbiters.items():
        #     for i in range(item[].value.num_contacts):
        #         var pos = item[].value.contacts[i].position.world_to_screen(screen_dimensions)

        #         renderer.set_color(point_color)
        #         renderer.draw_point(pos.x, pos.y)


        renderer.reset_target()
        var size = renderer.get_output_size()
        renderer.set_viewport(DRect[DType.int32](self.viewport.x * size[0], self.viewport.y * size[1], self.viewport.w * size[0], self.viewport.h * size[1]))
        renderer.copy(self.target, None)

    fn draw(self, world: World, renderer: Renderer) raises:
        renderer.set_target(self.target)
        renderer.set_color(background_clear)
        renderer.clear()

        var body_color = Color(204, 204, 229)
        var joint_color = Color(102, 229, 102)

        for body in world.bodies:
            body[][].draw(self, renderer, body_color)

        for joint in world.joints:
            joint[][].draw(self, renderer, joint_color)


        renderer.reset_target()
        var size = renderer.get_output_size()
        renderer.set_viewport(DRect[DType.int32](self.viewport.x * size[0], self.viewport.y * size[1], self.viewport.w * size[0], self.viewport.h * size[1]))
        renderer.copy(self.target, None)
