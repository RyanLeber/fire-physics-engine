
from sys.ffi import DLHandle, external_call


struct DrawModes:
    """Primitive assembly draw modes.

    ```
    RL_LINES     = 0x0001 #GL_LINES
    RL_TRIANGLES = 0x0004 #GL_TRIANGLES
    RL_QUADS     = 0x0007 #GL_QUADS
    ```
    GL_LINES:
        Treats each pair of vertices as an independent
        line segment. Vertices 2n - 1 and 2n define 
        line n. N/2 lines are drawn.

    GL_TRIANGLES:
        Treats each triplet of vertices as an independent
        triangle. Vertices 3n - 2, 3n - 1, and 3n define
        triangle n. N/3 triangles are drawn.

    GL_QUADS:
        Treats each group of four vertices as an independent
        quadrilateral. Vertices 4n - 3, 4n - 2, 4n - 1, and
        4n define quadrilateral n. N/4 quadrilaterals are drawn.
    """
    alias RL_LINES = 0x0001
    alias RL_TRIANGLES = 0x0004
    alias RL_QUADS = 0x0007


# MARK: Keyboard
struct Keyboard:
    alias KEY_NULL            = 0        # Key: NULL, used for no key pressed
    # Alphanumeric keys
    alias KEY_APOSTROPHE      = 39       # Key: '
    alias KEY_COMMA           = 44       # Key: ,
    alias KEY_MINUS           = 45       # Key: -
    alias KEY_PERIOD          = 46       # Key: .
    alias KEY_SLASH           = 47       # Key: /
    alias KEY_ZERO            = 48       # Key: 0
    alias KEY_ONE             = 49       # Key: 1
    alias KEY_TWO             = 50       # Key: 2
    alias KEY_THREE           = 51       # Key: 3
    alias KEY_FOUR            = 52       # Key: 4
    alias KEY_FIVE            = 53       # Key: 5
    alias KEY_SIX             = 54       # Key: 6
    alias KEY_SEVEN           = 55       # Key: 7
    alias KEY_EIGHT           = 56       # Key: 8
    alias KEY_NINE            = 57       # Key: 9
    alias KEY_SEMICOLON       = 59       # Key: ;
    alias KEY_EQUAL           = 61       # Key: =
    alias KEY_A               = 65       # Key: A | a
    alias KEY_B               = 66       # Key: B | b
    alias KEY_C               = 67       # Key: C | c
    alias KEY_D               = 68       # Key: D | d
    alias KEY_E               = 69       # Key: E | e
    alias KEY_F               = 70       # Key: F | f
    alias KEY_G               = 71       # Key: G | g
    alias KEY_H               = 72       # Key: H | h
    alias KEY_I               = 73       # Key: I | i
    alias KEY_J               = 74       # Key: J | j
    alias KEY_K               = 75       # Key: K | k
    alias KEY_L               = 76       # Key: L | l
    alias KEY_M               = 77       # Key: M | m
    alias KEY_N               = 78       # Key: N | n
    alias KEY_O               = 79       # Key: O | o
    alias KEY_P               = 80       # Key: P | p
    alias KEY_Q               = 81       # Key: Q | q
    alias KEY_R               = 82       # Key: R | r
    alias KEY_S               = 83       # Key: S | s
    alias KEY_T               = 84       # Key: T | t
    alias KEY_U               = 85       # Key: U | u
    alias KEY_V               = 86       # Key: V | v
    alias KEY_W               = 87       # Key: W | w
    alias KEY_X               = 88       # Key: X | x
    alias KEY_Y               = 89       # Key: Y | y
    alias KEY_Z               = 90       # Key: Z | z
    alias KEY_LEFT_BRACKET    = 91       # Key: [
    alias KEY_BACKSLASH       = 92       # Key: '\'
    alias KEY_RIGHT_BRACKET   = 93       # Key: ]
    alias KEY_GRAVE           = 96       # Key: `
    # Function keys
    alias KEY_SPACE           = 32       # Key: Space
    alias KEY_ESCAPE          = 256      # Key: Esc
    alias KEY_ENTER           = 257      # Key: Enter
    alias KEY_TAB             = 258      # Key: Tab
    alias KEY_BACKSPACE       = 259      # Key: Backspace
    alias KEY_INSERT          = 260      # Key: Ins
    alias KEY_DELETE          = 261      # Key: Del
    alias KEY_RIGHT           = 262      # Key: Cursor right
    alias KEY_LEFT            = 263      # Key: Cursor left
    alias KEY_DOWN            = 264      # Key: Cursor down
    alias KEY_UP              = 265      # Key: Cursor up
    alias KEY_PAGE_UP         = 266      # Key: Page up
    alias KEY_PAGE_DOWN       = 267      # Key: Page down
    alias KEY_HOME            = 268      # Key: Home
    alias KEY_END             = 269      # Key: End
    alias KEY_CAPS_LOCK       = 280      # Key: Caps lock
    alias KEY_SCROLL_LOCK     = 281      # Key: Scroll down
    alias KEY_NUM_LOCK        = 282      # Key: Num lock
    alias KEY_PRINT_SCREEN    = 283      # Key: Print screen
    alias KEY_PAUSE           = 284      # Key: Pause
    alias KEY_F1              = 290      # Key: F1
    alias KEY_F2              = 291      # Key: F2
    alias KEY_F3              = 292      # Key: F3
    alias KEY_F4              = 293      # Key: F4
    alias KEY_F5              = 294      # Key: F5
    alias KEY_F6              = 295      # Key: F6
    alias KEY_F7              = 296      # Key: F7
    alias KEY_F8              = 297      # Key: F8
    alias KEY_F9              = 298      # Key: F9
    alias KEY_F10             = 299      # Key: F10
    alias KEY_F11             = 300      # Key: F11
    alias KEY_F12             = 301      # Key: F12
    alias KEY_LEFT_SHIFT      = 340      # Key: Shift left
    alias KEY_LEFT_CONTROL    = 341      # Key: Control left
    alias KEY_LEFT_ALT        = 342      # Key: Alt left
    alias KEY_LEFT_SUPER      = 343      # Key: Super left
    alias KEY_RIGHT_SHIFT     = 344      # Key: Shift right
    alias KEY_RIGHT_CONTROL   = 345      # Key: Control right
    alias KEY_RIGHT_ALT       = 346      # Key: Alt right
    alias KEY_RIGHT_SUPER     = 347      # Key: Super right
    alias KEY_KB_MENU         = 348      # Key: KB menu
    # Keypad keys
    alias KEY_KP_0            = 320      # Key: Keypad 0
    alias KEY_KP_1            = 321      # Key: Keypad 1
    alias KEY_KP_2            = 322      # Key: Keypad 2
    alias KEY_KP_3            = 323      # Key: Keypad 3
    alias KEY_KP_4            = 324      # Key: Keypad 4
    alias KEY_KP_5            = 325      # Key: Keypad 5
    alias KEY_KP_6            = 326      # Key: Keypad 6
    alias KEY_KP_7            = 327      # Key: Keypad 7
    alias KEY_KP_8            = 328      # Key: Keypad 8
    alias KEY_KP_9            = 329      # Key: Keypad 9
    alias KEY_KP_DECIMAL      = 330      # Key: Keypad .
    alias KEY_KP_DIVIDE       = 331      # Key: Keypad /
    alias KEY_KP_MULTIPLY     = 332      # Key: Keypad *
    alias KEY_KP_SUBTRACT     = 333      # Key: Keypad -
    alias KEY_KP_ADD          = 334      # Key: Keypad +
    alias KEY_KP_ENTER        = 335      # Key: Keypad Enter
    alias KEY_KP_EQUAL        = 336      # Key: Keypad =
    # Android key buttons
    alias KEY_BACK            = 4        # Key: Android back button
    alias KEY_MENU            = 5        # Key: Android menu button
    alias KEY_VOLUME_UP       = 24       # Key: Android volume up button
    alias KEY_VOLUME_DOWN     = 25        # Key: Android volume down button


# MARK: BuiltinColors
struct BuiltinColors:
    """A list of pre-defined colors.

    Colors:
    ```
    WHITE: rgba( 245, 245, 245, 255 )
    BLACK: rgba( 0, 0, 0, 255 )
    RED: rgba( 230, 41, 55, 255 )
    MAROON: rgba( 190, 33, 55, 255 )
    DARKGRAY: rgba( 80, 80, 80, 255 )
    ```
    """
    alias WHITE: Color = Color( 245, 245, 245, 255 )
    alias BLACK: Color = Color( 0, 0, 0, 255 )
    alias RED: Color = Color( 230, 41, 55, 255 )
    alias MAROON: Color = Color( 190, 33, 55, 255 )
    alias DARKGRAY: Color = Color( 80, 80, 80, 255 )


# MARK: CameraMode
struct CameraMode: 
    """An enum containing Camera Modes.

    ```
    CAMERA_CUSTOM        = 0
    CAMERA_FREE          = 1
    CAMERA_ORBITAL       = 2
    CAMERA_FIRST_PERSON  = 3
    CAMERA_THIRD_PERSON  = 4
    ```
    """
    alias CAMERA_CUSTOM: Int32 = 0
    alias CAMERA_FREE: Int32 = 1
    alias CAMERA_ORBITAL: Int32 = 2
    alias CAMERA_FIRST_PERSON: Int32 = 3
    alias CAMERA_THIRD_PERSON: Int32 = 4


# MARK: CameraProjection
struct CameraProjection:
    """An Enum containing Camera Projection options.

    ```
    CAMERA_PERSPECTIVE  = 0
    CAMERA_ORTHOGRAPHIC = 1
    ```
    """
    alias CAMERA_PERSPECTIVE: Int32 = 0
    alias CAMERA_ORTHOGRAPHIC: Int32 = 1


# MARK: Vector2
@register_passable("trivial")
struct Vector2:
    """An object to define a Vector2 in 2D space.

    Attributes:
    ```
    x: Float32
    y: Float32
    ```
    """
    var x: Float32
    var y: Float32

    fn __init__(inout self):
        self.x = 0.0
        self.y = 0.0

    fn __init__(inout self, x: Float32, y: Float32):
        self.x = x
        self.y = y

    fn __init__(inout self, value: Float32):
        self.x = value
        self.y = value


# MARK: Vector3
@register_passable("trivial")
struct Vector3:
    """An object to define a Vector3 in 3D space.

    Attributes:
    ```
    x: Float32
    y: Float32
    z: Float32
    ```
    """
    var x: Float32
    var y: Float32
    var z: Float32
    
    fn __init__(inout self):
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0

    fn __init__(inout self, x: Float32, y: Float32, z: Float32):
        self.x = x
        self.y = y
        self.z = z

    fn __init__(inout self, val: Float32):
        self.x = val
        self.y = val
        self.z = val


# MARK: Rectangle
@register_passable("trivial")
struct Rectangle(CollectionElement):
    """A Rectangle object to define a rectangle in 2D scenes.

    Attributes:
    ```
    x: Float32
    y: Float32
    width: Float32
    height: Float32
    ```
    """
    var data: SIMD[DType.float32, 4]

    @always_inline
    fn __init__(inout self):
        self.data = SIMD[DType.float32, 4](0)

    @always_inline
    fn __init__(inout self, x: Float32, y: Float32, width: Float32, height: Float32):
        self.data = SIMD[DType.float32, 4](x, y, width, height)

    @always_inline
    fn __init__(inout self, position: Vec2, size: Vec2):
        self.data = SIMD[DType.float32, 4](position[0], position[1], size[0], size[1])

    @always_inline
    fn __init__(inout self, data: SIMD[DType.float32, 4]):
        self.data = data

    @always_inline
    fn __getitem__(self, idx: Int) -> Float32:
        return self.data[idx]

    @always_inline
    fn __setitem__(inout self, idx: Int, value: Float32):
        self.data[idx] = value

    @always_inline
    fn __getattr__[name: StringLiteral](self) -> Float32:
        constrained[name == "x" or name == "y" or name == "width" or name == "height", "can only access with x, y, width, or height members"]()
        if name == "x":
            return self.data[0]
        elif name == "y":
            return self.data[1]
        elif name == "width":
            return self.data[2]
        else:
            return self.data[3]

    @always_inline
    fn __setattr__[name: StringLiteral](inout self, val: Float32):
        constrained[name == "x" or name == "y" or name == "width" or name == "height", "can only access with x, y, width, or height members"]()
        if name == "x":
            self.data[0] = val
        elif name == "y":
            self.data[1] = val
        elif name == "width":
            self.data[2] = val
        else:
            self.data[3] = val


# MARK: Camera3D
# @register_passable("trivial")
@value
struct Camera3D:
    """A camera object to define a camera in 3D scenes.

    Attributes:
    ```
    position: Vector3
    target: Vector3
    up: Vector3
    fovy: Float32
    projection: Int32
    ```
    """
    var position: Vector3
    var target: Vector3
    var up: Vector3
    var fovy: Float32
    var projection: Int32

    fn __init__(inout self):
        self.position = Vector3(0)
        self.target = Vector3(0)
        self.up = Vector3(0)
        self.fovy = 0
        self.projection = 0

    fn __init__(inout self, val: Float32):
        self.position = Vector3(val)
        self.target = Vector3(val)
        self.up = Vector3(val)
        self.fovy = val
        self.projection = int(val)


# MARK: Camera2D
# @register_passable("trivial")
@value
struct Camera2D:
    """A camera object to define a camera in 2D scenes.

    Attributes:
    ```
    offset: Vector2     # Camera offset (displacement from target)
    target: Vector2     # Camera target (rotation and zoom origin)
    rotation: Float32   # Camera rotation in degrees
    zoom: Float32       # Camera zoom (scaling), should be 1.0f by default
    ```
    """
    var offset: Vec2
    var target: Vec2
    var rotation: Float32
    var zoom: Float32

    fn __init__(inout self):
        self.offset = Vec2(0)
        self.target = Vec2(0)
        self.rotation = 0
        self.zoom = 0

    fn __init__(inout self, val: Float32):
        self.offset = Vec2(val)
        self.target = Vec2(val)
        self.rotation = val
        self.zoom = val


# @register_passable("trivial")
# struct Color:
#     var r: UInt8
#     var g: UInt8
#     var b: UInt8
#     var a: UInt8

#     fn __init__(inout self, r: UInt8, g: UInt8, b: UInt8, a: UInt8):
#             self.r = r
#             self.g = g
#             self.b = b
#             self.a = a


# MARK: Color
@register_passable("trivial")
struct Color(CollectionElement):
    """Color, 4 components, R8G8B8A8 (32bit)."""
    var data: SIMD[DType.uint8, 4]

    @always_inline
    fn __init__(inout self):
        self.data = SIMD[DType.uint8, 4](0)

    @always_inline
    fn __init__(inout self, r: UInt8, g: UInt8, b: UInt8, a: UInt8):
        """Constructs a Color from r, g, b, and a values."""
        self.data = SIMD[DType.uint8, 4](r, g, b, a)

    @always_inline
    fn __init__(inout self, data: SIMD[DType.uint8, 4]):
        self.data = data

    @always_inline
    fn __getitem__(self, idx: Int) -> UInt8:
        return self.data[idx]

    @always_inline
    fn __setitem__(inout self, idx: Int, value: UInt8):
        self.data[idx] = value

    @always_inline
    fn __getattr__[name: StringLiteral](self) -> UInt8:
        constrained[name == "r" or name == "g" or name == "b" or name == "a", "can only access with r, g, b, or a members"]()
        if name == "r":
            return self.data[0]
        elif name == "g":
            return self.data[1]
        elif name == "b":
            return self.data[2]
        else:
            return self.data[3]

    @always_inline
    fn __setattr__[name: StringLiteral](inout self, val: UInt8):
        constrained[name == "r" or name == "g" or name == "b" or name == "a", "can only access with r, g, b, or a members"]()
        if name == "r":
            self.data[0] = val
        elif name == "g":
            self.data[1] = val
        elif name == "b":
            self.data[2] = val
        else:
            self.data[3] = val


# MARK: Texture2D
@register_passable('trivial')
struct Texture2D:
    """Represents a texture object to define a 2D texture.

    Attributes:
    ```
    id: UInt8        # OpenGL texture id.
    width: Int32     # Texture base width.
    height: Int32    # Texture base height.
    mipmaps: Int32   # Mipmap levels, 1 by default.
    format: Int32    # Data format (PixelFormat type).
    ```
    """
    var id: UInt32
    var width: Int
    var height: Int
    var mipmaps: Int
    var format: Int


#%%%%%%%%%%%%%%%%%%%%%%%%
# MARK: Raylib Internal Bindings
#%%%%%%%%%%%%%%%%%%%%%%%%
# Core
alias c_raylib_InitWindow = fn(width: Int32, height: Int32, title: StringLiteral) -> None
""" Test"""
alias c_raylib_UpdateCamera3D = fn(camera: UnsafePointer[Camera3D], mode: Int32) -> None
alias c_raylib_UpdateCamera2D = fn(camera: UnsafePointer[Camera2D], mode: Int32) -> None
alias c_raylib_WindowShouldClose = fn() -> Int32
alias c_raylib_CloseWindow = fn() -> None

alias c_raylib_SetTargetFPS = fn(fps: Int32) -> None
alias c_raylib_GetFrameTime = fn() -> Float32
alias c_raylib_GetTime = fn() -> Float64
alias c_raylib_GetFPS = fn() -> Int32

alias c_raylib_BeginDrawing = fn() -> None
alias c_raylib_EndDrawing = fn() -> None
alias c_raylib_EndMode3D = fn() -> None
alias c_raylib_EndMode2D = fn() -> None

alias c_raylib_DrawGrid = fn(slices: Int32, spacing: Float32) -> None
alias c_raylib_DrawFPS = fn(pos_x: Int32, pos_y: Int32) -> None

# Input Functions: Keyboard
alias c_raylib_IsKeyPressed = fn(key: Int32) -> Bool
alias c_raylib_IsKeyPressedRepeat = fn(key: Int) -> Bool
alias c_raylib_IsKeyDown = fn(key: Int32) -> Bool
alias c_raylib_IsKeyReleased = fn(key: Int32) -> Bool
alias c_raylib_IsKeyUp = fn(key: Int32) -> Bool

alias c_raylib_GetKeyPressed = fn() -> Int32
alias c_raylib_GetCharPressed = fn() -> Int32

alias c_raylib_SetExitKey = fn(key: Int32) -> None

# Input Functions: Mouse
alias c_raylib_IsMouseButtonPressed = fn(button: Int32) -> Bool
alias c_raylib_IsMouseButtonDown = fn(button: Int32) -> Bool
alias c_raylib_IsMouseButtonReleased = fn(button: Int32) -> Bool
alias c_raylib_IsMouseButtonUp = fn(button: Int32) -> Bool

alias c_raylib_GetMouseX = fn() -> Int32
alias c_raylib_GetMouseY = fn() -> Int32
alias c_raylib_GetMouseDelta = fn() -> Vec2

alias c_raylib_SetMousePosition = fn(x: Int32, y: Int32) -> None
alias c_raylib_SetMouseOffset = fn(offset_x: Int32, offset_y: Int32) -> None
alias c_raylib_SetMouseScale = fn(scale_x: Float32, scale_y: Float32) -> None

alias c_raylib_GetMouseWheelMove = fn() -> Float32
alias c_raylib_GetMouseWheelMoveV = fn() -> Vec2

alias c_raylib_SetMouseCursor = fn(cursor: Int32) -> None

# Module: text
alias c_raylib_DrawText = fn(StringLiteral, Int32, Int32, Int32, Color) -> None


# Module: rlglfw, low level rendering functions
alias c_raylib_glBegin = fn(mode: Int32) -> NoneType
alias c_raylib_rlBegin = fn(mode: Int32) -> NoneType
alias c_raylib_rlEnd = fn() -> None
alias c_raylib_rlColor4ub = fn(r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> None
alias c_raylib_rlNormal3f = fn(x: Float32, y: Float32, z: Float32) -> None
alias c_raylib_rlVertex2f = fn(x: Float32, y: Float32) -> None
alias c_raylib_rlTexCoord2f = fn(x: Float32, y: Float32) -> None

alias c_raylib_rlSetTexture = fn( id: UInt32 ) -> None



#%%%%%%%%%%%%%%%%%%%%%%%%
# MARK: Raylib External Bindings
#%%%%%%%%%%%%%%%%%%%%%%%%
# Core
alias c_raylib_ClearBackground = fn(color: UnsafePointer[Color]) -> None
alias c_raylib_BeginMode2D = fn(camera2D: UnsafePointer[Camera2D]) -> None
alias c_raylib_BeginMode3D = fn(camera3D: UnsafePointer[Camera3D]) -> None

# Module: rshape
alias c_raylib_DrawLine = fn(start_pos_x: Int32, start_pos_y: Int32, end_pos_x: Int32, end_pos_y: Int32, color: UnsafePointer[Color]) -> None
alias c_raylib_DrawLineV = fn(start_pos: UnsafePointer[Vec2], end_pos: UnsafePointer[Vec2], color: UnsafePointer[Color]) -> None

alias c_raylib_DrawCircle = fn(center_x: Int32, center_y: Int32, radius: Float32, color: UnsafePointer[Color]) -> None
alias c_raylib_DrawCircleV = fn(center: UnsafePointer[Vec2], radius: Float32, color: UnsafePointer[Color]) -> None
alias c_raylib_DrawCircleLines = fn(center_x: Int32, center_y: Int32, radius: Float32, color: UnsafePointer[Color]) -> None

alias c_raylib_DrawRectangle = fn(x: Int32, y: Int32, width: Int32, height: Int32, color: UnsafePointer[Color]) -> None
alias c_raylib_DrawRectangleV = fn(position: UnsafePointer[Vec2], size: UnsafePointer[Vec2], color: UnsafePointer[Color]) -> None
alias c_raylib_DrawRectangleRec = fn(rect: UnsafePointer[Rectangle], color: UnsafePointer[Color]) -> None
alias c_raylib_DrawRectanglePro = fn(rect: UnsafePointer[Rectangle], origin: UnsafePointer[Vec2], rotation: Float32, color: UnsafePointer[Color]) -> None

alias c_raylib_DrawRectangleLines = fn(x: Int32, y: Int32, width: Int32, height: Int32, color: UnsafePointer[Color]) -> None
alias c_raylib_DrawRectangleRounded = fn(rec: Rectangle, roundness: Float32, segments: Int, color: UnsafePointer[Color]) -> None
alias c_raylib_DrawRectangleRoundedLines = fn(rec: Rectangle, roundness: Float32, segments: Int32, color: UnsafePointer[Color]) -> None

alias c_raylib_DrawPoly = fn(center: UnsafePointer[Vec2], sides: Int32, radius: Float32, rotation: Float32, color: UnsafePointer[Color]) -> None
alias c_raylib_DrawPolyLines = fn(center: UnsafePointer[Vec2], sides: Int32, radius: Float32, rotation: Float32, color: UnsafePointer[Color])  -> None
alias c_raylib_DrawPolyLinesEx = fn(center: UnsafePointer[Vec2], sides: Int32, radius: Float32, rotation: Float32, line_thick: Float32, color: UnsafePointer[Color])  -> None

# Module: rmodels
alias c_raylib_DrawCube = fn(position: UnsafePointer[Vector3], width: Float32, height: Float32, length: Float32, color: UnsafePointer[Color]) -> None
alias c_raylib_DrawCubeV = fn(position: UnsafePointer[Vector3], size: UnsafePointer[Vector3], color: UnsafePointer[Color]) -> None
alias c_raylib_DrawCubeWires = fn(position: UnsafePointer[Vector3], width: Float32, height: Float32, length: Float32, color: UnsafePointer[Color]) -> None
alias c_raylib_DrawCubeWiresV = fn(position: UnsafePointer[Vector3], size: UnsafePointer[Vector3], color: UnsafePointer[Color]) -> None

# Module: text
alias c_raylib_DrawText_ptr = fn(text: DTypePointer[DType.int8], pos_x: Int32, pos_y: Int32, font_size: Int32, color: UnsafePointer[Color]) -> None

# Module: rlglfw, low level rendering functions
alias c_raylib_GetShapesTexture = fn() -> UnsafePointer[Texture2D]
alias c_raylib_GetShapesTextureRectangle = fn() -> UnsafePointer[Rectangle]

# alias RAYLIB_PATH = '/home/ryan/raylib_edits/raylib/build/raylib/libraylib.so' # path to editted raylib
alias RAYLIB_PATH = '/usr/local/lib/libraylib.so'
# alias RAYLIB_EXTERNAL_BINDINGS_PATH = '/home/ryan/projects/raylib_bindings/lib/libraylib_bindings.so'
alias RAYLIB_EXTERNAL_BINDINGS_PATH = '/home/ryan/mojo-projects/fire-physics-engine/raylib_bindings/lib/libraylib_bindings.so'

# MARK: RayLib
@value
struct RayLib:
    # raylib internal bindings
    var init_window: c_raylib_InitWindow
    """Test."""
    var update_camera_3d: c_raylib_UpdateCamera3D
    var update_camera_2d: c_raylib_UpdateCamera2D
    var window_should_close: c_raylib_WindowShouldClose
    var close_window: c_raylib_CloseWindow
    var begin_drawing: c_raylib_BeginDrawing
    var end_drawing: c_raylib_EndDrawing
    var end_mode_3d: c_raylib_EndMode3D
    var end_mode_2d: c_raylib_EndMode2D

    var set_target_fps: c_raylib_SetTargetFPS
    var get_frame_time: c_raylib_GetFrameTime
    var get_time: c_raylib_GetTime
    var get_fps: c_raylib_GetFPS

    var draw_grid: c_raylib_DrawGrid
    var draw_text: c_raylib_DrawText_ptr
    var draw_fps: c_raylib_DrawFPS

    var gl_begin: c_raylib_glBegin
    var rl_begin: c_raylib_rlBegin
    var rl_end: c_raylib_rlEnd
    var rl_color_4ub: c_raylib_rlColor4ub
    var rl_normal: c_raylib_rlNormal3f
    var rl_vertex_2f: c_raylib_rlVertex2f
    var rl_tex_coord_2f: c_raylib_rlTexCoord2f

    var rl_set_texture: c_raylib_rlSetTexture

    # raylib external bindings
    var begin_mode_2d: c_raylib_BeginMode2D
    var begin_mode_3d: c_raylib_BeginMode3D
    var clear_background: c_raylib_ClearBackground

    var is_key_pressed: c_raylib_IsKeyPressed
    var is_key_pressed_repeat: c_raylib_IsKeyPressedRepeat
    var is_key_down: c_raylib_IsKeyDown
    var is_key_released: c_raylib_IsKeyReleased
    var is_key_up: c_raylib_IsKeyUp
    var get_key_pressed: c_raylib_GetKeyPressed
    var get_char_pressed: c_raylib_GetCharPressed
    var set_exit_key: c_raylib_SetExitKey

    var is_mouse_button_pressed: c_raylib_IsMouseButtonPressed
    var is_mouse_button_down: c_raylib_IsMouseButtonDown
    var is_mouse_button_released: c_raylib_IsMouseButtonReleased
    var is_mouse_button_up: c_raylib_IsMouseButtonUp
    var get_mouse_x: c_raylib_GetMouseX
    var get_mouse_y: c_raylib_GetMouseY
    var get_mouse_delta: c_raylib_GetMouseDelta
    var set_mouse_position: c_raylib_SetMousePosition
    var set_mouse_offset: c_raylib_SetMouseOffset
    var set_mouse_scale: c_raylib_SetMouseScale
    var get_mouse_wheel_move: c_raylib_GetMouseWheelMove
    var get_mouse_wheel_move_v: c_raylib_GetMouseWheelMoveV
    var set_mouse_cursor: c_raylib_SetMouseCursor

    var draw_line: c_raylib_DrawLine
    var draw_line_v: c_raylib_DrawLineV

    var draw_circle: c_raylib_DrawCircle
    var draw_circle_v: c_raylib_DrawCircleV
    var draw_circle_lines: c_raylib_DrawCircleLines

    var draw_rectangle: c_raylib_DrawRectangle
    var draw_rectangle_v: c_raylib_DrawRectangleV
    var draw_rectangle_rect: c_raylib_DrawRectangleRec
    var draw_rectangle_pro: c_raylib_DrawRectanglePro

    var draw_rectangle_lines: c_raylib_DrawRectangleLines
    var draw_rectangle_rounded: c_raylib_DrawRectangleRounded
    # var draw_rectangle_rounded_lines: c_raylib_DrawRectangleRoundedLines

    var draw_poly: c_raylib_DrawPoly
    var draw_poly_lines: c_raylib_DrawPolyLines
    var draw_poly_lines_ex: c_raylib_DrawPolyLinesEx

    var draw_cube: c_raylib_DrawCube
    var draw_cube_v: c_raylib_DrawCubeV
    var draw_cube_wires : c_raylib_DrawCubeWires
    var draw_cube_wires_v : c_raylib_DrawCubeWiresV

    var get_shapes_texture: c_raylib_GetShapesTexture
    var get_shapes_texture_rect: c_raylib_GetShapesTextureRectangle


    fn __init__(inout self):
        var raylib_internal = DLHandle(RAYLIB_PATH)
        var raylib_external = DLHandle(RAYLIB_EXTERNAL_BINDINGS_PATH)

        # raylib external bindings
        self.init_window = raylib_internal.get_function[c_raylib_InitWindow]('InitWindow')
        self.update_camera_3d = raylib_internal.get_function[c_raylib_UpdateCamera3D]('UpdateCamera')
        self.update_camera_2d = raylib_internal.get_function[c_raylib_UpdateCamera2D]('UpdateCamera')
        self.window_should_close = raylib_internal.get_function[c_raylib_WindowShouldClose]('WindowShouldClose')
        self.close_window = raylib_internal.get_function[c_raylib_CloseWindow]('CloseWindow')
        self.begin_drawing = raylib_internal.get_function[c_raylib_BeginDrawing]('BeginDrawing')
        self.end_drawing = raylib_internal.get_function[c_raylib_EndDrawing]('EndDrawing')
        self.end_mode_3d = raylib_internal.get_function[c_raylib_EndMode3D]('EndMode3D')
        self.end_mode_2d = raylib_internal.get_function[c_raylib_EndMode2D]('EndMode2D')

        self.set_target_fps = raylib_internal.get_function[c_raylib_SetTargetFPS]('SetTargetFPS')
        self.get_frame_time = raylib_internal.get_function[c_raylib_GetFrameTime]('GetFrameTime')
        self.get_time = raylib_internal.get_function[c_raylib_GetTime]('GetTime')
        self.get_fps = raylib_internal.get_function[c_raylib_GetFPS]('GetFPS')

        self.draw_grid = raylib_internal.get_function[c_raylib_DrawGrid]('DrawGrid')
        self.draw_fps = raylib_internal.get_function[c_raylib_DrawFPS]('DrawFPS')

        self.is_key_pressed = raylib_internal.get_function[c_raylib_IsKeyPressed]('IsKeyPressed')
        self.is_key_pressed_repeat = raylib_internal.get_function[c_raylib_IsKeyPressedRepeat]('IsKeyPressedRepeat')
        self.is_key_down = raylib_internal.get_function[c_raylib_IsKeyDown]('IsKeyDown')
        self.is_key_released = raylib_internal.get_function[c_raylib_IsKeyReleased]('IsKeyReleased')
        self.is_key_up = raylib_internal.get_function[c_raylib_IsKeyUp]('IsKeyUp')
        self.get_key_pressed = raylib_internal.get_function[c_raylib_GetKeyPressed]('GetKeyPressed')
        self.get_char_pressed = raylib_internal.get_function[c_raylib_GetCharPressed]('GetCharPressed')
        self.set_exit_key = raylib_internal.get_function[c_raylib_SetExitKey]('SetExitKey')

        self.is_mouse_button_pressed = raylib_internal.get_function[c_raylib_IsMouseButtonPressed]('IsMouseButtonPressed')
        self.is_mouse_button_down = raylib_internal.get_function[c_raylib_IsMouseButtonDown]('IsMouseButtonDown')
        self.is_mouse_button_released = raylib_internal.get_function[c_raylib_IsMouseButtonReleased]('IsMouseButtonReleased')
        self.is_mouse_button_up = raylib_internal.get_function[c_raylib_IsMouseButtonUp]('IsMouseButtonUp')
        self.get_mouse_x = raylib_internal.get_function[c_raylib_GetMouseX]('GetMouseX')
        self.get_mouse_y = raylib_internal.get_function[c_raylib_GetMouseY]('GetMouseY')
        self.get_mouse_delta = raylib_internal.get_function[c_raylib_GetMouseDelta]('GetMouseDelta')
        self.set_mouse_position = raylib_internal.get_function[c_raylib_SetMousePosition]('SetMousePosition')
        self.set_mouse_offset = raylib_internal.get_function[c_raylib_SetMouseOffset]('SetMouseOffset')
        self.set_mouse_scale = raylib_internal.get_function[c_raylib_SetMouseScale]('SetMouseScale')
        self.get_mouse_wheel_move = raylib_internal.get_function[c_raylib_GetMouseWheelMove]('GetMouseWheelMove')
        self.get_mouse_wheel_move_v = raylib_internal.get_function[c_raylib_GetMouseWheelMoveV]('GetMouseWheelMoveV')
        self.set_mouse_cursor = raylib_internal.get_function[c_raylib_SetMouseCursor]('SetMouseCursor')

        self.gl_begin = raylib_internal.get_function[c_raylib_glBegin]('glBegin')
        self.rl_begin = raylib_internal.get_function[c_raylib_rlBegin]('rlBegin')
        self.rl_end = raylib_internal.get_function[c_raylib_rlEnd]('rlEnd')
        self.rl_color_4ub = raylib_internal.get_function[c_raylib_rlColor4ub]('rlColor4ub')
        self.rl_normal = raylib_internal.get_function[c_raylib_rlNormal3f]('rlNormal3f')
        self.rl_vertex_2f = raylib_internal.get_function[c_raylib_rlVertex2f]('rlVertex2f')
        self.rl_tex_coord_2f = raylib_internal.get_function[c_raylib_rlTexCoord2f]('rlTexCoord2f')

        self.rl_set_texture = raylib_internal.get_function[c_raylib_rlSetTexture]('rlSetTexture')

        # raylib external bindings
        self.begin_mode_2d = raylib_external.get_function[c_raylib_BeginMode2D]('_BeginMode2D')
        self.begin_mode_3d = raylib_external.get_function[c_raylib_BeginMode3D]('_BeginMode3D')
        self.clear_background = raylib_external.get_function[c_raylib_ClearBackground]('_ClearBackground')

        self.draw_text = raylib_external.get_function[c_raylib_DrawText_ptr]('_DrawText')

        self.draw_line = raylib_external.get_function[c_raylib_DrawLine]('_DrawLine')
        self.draw_line_v = raylib_external.get_function[c_raylib_DrawLineV]('_DrawLineV')
        
        self.draw_circle = raylib_external.get_function[c_raylib_DrawCircle]('_DrawCircle')
        self.draw_circle_v = raylib_external.get_function[c_raylib_DrawCircleV]('_DrawCircleV')
        self.draw_circle_lines = raylib_external.get_function[c_raylib_DrawCircleLines]('_DrawCircleLines')

        self.draw_rectangle = raylib_external.get_function[c_raylib_DrawRectangle]('_DrawRectangle')
        self.draw_rectangle_v = raylib_external.get_function[c_raylib_DrawRectangleV]('_DrawRectangleV')
        self.draw_rectangle_rect = raylib_external.get_function[c_raylib_DrawRectangleRec]('_DrawRectangleRec')
        self.draw_rectangle_pro = raylib_external.get_function[c_raylib_DrawRectanglePro]('_DrawRectanglePro')

        self.draw_rectangle_lines = raylib_external.get_function[c_raylib_DrawRectangleLines]('_DrawRectangleLines')
        self.draw_rectangle_rounded = raylib_external.get_function[c_raylib_DrawRectangleRounded]('_DrawRectangleRounded')
        # self.draw_rectangle_rounded_lines = raylib_external.get_function[c_raylib_DrawRectangleRoundedLines]('_DrawRectangleRoundedLines')

        self.draw_poly = raylib_external.get_function[c_raylib_DrawPoly]('_DrawPoly')
        self.draw_poly_lines = raylib_external.get_function[c_raylib_DrawPolyLines]('_DrawPolyLines')
        self.draw_poly_lines_ex = raylib_external.get_function[c_raylib_DrawPolyLinesEx]('_DrawPolyLinesEx')

        self.draw_cube = raylib_external.get_function[c_raylib_DrawCube]('_DrawCube')
        self.draw_cube_v = raylib_external.get_function[c_raylib_DrawCubeV]('_DrawCubeV')
        self.draw_cube_wires = raylib_external.get_function[c_raylib_DrawCubeWires]('_DrawCubeWires')
        self.draw_cube_wires_v = raylib_external.get_function[c_raylib_DrawCubeWiresV]('_DrawCubeWiresV')

        self.get_shapes_texture = raylib_external.get_function[c_raylib_GetShapesTexture]('GetShapesTexture')
        self.get_shapes_texture_rect = raylib_external.get_function[c_raylib_GetShapesTextureRectangle]('GetShapesTextureRectangle')
