part of 'raylib.dart';

abstract interface class Disposeable
{
  void dispose();
}

// C memory resourcers manager class
class NativeResource<T extends NativeType> implements Disposeable {
  final Pointer<T> pointer;
  bool _disposed = false;
  bool IsOwner = true;

  NativeResource(this.pointer, { this.IsOwner = true });

  bool get isDisposed => _disposed;
  void MarkAsDisposed() { _disposed = true; }

  @override
  void dispose()
  {
    if (!isDisposed && IsOwner)
    {
      MarkAsDisposed();
      malloc.free(this.pointer);
    }
  }
}

const int RAYLIB_VERSION_MAJOR = 5;
const int RAYLIB_VERSION_MINOR = 6;
const int RAYLIB_VERSION_PATCH = 0;
const String RAYLIB_VERSION = '5.6-dev';

const double PI = 3.14159265358979323846;
const double DEG2RAG = (PI/180.0);
const double RAD2DEG = (180.0/PI);
const double EPSILON = 0.000001;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// Vector2, 2 components
final class _Vector2 extends Struct
{
  @Float() external double x;          // Vector x component
  @Float() external double y;          // Vector y component
}

// Vector3, 3 components
final class _Vector3 extends Struct
{
  @Float() external double x;          // Vector x component
  @Float() external double y;          // Vector y component
  @Float() external double z;          // Vector z component
}

// Vector4, 4 components
final class _Vector4 extends Struct
{
  @Float() external double x;          // Vector x component
  @Float() external double y;          // Vector y component
  @Float() external double z;          // Vector z component
  @Float() external double w;          // Vector w component
}

// Quaternion, 4 components (Vector4 alias)
typedef _Quaternion = _Vector4;

// Matrix, 4x4 components, column major, OpenGL style, right-handed
// ToDO: Implement native Raylib Matrix constructors inside struct
final class _Matrix extends Struct
{
  @Float() external double m0; @Float() external double m4; @Float() external double m8;  @Float() external double m12;
  @Float() external double m1; @Float() external double m5; @Float() external double m9;  @Float() external double m13;
  @Float() external double m2; @Float() external double m6; @Float() external double m10; @Float() external double m14;
  @Float() external double m3; @Float() external double m7; @Float() external double m11; @Float() external double m15;
}

// Color, 4 components, R8G8B8A8 (32bit)
// Use Colors.NewColor to instantiate a new Color
final class _Color extends Struct
{
  @Uint8() external int r;             // Color red value
  @Uint8() external int g;             // Color green value
  @Uint8() external int b;             // Color blue value
  @Uint8() external int a;             // Color alpha value
}

// Rectangle, 4 components
final class _Rectangle extends Struct
{
  @Float() external double x;          // Rectangle top-left corner position x
  @Float() external double y;          // Rectangle top-left corner position y
  @Float() external double width;      // Rectangle width
  @Float() external double height;     // Rectangle height
}

// Image, pixel data stored in CPU memory (RAM)
final class _Image extends Struct
{
  external Pointer<Void> data;         // Image raw data
  @Int32() external int width;         // Image base width
  @Int32() external int height;        // Image base height
  @Int32() external int mipmaps;       // Mipmap levels, 1 by default
  @Int32() external int format;        // Data format (PixelFormat type)
}

// Texture, tex data stored in GPU memory (VRAM)
final class _Texture extends Struct
{
  @Uint32() external int id;           // OpenGL texture id
  @Int32()  external int width;        // Texture base width
  @Int32()  external int heigth;       // Texture base height
  @Int32()  external int mipmaps;      // Mipmap levels, 1 by default
  @Int32()  external int format;       // Data format (PixelFormat type)
}

// Texture2D, same as Texture
typedef _Texture2D = _Texture;

// TextureCubemap, same as Texture
typedef _TextureCubemap = _Texture;

// RenderTexture, fbo for texture rendering
final class _RenderTexture extends Struct
{
  @Uint32() external int id;           // OpenGL framebuffer object id
  external _Texture texture;   // Color buffer attachment texture
  external _Texture depth;     // Depth buffer attachment texture
}

// RenderTexture2D, same as RenderTexture
typedef _RenderTexture2D = _RenderTexture;

// NPatchInfo, n-patch layout info
// ToDO: Implement constructor functions as native of the class
final class _NPatchInfo extends Struct
{
  external _Rectangle source;  // Texture source rectangle
  @Int32() external int left;          // Left border offset
  @Int32() external int top;           // Top border offset
  @Int32() external int right;         // Right border offset
  @Int32() external int bottom;        // Bottom border offset
  @Int32() external int layout;        // Layout of the n-patch: 3x3, 1x3 or 3x1
}

// GlyphInfo, font characters glyphs info
final class _GlyphInfo extends Struct
{
  @Int32() external int value;         // Character value (Unicode)
  @Int32() external int offsetX;       // Character offset X when drawing
  @Int32() external int offsetY;       // Character offset Y when drawing
  @Int32() external int advanceX;      // Character advance position X
  external _Image image;       // Character image data
}

// Font, font texture and GlyphInfo array data
final class _Font extends Struct
{
  @Int32() external int baseSize;      // Base size (default chars height)
  @Int32() external int glyphCount;    // Number of glyph characters
  @Int32() external int glyphPadding;  // Padding around the glyph characters
  external _Texture texture;   // Texture atlas containing the glyphs
  external Pointer<_Rectangle> recs;    // Rectangles in texture for the glyphs. It's a pointer by default on Raylib
  external Pointer<_GlyphInfo> glyphs;  // Glyphs info data. It's a pointer by default on Raylib
}

// Camera, defines position/orientation in 3d space
final class _Camera3D extends Struct
{
  external _Vector3 position;  // Camera position
  external _Vector3 target;    // Camera target it looks-at
  external _Vector3 up;        // Camera up vector (rotation over its axis)
  @Float() external double fovy;       // Camera field-of-view aperture in Y (degrees) in perspective, used as near plane height in world units in orthographic
  @Int32() external int projection;    // Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

typedef _Camera = _Camera3D;             // Camera type fallback, defaults to Camera3D

// Camera2D, defines position/orientation in 2d space
final class _Camera2D extends Struct
{
  external _Vector2 offset;    // Camera offset (screen space offset from window origin)
  external _Vector2 target;    // Camera target (world space target point that is mapped to screen space offset)
  @Float() external double rotation;   // Camera rotation in degrees (pivots around target)
  @Float() external double zoom;       // Camera zoom (scaling around target), must not be set to 0, set to 1.0f for no scale
}

// Mesh, vertex data and vao/vbo
final class _Mesh extends Struct
{
  @Int32() external int vertexCount;   // Number of vertices stored in arrays
  @Int32() external int triagleCoung;  // Number of triangles stored (indexed or not)

  // Vertex attributes data
  external Pointer<Float> vertices;    // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
  external Pointer<Float> texcoords;   // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
  external Pointer<Float> texcoords2;  // Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
  external Pointer<Float> normals;     // Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
  external Pointer<Float> tangents;    // Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
  external Pointer<Uint8> colors;      // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
  external Pointer<Uint16> indices;    // Vertex indices (in case vertex data comes indexed)

  // Animation vertex data
  external Pointer<Float> animVertices;// Animated vertex positions (after bones transformations)
  external Pointer<Float> animNormals; // Animated normals (after bones transformations)
  external Pointer<Uint8> boneIds;     // Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning) (shader-location = 6)
  external Pointer<Float> boneWeights; // Vertex bone weight, up to 4 bones influence by vertex (skinning) (shader-location = 7)
  external Pointer<_Matrix> boneMatrices; // Bones animated transformation matrices
  @Int32() external int boneCount;     // Number of bones

  @Uint32() external int vaoID;        // OpenGL Vertex Array Object id
  external Pointer<Int32> vboId;       // OpenGL Vertex Buffer Objects id (default vertex data)
}

// Shader
final class Shader extends Struct
{
  @Uint32() external int id;           // Shader program id
  external Pointer<Int32> locs;        // Shader locations array (RL_MAX_SHADER_LOCATIONS)
}

// MaterialMap
final class MaterialMap extends Struct
{
  external _Texture2D texture;          // Material shader
  external _Color color;                // Material map color
  @Float() external double value;      // Material map value
}

// Material, includes shader and maps
final class _Material extends Struct
{
  external Shader shader;              // Material shader
  external Pointer<MaterialMap> maps;  // Material maps array (MAX_MATERIAL_MAPS)
  @Array(4) external Array<Float> params; // Material generic parameters (if required)
}

// Transform, vertex transformation data
final class _Transform extends Struct
{
  external _Vector3 translation;        // Translation
  external _Quaternion rotation;        // Rotation
  external _Vector3 scale;              // Scale
}

// Bone, skeletal animation bone
final class _BoneInfo extends Struct
{
  @Array(32) external Array<Uint8> name;// Bone name
  @Int32() external int parent;        // Bone parent
}

// Model, meshes, materials and animation data
final class _Model extends Struct
{
  external _Matrix transform;           // Local transform matrix

  @Int32() external int meshCount;     // Number of meshes
  @Int32() external int materialCount; // Number of materials
  external Pointer<_Mesh> meshes;       // Meshes array
  external Pointer<_Material> materials;// Materials array
  external Pointer<Int32> meshMaterial;// Mesh material number

  // Animation data
  @Int32() external int boneCount;     // Number of bones
  external Pointer<_BoneInfo> bones;    // Bones information (skeleton)
  external Pointer<_Transform> bindPose;// Bones base transformation (pose)
}

// ModelAnimation
final class ModelAnimation extends Struct
{
  @Int32() external int boneCount;     // Number of bones
  @Int32() external int frameCount;    // Number of animation frames
  external Pointer<_BoneInfo> bones;    // Bones information (skeleton)
  external Pointer<Pointer<_Transform>> framePoses; // Poses array by frame
  @Array(32) external Array<Uint8> name; // Animation name
}

// Ray, ray for raycasting
final class Ray extends Struct
{
  external _Vector3 position;           // Ray position (origin)
  external _Vector3 direction;          // Ray direction (normalized)
}

final class RayCollision extends Struct
{
  @Bool() external bool hit;           // Did the ray hit something?
  @Float() external double distance;   // Distance to the nearest hit
  external _Vector3 point;              // Point of the nearest hit
  external _Vector3 normal;             // Surface normal of hit
}

// BoundingBox
final class _BoundingBox extends Struct
{
  external _Vector3 min;                // Minimum vertex box-corner
  external _Vector3 max;                // Maximum vertex box-corner
}

// Wave, audio wave data
final class Wave extends Struct
{
  @Uint32() external int frameCount;   // Total number of frames (considering channels)
  @Uint32() external int sampleRate;   // Frequency (samples per second)
  @Uint32() external int sampleSize;   // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
  @Uint32() external int channels;     // Number of channels (1-mono, 2-stereo, ...)
  external Pointer<Void> data;         // Buffer data pointer
}
/* 
typedef rAudioBuffer = rAudioBuffer;
typedef rAudioProcessor = rAudioProcessor;

final class AudioStream extends Struct
{
  external Pointer<rAudioBuffer> buffer; // Pointer to internal data used by the audio system
  external Pointer<rAudioProcessor> processor; // Pointer to internal data processor, useful for audio effects

  @Uint32() external int sampleRate;   // Frequency (samples per second)
  @Uint32() external int sampleSize;   // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
  @Uint32() external int channels;     // Number of channels (1-mono, 2-stereo, ...)
}

// Sound
final class Sound extends Struct
{
  external AudioStream stream;         // Audio stream
  @Uint32() external int frameCount;   // Total number of frames (considering channels)
}

// Music, audio stream, anything longer than ~10 seconds should be streamed
final class Music extends Struct
{
  external AudioStream stream;         // Audio stream
  @Uint32() external int frameCount;   // Total number of frames (considering channels)
  @Bool() external bool looping;       // Music looping enable

  @Int32() external int ctxType;       // Type of music context (audio filetype)
  external Pointer<Void> ctxData;      // Audio context data, depends on type
}
*/
// VrDeviceInfo, Head-Mounted-Display device parameters
final class VrDeviceInfo extends Struct
{
  @Int32() external int hResolution;   // Horizontal resolution in pixels
  @Int32() external int vResolution;   // Vertical resolution in pixels
  @Float() external double hScreenSize;// Horizontal size in meters
  @Float() external double vScreenSize;// Vertical size in meters
  @Float() external double eyeToScreenDistance; // Distance between eye and display in meters
  @Float() external double lensSeparationDistance; // Lens separation distance in meters
  @Float() external double interpupillaryDistance; // IPD (distance between pupils) in meters
  @Array(4) external Array<Float> lensDistortionValues; // Lens distortion constant parameters
  @Array(4) external Array<Float> chromaAbCorrection; // Chromatic aberration correction parameters
}

final class VrStereoConfig extends Struct
{
  @Array(2) external Array<_Matrix> projection;
  @Array(2) external Array<_Matrix> viewOffset;
  @Array(2) external Array<Float> leftLensCenter;
  @Array(2) external Array<Float> rightLensCenter;
  @Array(2) external Array<Float> leftScreenCenter;
  @Array(2) external Array<Float> rightScreenCenter;
  @Array(2) external Array<Float> scale;
  @Array(2) external Array<Float> scaleIn;
}

// File path list
final class FilePathList extends Struct
{
  @Uint32() external int count;        // Filepaths entries count
  external Pointer<Pointer<Uint8>> paths; // Filepaths entries
}

// Automation event
final class AutomationEvent extends Struct
{
  @Uint32() external int frame;        // Event frame
  @Uint32() external int type;         // Event type (AutomationEventType)
  @Array(4) external Array<Int32> params; // Event parameters (if required)
}

// Automation event list
final class AutomationEventList extends Struct
{
  @Uint32() external int capacity;     // Events max entries (MAX_AUTOMATION_EVENTS)
  @Uint32() external int count;        // Events entries count
  external Pointer<AutomationEvent> events; // Events entries
}

//----------------------------------------------------------------------------------
// Enumerators Definition
//----------------------------------------------------------------------------------
/// System/Window config flags
/// 
/// NOTE: Every bit registers one state (use it with bit masks)
/// 
/// By default all flags are set to 0
abstract class ConfigFlags
{
  static const int VSYNC_HINT         = 0x00000040;   // Set to try enabling V-Sync on GPU
  static const int FULLSCREEN_MODE    = 0x00000002;   // Set to run program in fullscreen
  static const int WINDOW_RESIZABLE   = 0x00000004;   // Set to allow resizable window
  static const int WINDOW_UNDECORATED = 0x00000008;   // Set to disable window decoration (frame and buttons)
  static const int WINDOW_HIDDEN      = 0x00000080;   // Set to hide window
  static const int WINDOW_MINIMIZED   = 0x00000200;   // Set to minimize window (iconify)
  static const int WINDOW_MAXIMIZED   = 0x00000400;   // Set to maximize window (expanded to monitor)
  static const int WINDOW_UNFOCUSED   = 0x00000800;   // Set to window non focused
  static const int WINDOW_TOPMOST     = 0x00001000;   // Set to window always on top
  static const int WINDOW_ALWAYS_RUN  = 0x00000100;   // Set to allow windows running while minimized
  static const int WINDOW_TRANSPARENT = 0x00000010;   // Set to allow transparent framebuffer
  static const int WINDOW_HIGHDPI     = 0x00002000;   // Set to support HighDPI
  static const int WINDOW_MOUSE_PASSTHROUGH = 0x00004000; // Set to support mouse passthrough only supported when FLAG_WINDOW_UNDECORATED
  static const int BORDERLESS_WINDOWED_MODE = 0x00008000; // Set to run program in borderless windowed mode
  static const int MSAA_4X_HINT       = 0x00000020;   // Set to try enabling MSAA 4X
  static const int INTERLACED_HINT    = 0x00010000;   // Set to try enabling interlaced video format (for V3D)
}

/// Trace log level
/// NOTE: Organized by priority level
enum TraceLogLevel
{
  LOG_ALL,            // Display all logs
  LOG_TRACE,          // Trace logging, intended for internal use only
  LOG_DEBUG,          // Debug logging, used for internal debugging, it should be disabled on release builds
  LOG_INFO,           // Info logging, used for program execution info
  LOG_WARNING,        // Warning logging, used on recoverable failures
  LOG_ERROR,          // Error logging, used on unrecoverable failures
  LOG_FATAL,          // Fatal logging, used to abort program: exit(EXIT_FAILURE)
  LOG_NONE            // Disable logging
}

/// Keyboard keys (US keyboard layout)
/// 
/// NOTE: Use GetKeyPressed() to allow redefining required keys for alternative layouts
abstract class KeyboardKey
{
  static const int KEY_NULL            = 0;        // Key: NULL, used for no key pressed
  // Alphanumeric keys
  static const int KEY_APOSTROPHE      = 39;       // Key: '
  static const int KEY_COMMA           = 44;       // Key: ,
  static const int KEY_MINUS           = 45;       // Key: -
  static const int KEY_PERIOD          = 46;       // Key: .
  static const int KEY_SLASH           = 47;       // Key: /
  static const int KEY_ZERO            = 48;       // Key: 0
  static const int KEY_ONE             = 49;       // Key: 1
  static const int KEY_TWO             = 50;       // Key: 2
  static const int KEY_THREE           = 51;       // Key: 3
  static const int KEY_FOUR            = 52;       // Key: 4
  static const int KEY_FIVE            = 53;       // Key: 5
  static const int KEY_SIX             = 54;       // Key: 6
  static const int KEY_SEVEN           = 55;       // Key: 7
  static const int KEY_EIGHT           = 56;       // Key: 8
  static const int KEY_NINE            = 57;       // Key: 9
  static const int KEY_SEMICOLON       = 59;       // Key: ;
  static const int KEY_EQUAL           = 61;       // Key: =
  static const int KEY_A               = 65;       // Key: A | a
  static const int KEY_B               = 66;       // Key: B | b
  static const int KEY_C               = 67;       // Key: C | c
  static const int KEY_D               = 68;       // Key: D | d
  static const int KEY_E               = 69;       // Key: E | e
  static const int KEY_F               = 70;       // Key: F | f
  static const int KEY_G               = 71;       // Key: G | g
  static const int KEY_H               = 72;       // Key: H | h
  static const int KEY_I               = 73;       // Key: I | i
  static const int KEY_J               = 74;       // Key: J | j
  static const int KEY_K               = 75;       // Key: K | k
  static const int KEY_L               = 76;       // Key: L | l
  static const int KEY_M               = 77;       // Key: M | m
  static const int KEY_N               = 78;       // Key: N | n
  static const int KEY_O               = 79;       // Key: O | o
  static const int KEY_P               = 80;       // Key: P | p
  static const int KEY_Q               = 81;       // Key: Q | q
  static const int KEY_R               = 82;       // Key: R | r
  static const int KEY_S               = 83;       // Key: S | s
  static const int KEY_T               = 84;       // Key: T | t
  static const int KEY_U               = 85;       // Key: U | u
  static const int KEY_V               = 86;       // Key: V | v
  static const int KEY_W               = 87;       // Key: W | w
  static const int KEY_X               = 88;       // Key: X | x
  static const int KEY_Y               = 89;       // Key: Y | y
  static const int KEY_Z               = 90;       // Key: Z | z
  static const int KEY_LEFT_BRACKET    = 91;       // Key: [
  static const int KEY_BACKSLASH       = 92;       // Key: '\'
  static const int KEY_RIGHT_BRACKET   = 93;       // Key: ]
  static const int KEY_GRAVE           = 96;       // Key: `
  // Function keys
  static const int KEY_SPACE           = 32;       // Key: Space
  static const int KEY_ESCAPE          = 256;      // Key: Esc
  static const int KEY_ENTER           = 257;      // Key: Enter
  static const int KEY_TAB             = 258;      // Key: Tab
  static const int KEY_BACKSPACE       = 259;      // Key: Backspace
  static const int KEY_INSERT          = 260;      // Key: Ins
  static const int KEY_DELETE          = 261;      // Key: Del
  static const int KEY_RIGHT           = 262;      // Key: Cursor right
  static const int KEY_LEFT            = 263;      // Key: Cursor left
  static const int KEY_DOWN            = 264;      // Key: Cursor down
  static const int KEY_UP              = 265;      // Key: Cursor up
  static const int KEY_PAGE_UP         = 266;      // Key: Page up
  static const int KEY_PAGE_DOWN       = 267;      // Key: Page down
  static const int KEY_HOME            = 268;      // Key: Home
  static const int KEY_END             = 269;      // Key: End
  static const int KEY_CAPS_LOCK       = 280;      // Key: Caps lock
  static const int KEY_SCROLL_LOCK     = 281;      // Key: Scroll down
  static const int KEY_NUM_LOCK        = 282;      // Key: Num lock
  static const int KEY_PRINT_SCREEN    = 283;      // Key: Print screen
  static const int KEY_PAUSE           = 284;      // Key: Pause
  static const int KEY_F1              = 290;      // Key: F1
  static const int KEY_F2              = 291;      // Key: F2
  static const int KEY_F3              = 292;      // Key: F3
  static const int KEY_F4              = 293;      // Key: F4
  static const int KEY_F5              = 294;      // Key: F5
  static const int KEY_F6              = 295;      // Key: F6
  static const int KEY_F7              = 296;      // Key: F7
  static const int KEY_F8              = 297;      // Key: F8
  static const int KEY_F9              = 298;      // Key: F9
  static const int KEY_F10             = 299;      // Key: F10
  static const int KEY_F11             = 300;      // Key: F11
  static const int KEY_F12             = 301;      // Key: F12
  static const int KEY_LEFT_SHIFT      = 340;      // Key: Shift left
  static const int KEY_LEFT_CONTROL    = 341;      // Key: Control left
  static const int KEY_LEFT_ALT        = 342;      // Key: Alt left
  static const int KEY_LEFT_SUPER      = 343;      // Key: Super left
  static const int KEY_RIGHT_SHIFT     = 344;      // Key: Shift right
  static const int KEY_RIGHT_CONTROL   = 345;      // Key: Control right
  static const int KEY_RIGHT_ALT       = 346;      // Key: Alt right
  static const int KEY_RIGHT_SUPER     = 347;      // Key: Super right
  static const int KEY_KB_MENU         = 348;      // Key: KB menu
  // Keypad keys
  static const int KEY_KP_0            = 320;      // Key: Keypad 0
  static const int KEY_KP_1            = 321;      // Key: Keypad 1
  static const int KEY_KP_2            = 322;      // Key: Keypad 2
  static const int KEY_KP_3            = 323;      // Key: Keypad 3
  static const int KEY_KP_4            = 324;      // Key: Keypad 4
  static const int KEY_KP_5            = 325;      // Key: Keypad 5
  static const int KEY_KP_6            = 326;      // Key: Keypad 6
  static const int KEY_KP_7            = 327;      // Key: Keypad 7
  static const int KEY_KP_8            = 328;      // Key: Keypad 8
  static const int KEY_KP_9            = 329;      // Key: Keypad 9
  static const int KEY_KP_DECIMAL      = 330;      // Key: Keypad .
  static const int KEY_KP_DIVIDE       = 331;      // Key: Keypad /
  static const int KEY_KP_MULTIPLY     = 332;      // Key: Keypad *
  static const int KEY_KP_SUBTRACT     = 333;      // Key: Keypad -
  static const int KEY_KP_ADD          = 334;      // Key: Keypad +
  static const int KEY_KP_ENTER        = 335;      // Key: Keypad Enter
  static const int KEY_KP_EQUAL        = 336;      // Key: Keypad =
  // Android key buttons
  static const int KEY_BACK            = 4;        // Key: Android back button
  static const int KEY_MENU            = 5;        // Key: Android menu button
  static const int KEY_VOLUME_UP       = 24;       // Key: Android volume up button
  static const int KEY_VOLUME_DOWN     = 25;       // Key: Android volume down button
}

/// Add backwards compatibility support for deprecated names
final int MOUSE_LEFT_BUTTON = MouseButton.LEFT.index;
final int MOUSE_RIGHT_BUTTON = MouseButton.RIGHT.index;
final int MOUSE_MIDDLE_BUTTON = MouseButton.MIDDLE.index;

/// Mouse buttons
enum MouseButton {
  LEFT,                 // Mouse button left
  RIGHT,                // Mouse button right
  MIDDLE,               // Mouse button middle (pressed wheel)
  SIDE,                 // Mouse button side (advanced mouse device)
  EXTRA,                // Mouse button extra (advanced mouse device)
  FORWARD,              // Mouse button forward (advanced mouse device)
  BACK,                 // Mouse button back (advanced mouse device)
}

/// Mouse cursor
enum MouseCursor {
  DEFAULT,              // Default pointer shape
  ARROW,                // Arrow shape
  IBEAM,                // Text writing cursor shape
  CROSSHAIR,            // Cross shape
  POINTING_HAND,        // Pointing hand cursor
  RESIZE_EW,            // Horizontal resize/move arrow shape
  RESIZE_NS,            // Vertical resize/move arrow shape
  RESIZE_NWSE,          // Top-left to bottom-right diagonal resize/move arrow shape
  RESIZE_NESW,          // The top-right to bottom-left diagonal resize/move arrow shape
  RESIZE_ALL,           // The omnidirectional resize/move cursor shape
  NOT_ALLOWED,          // The operation-not-allowed shape
}

/// Gamepad buttons
enum GamepadButton {
  UNKNOWN,            // Unknown button, just for error checking
  LEFT_FACE_UP,       // Gamepad left DPAD up button
  LEFT_FACE_RIGHT,    // Gamepad left DPAD right button
  LEFT_FACE_DOWN,     // Gamepad left DPAD down button
  LEFT_FACE_LEFT,     // Gamepad left DPAD left button
  RIGHT_FACE_UP,      // Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
  RIGHT_FACE_RIGHT,   // Gamepad right button right (i.e. PS3: Circle, Xbox: B)
  RIGHT_FACE_DOWN,    // Gamepad right button down (i.e. PS3: Cross, Xbox: A)
  RIGHT_FACE_LEFT,    // Gamepad right button left (i.e. PS3: Square, Xbox: X)
  LEFT_TRIGGER_1,     // Gamepad top/back trigger left (first), it could be a trailing button
  LEFT_TRIGGER_2,     // Gamepad top/back trigger left (second), it could be a trailing button
  RIGHT_TRIGGER_1,    // Gamepad top/back trigger right (first), it could be a trailing button
  RIGHT_TRIGGER_2,    // Gamepad top/back trigger right (second), it could be a trailing button
  MIDDLE_LEFT,        // Gamepad center buttons, left one (i.e. PS3: Select)
  MIDDLE,             // Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
  MIDDLE_RIGHT,       // Gamepad center buttons, right one (i.e. PS3: Start)
  LEFT_THUMB,         // Gamepad joystick pressed button left
  RIGHT_THUMB         // Gamepad joystick pressed button right
}

/// Gamepad axes
enum GamepadAxis {
  LEFT_X,               // Gamepad left stick X axis
  LEFT_Y,               // Gamepad left stick Y axis
  RIGHT_X,              // Gamepad right stick X axis
  RIGHT_Y,              // Gamepad right stick Y axis
  LEFT_TRIGGE,          // Gamepad back trigger left, pressure level: [1..-1]
  RIGHT_TRIGGER,        // Gamepad back trigger right, pressure level: [1..-1]
}

/// Material map index
enum MaterialMapIndex {
  ALBEDO,            // Albedo material (same as: MATERIAL_MAP_DIFFUSE)
  METALNESS,         // Metalness material (same as: MATERIAL_MAP_SPECULAR)
  NORMAL,            // Normal material
  ROUGHNESS,         // Roughness material
  OCCLUSION,         // Ambient occlusion material
  EMISSION,          // Emission material
  HEIGHT,            // Heightmap material
  CUBEMAP,           // Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  IRRADIANCE,        // Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  PREFILTER,         // Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  BRDF               // Brdf material
}

final int MATERIAL_MAP_DIFFUSE = MaterialMapIndex.ALBEDO.index;
final int MATERIAL_MAP_SPECULAR = MaterialMapIndex.METALNESS.index;

/// Shader location index
enum ShaderLocationIndex {
  VERTEX_POSITION,     // Shader location: vertex attribute: position
  VERTEX_TEXCOORD01,   // Shader location: vertex attribute: texcoord01
  VERTEX_TEXCOORD02,   // Shader location: vertex attribute: texcoord02
  VERTEX_NORMAL,       // Shader location: vertex attribute: normal
  VERTEX_TANGENT,      // Shader location: vertex attribute: tangent
  VERTEX_COLOR,        // Shader location: vertex attribute: color
  MATRIX_MVP,          // Shader location: matrix uniform: model-view-projection
  MATRIX_VIEW,         // Shader location: matrix uniform: view (camera transform)
  MATRIX_PROJECTION,   // Shader location: matrix uniform: projection
  MATRIX_MODEL,        // Shader location: matrix uniform: model (transform)
  MATRIX_NORMAL,       // Shader location: matrix uniform: normal
  VECTOR_VIEW,         // Shader location: vector uniform: view
  COLOR_DIFFUSE,       // Shader location: vector uniform: diffuse color
  COLOR_SPECULAR,      // Shader location: vector uniform: specular color
  COLOR_AMBIENT,       // Shader location: vector uniform: ambient color
  MAP_ALBEDO,          // Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
  MAP_METALNESS,       // Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
  MAP_NORMAL,          // Shader location: sampler2d texture: normal
  MAP_ROUGHNESS,       // Shader location: sampler2d texture: roughness
  MAP_OCCLUSION,       // Shader location: sampler2d texture: occlusion
  MAP_EMISSION,        // Shader location: sampler2d texture: emission
  MAP_HEIGHT,          // Shader location: sampler2d texture: height
  MAP_CUBEMAP,         // Shader location: samplerCube texture: cubemap
  MAP_IRRADIANCE,      // Shader location: samplerCube texture: irradiance
  MAP_PREFILTER,       // Shader location: samplerCube texture: prefilter
  MAP_BRDF,            // Shader location: sampler2d texture: brdf
  VERTEX_BONEIDS,      // Shader location: vertex attribute: boneIds
  VERTEX_BONEWEIGHTS,  // Shader location: vertex attribute: boneWeights
  BONE_MATRICES,       // Shader location: array of matrices uniform: boneMatrices
  VERTEX_INSTANCE_TX   // Shader location: vertex attribute: instanceTransform
}

final int SHADER_LOC_MAP_DIFFUSE = ShaderLocationIndex.MAP_ALBEDO.index;
final int SHADER_LOC_MAP_SPECULAR = ShaderLocationIndex.MAP_METALNESS.index;

/// Shader uniform data type
enum ShaderUniformDataType {
  FLOAT,           // Shader uniform type: float
  VEC2,            // Shader uniform type: vec2 (2 float)
  VEC3,            // Shader uniform type: vec3 (3 float)
  VEC4,            // Shader uniform type: vec4 (4 float)
  INT,             // Shader uniform type: int
  IVEC2,           // Shader uniform type: ivec2 (2 int)
  IVEC3,           // Shader uniform type: ivec3 (3 int)
  IVEC4,           // Shader uniform type: ivec4 (4 int)
  UINT,            // Shader uniform type: unsigned int
  UIVEC2,          // Shader uniform type: uivec2 (2 unsigned int)
  UIVEC3,          // Shader uniform type: uivec3 (3 unsigned int)
  UIVEC4,          // Shader uniform type: uivec4 (4 unsigned int)
  SAMPLER2D        // Shader uniform type: sampler2d
}

/// Shader attribute data types
enum ShaderAttributeDataType {
  SHADER_ATTRIB_FLOAT,            // Shader attribute type: float
  SHADER_ATTRIB_VEC2,             // Shader attribute type: vec2 (2 float)
  SHADER_ATTRIB_VEC3,             // Shader attribute type: vec3 (3 float)
  SHADER_ATTRIB_VEC4              // Shader attribute type: vec4 (4 float)
}

/// Pixel formats
/// 
/// NOTE: Support depends on OpenGL version and platform
abstract class PixelFormat {
  static const int UNCOMPRESSED_GRAYSCALE = 1;     // 8 bit per pixel (no alpha)
  static const int UNCOMPRESSED_GRAY_ALPHA = 2;    // 8*2 bpp (2 channels)
  static const int UNCOMPRESSED_R5G6B5 = 3;        // 16 bpp
  static const int UNCOMPRESSED_R8G8B8 = 4;        // 24 bpp
  static const int UNCOMPRESSED_R5G5B5A1 = 5;      // 16 bpp (1 bit alpha)
  static const int UNCOMPRESSED_R4G4B4A4 = 6;      // 16 bpp (4 bit alpha)
  static const int UNCOMPRESSED_R8G8B8A8 = 7;      // 32 bpp
  static const int UNCOMPRESSED_R32 = 8;           // 32 bpp (1 channel - float)
  static const int UNCOMPRESSED_R32G32B32 = 9;     // 32*3 bpp (3 channels - float)
  static const int UNCOMPRESSED_R32G32B32A32 = 10; // 32*4 bpp (4 channels - float)
  static const int UNCOMPRESSED_R16 = 11;          // 16 bpp (1 channel - half float)
  static const int UNCOMPRESSED_R16G16B16 = 12;    // 16*3 bpp (3 channels - half float)
  static const int UNCOMPRESSED_R16G16B16A16 = 13; // 16*4 bpp (4 channels - half float)
  static const int COMPRESSED_DXT1_RGB = 14;       // 4 bpp (no alpha)
  static const int COMPRESSED_DXT1_RGBA = 15;      // 4 bpp (1 bit alpha)
  static const int COMPRESSED_DXT3_RGBA = 16;      // 8 bpp
  static const int COMPRESSED_DXT5_RGBA = 17;      // 8 bpp
  static const int COMPRESSED_ETC1_RGB = 18;       // 4 bpp
  static const int COMPRESSED_ETC2_RGB = 19;       // 4 bpp
  static const int COMPRESSED_ETC2_EAC_RGBA = 20;  // 8 bpp
  static const int COMPRESSED_PVRT_RGB = 21;       // 4 bpp
  static const int COMPRESSED_PVRT_RGBA = 22;      // 4 bpp
  static const int COMPRESSED_ASTC_4x4_RGBA = 23;  // 8 bpp
  static const int COMPRESSED_ASTC_8x8_RGBA = 24;  // 2 bpp
}

/// Texture parameters: filter mode
/// 
/// NOTE 1: Filtering considers mipmaps if available in the texture
/// 
/// NOTE 2: Filter is accordingly set for minification and magnification
enum TextureFilter {
  TEXTURE_FILTER_POINT,                   // No filter, just pixel approximation
  TEXTURE_FILTER_BILINEAR,                // Linear filtering
  TEXTURE_FILTER_TRILINEAR,               // Trilinear filtering (linear with mipmaps)
  TEXTURE_FILTER_ANISOTROPIC_4X,          // Anisotropic filtering 4x
  TEXTURE_FILTER_ANISOTROPIC_8X,          // Anisotropic filtering 8x
  TEXTURE_FILTER_ANISOTROPIC_16X,         // Anisotropic filtering 16x
}

/// Texture parameters: wrap mode
enum TextureWrap {
  TEXTURE_WRAP_REPEAT,                    // Repeats texture in tiled mode
  TEXTURE_WRAP_CLAMP,                     // Clamps texture to edge pixel in tiled mode
  TEXTURE_WRAP_MIRROR_REPEAT,             // Mirrors and repeats the texture in tiled mode
  TEXTURE_WRAP_MIRROR_CLAMP               // Mirrors and clamps to border the texture in tiled mode
}

/// Cubemap layouts
enum CubemapLayout {
  CUBEMAP_LAYOUT_AUTO_DETECT,             // Automatically detect layout type
  CUBEMAP_LAYOUT_LINE_VERTICAL,           // Layout is defined by a vertical line with faces
  CUBEMAP_LAYOUT_LINE_HORIZONTAL,         // Layout is defined by a horizontal line with faces
  CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR,     // Layout is defined by a 3x4 cross with cubemap faces
  CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE      // Layout is defined by a 4x3 cross with cubemap faces
}

/// Font type, defines generation method
enum FontType {
  FONT_DEFAULT,                           // Default font generation, anti-aliased
  FONT_BITMAP,                            // Bitmap font generation, no anti-aliasing
  FONT_SDF                                // SDF font generation, requires external shader
}

/// Color blending modes (pre-defined)
enum BlendMode {
  BLEND_ALPHA,                    // Blend textures considering alpha (default)
  BLEND_ADDITIVE,                 // Blend textures adding colors
  BLEND_MULTIPLIED,               // Blend textures multiplying colors
  BLEND_ADD_COLORS,               // Blend textures adding colors (alternative)
  BLEND_SUBTRACT_COLORS,          // Blend textures subtracting colors (alternative)
  BLEND_ALPHA_PREMULTIPLY,        // Blend premultiplied textures considering alpha
  BLEND_CUSTOM,                   // Blend textures using custom src/dst factors (use rlSetBlendFactors())
  BLEND_CUSTOM_SEPARATE           // Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
}

/// Gesture
/// 
/// NOTE: Provided as bit-wise flags to enable only desired gestures
abstract class Gesture {
  static const int GESTURE_NONE        = 0;         // No gesture
  static const int GESTURE_TAP         = 1;         // Tap gesture
  static const int GESTURE_DOUBLETAP   = 2;         // Double tap gesture
  static const int GESTURE_HOLD        = 4;         // Hold gesture
  static const int GESTURE_DRAG        = 8;         // Drag gesture
  static const int GESTURE_SWIPE_RIGHT = 16;        // Swipe right gesture
  static const int GESTURE_SWIPE_LEFT  = 32;        // Swipe left gesture
  static const int GESTURE_SWIPE_UP    = 64;        // Swipe up gesture
  static const int GESTURE_SWIPE_DOWN  = 128;       // Swipe down gesture
  static const int GESTURE_PINCH_IN    = 256;       // Pinch in gesture
  static const int GESTURE_PINCH_OUT   = 512;       // Pinch out gesture
}

/// Camera system modes
enum CameraMode {
  CUSTOM,                              // Camera custom, controlled by user (UpdateCamera() does nothing)
  FREE,                                // Camera free mode
  ORBITAL,                             // Camera orbital, around target, zoom supported
  FIRST_PERSON,                        // Camera first person
  THIRD_PERSON                         // Camera third person
}

/// Camera projection
enum CameraProjection {
  PERSPECTIVE,                        // Perspective projection
  ORTHOGRAPHIC                        // Orthographic projection
}

// N-patch layout
enum NPatchLayout {
  NPATCH_NINE_PATCH,                   // Npatch layout: 3x3 tiles
  NPATCH_THREE_PATCH_VERTICAL,         // Npatch layout: 1x3 tiles
  NPATCH_THREE_PATCH_HORIZONTAL        // Npatch layout: 3x1 tiles
}

// Callbacks to hook some internal functions
// WARNING: These callbacks are intended for advanced users
// typedef void (*TraceLogCallback)(int logLevel, const char *text, va_list args);  // Logging: Redirect trace log messages
// typedef unsigned char *(*LoadFileDataCallback)(const char *fileName, int *dataSize);    // FileIO: Load binary data
// typedef bool (*SaveFileDataCallback)(const char *fileName, void *data, int dataSize);   // FileIO: Save binary data
// typedef char *(*LoadFileTextCallback)(const char *fileName);            // FileIO: Load text data
// typedef bool (*SaveFileTextCallback)(const char *fileName, const char *text); // FileIO: Save text data

//------------------------------------------------------------------------------------
// Global Variables Definition
//------------------------------------------------------------------------------------
// It's lonely here...


//------------------------------------------------------------------------------------
// Initializing Dynamic Library
//------------------------------------------------------------------------------------

final DynamicLibrary _dylib = _load();

DynamicLibrary _load()
{
  if (Platform.isWindows) return DynamicLibrary.open('../bin/libraylib.dll');
  if (Platform.isLinux) return DynamicLibrary.open('libraylib.so');
  if (Platform.isMacOS) return DynamicLibrary.open('libraylib.dylib');

  throw UnsupportedError("Operational system not supported");
}

//------------------------------------------------------------------------------------
// Window and Graphics Device Functions (Module: core)
//------------------------------------------------------------------------------------

typedef _InitWindowRay  = Void Function(Int32, Int32, Pointer<Utf8>);
typedef _InitWindowDart = void Function(int, int, Pointer<Utf8>);
final _initWindow = _dylib.lookupFunction<_InitWindowRay, _InitWindowDart>('InitWindow');

typedef _CloseWindowRay = Void Function();
typedef _CloseWindowDart = void Function();
final _closeWindow = _dylib.lookupFunction<_CloseWindowRay, _CloseWindowDart>('CloseWindow');

typedef _WindowShouldCloseRay = Bool Function();
typedef _WindowShouldCloseDart = bool Function();
final _windowShouldClose = _dylib.lookupFunction<_WindowShouldCloseRay, _WindowShouldCloseDart>('WindowShouldClose');

typedef _IsWindowReadyRay = Bool Function();
typedef _IsWindowReadyDart = bool Function();
final _isWindowReady = _dylib.lookupFunction<_IsWindowReadyRay, _IsWindowReadyDart>('IsWindowReady');

typedef _IsFullScreenRay = Bool Function();
typedef _IsFullScreenDart = bool Function();
final _isFullScreen = _dylib.lookupFunction<_IsFullScreenRay, _IsFullScreenDart>('IsWindowFullscreen');

typedef _IsHiddenRay = Bool Function();
typedef _IsHiddenDart = bool Function();
final _isHidden = _dylib.lookupFunction<_IsHiddenRay, _IsHiddenDart>('IsWindowHidden');

typedef _IsMinimizedRay = Bool Function();
typedef _IsMinimizedDart = bool Function();
final _isMinimized = _dylib.lookupFunction<_IsMinimizedRay, _IsMinimizedDart>('IsWindowMinimized');

typedef _IsMaximizedRay = Bool Function();
typedef _IsMaximizedDart = bool Function();
final _isMaximized = _dylib.lookupFunction<_IsMaximizedRay, _IsMaximizedDart>('IsWindowMaximized');

typedef _IsFocusedRay = Bool Function();
typedef _IsFocusedDart = bool Function();
final _isFocused = _dylib.lookupFunction<_IsFocusedRay, _IsFocusedDart>('symbolName');

typedef _IsWindowResizedRay = Bool Function();
typedef _IsWindowResizedDart = bool Function();
final _isResized = _dylib.lookupFunction<_IsWindowResizedRay, _IsWindowResizedDart>('IsWindowResized');

typedef _IsWindowStateRay = Bool Function(Uint32);
typedef _IsWindowStateDart = bool Function(int);
final _isWindowState = _dylib.lookupFunction<_IsWindowStateRay, _IsWindowStateDart>('IsWindowState');
//ConfigFlags

typedef _SetWindowStateRay = Void Function(Uint32);
typedef _SetWindowStateDart = void Function(int);
final _setWindowState = _dylib.lookupFunction<_SetWindowStateRay, _SetWindowStateDart>('SetWindowState');

typedef _ClearWindowStateRay = Void Function(Uint32);
typedef _ClearWindowStateDart = void Function(int);
final _clearWindowState = _dylib.lookupFunction<_ClearWindowStateRay, _ClearWindowStateDart>('ClearWindowState');

typedef _ToggleFullscreenRay = Void Function();
typedef _ToggleFullscreenDart = void Function();
final _toggleFullscreen = _dylib.lookupFunction<_ToggleFullscreenRay, _ToggleFullscreenDart>('ToggleFullscreen');

typedef _ToggleBorderlessWindowedRay = Void Function();
typedef _ToggleBorderlessWindowedDart = void Function();
final _toggleBorderlessWindowed = _dylib.lookupFunction<_ToggleBorderlessWindowedRay, _ToggleBorderlessWindowedDart>('ToggleBorderlessWindowed');

typedef _MaximizeWindowRay = Void Function();
typedef _MaximizeWindowDart = void Function();
final _maximizeWindow = _dylib.lookupFunction<_MaximizeWindowRay, _MaximizeWindowDart>('MaximizeWindow');

typedef _MinimizeWindowRay = Void Function();
typedef _MinimizeWindowDart = void Function();
final _minimizeWindow = _dylib.lookupFunction<_MinimizeWindowRay, _MinimizeWindowDart>('MinimizeWindow');

typedef _RestoreWindowRay = Void Function();
typedef _RestoreWindowDart = void Function();
final _restoreWindow = _dylib.lookupFunction<_RestoreWindowRay, _RestoreWindowDart>('RestoreWindow');

typedef _SetWindowIconRay = Void Function(_Image);
typedef _SetWindowIconDart = void Function(_Image);
final _setWindowIcon = _dylib.lookupFunction<_SetWindowIconRay, _SetWindowIconDart>('SetWindowIcon');

typedef _SetWindowIconsRay = Void Function(Pointer<_Image>, Int32);
typedef _SetWindowIconsDart = void Function(Pointer<_Image>, int);
final _setWindowIcons = _dylib.lookupFunction<_SetWindowIconsRay, _SetWindowIconsDart>('SetWindowIcons');

typedef _SetWindowTitleRay = Void Function(Pointer<Utf8>);
typedef _SetWindowTitleDart = void Function(Pointer<Utf8>);
final _setWindowTitle = _dylib.lookupFunction<_SetWindowTitleRay, _SetWindowTitleDart>('SetWindowTitle');

typedef _SetWindowPositionRay = Void Function(Int32, Int32);
typedef _SetWindowPositionDart = void Function(int, int);
final _setWindowPosition = _dylib.lookupFunction<_SetWindowPositionRay, _SetWindowPositionDart>('SetWindowPosition');

typedef _SetWindowMonitorRay = Void Function(Int32);
typedef _SetWindowMonitorDart = void Function(int);
final _setWindowMonitor = _dylib.lookupFunction<_SetWindowMonitorRay, _SetWindowMonitorDart>('SetWindowMonitor');

typedef _SetWindowMinSizeRay = Void Function(Int32, Int32);
typedef _SetWindowMinSizeDart = void Function(int, int);
final _setWindowMinSize = _dylib.lookupFunction<_SetWindowMinSizeRay, _SetWindowMinSizeDart>('SetWindowMinSize');

typedef _SetWindowMaxSizeRay = Void Function(Int32, Int32);
typedef _SetWindowMaxSizeDart = void Function(int, int);
final _setWindowMaxSize = _dylib.lookupFunction<_SetWindowMaxSizeRay, _SetWindowMaxSizeDart>('SetWindowMaxSize');

typedef _SetWindowSizeRay = Void Function(Int32, Int32);
typedef _SetWindowSizeDart = void Function(int, int);
final _setWindowSize = _dylib.lookupFunction<_SetWindowSizeRay, _SetWindowSizeDart>('SetWindowSize');

typedef _SetWindowOpacityRay = Void Function(Float);
typedef _SetWindowOpacityDart = void Function(double);
final _setWindowOpacity = _dylib.lookupFunction<_SetWindowOpacityRay, _SetWindowOpacityDart>('SetWindowOpacity');

typedef _SetWindowFocusedRay = Void Function();
typedef _SetWindowFocusedDart = void Function();
final _setWindowFocused = _dylib.lookupFunction<_SetWindowFocusedRay, _SetWindowFocusedDart>('SetWindowFocused');

typedef _GetWindowHandleRay = Pointer<Void> Function();
typedef _GetWindowHandleDart = Pointer<Void> Function();
final _getWindowHandle = _dylib.lookupFunction<_GetWindowHandleRay, _GetWindowHandleDart>('GetWindowHandle');

typedef _GetScreenWidthRay = Int32 Function();
typedef _GetScreenWidthDart = int Function();
final _getScreenWidth = _dylib.lookupFunction<_GetScreenWidthRay, _GetScreenWidthDart>('GetScreenWidth');

typedef _GetScreenHeightRay = Int32 Function();
typedef _GetScreenHeightDart = int Function();
final _getScreenHeight = _dylib.lookupFunction<_GetScreenHeightRay, _GetScreenHeightDart>('GetScreenHeight');

typedef _GetRenderWidthRay = Int32 Function();
typedef _GetRenderWidthDart = int Function();
final _getRenderWidth = _dylib.lookupFunction<_GetRenderWidthRay, _GetRenderWidthDart>('GetRenderWidth');

typedef _GetRenderHeightRay = Int32 Function();
typedef _GetRenderHeightDart = int Function();
final _getRenderHeight = _dylib.lookupFunction<_GetRenderHeightRay, _GetRenderHeightDart>('GetRenderHeight');

typedef _GetMonitorCountRay = Int32 Function();
typedef _GetMonitorCountDart = int Function();
final _getMonitorCount = _dylib.lookupFunction<_GetMonitorCountRay, _GetMonitorCountDart>('GetMonitorCount');

typedef _GetCurrentMonitorRay = Int32 Function();
typedef _GetCurrentMonitorDart = int Function();
final _getCurrentMonitor = _dylib.lookupFunction<_GetCurrentMonitorRay, _GetCurrentMonitorDart>('GetCurrentMonitor');

typedef _GetMonitorPositionRay = _Vector2 Function(Int32);
typedef _GetMonitorPositionDart = _Vector2 Function(int);
final _getMonitorPosition = _dylib.lookupFunction<_GetMonitorPositionRay, _GetMonitorPositionDart>('GetMonitorPosition');

typedef _GetMonitorWidthRay = Int32 Function(Int32);
typedef _GetMonitorWidthDart = int Function(int);
final _getMonitorWidth = _dylib.lookupFunction<_GetMonitorWidthRay, _GetMonitorWidthDart>('GetMonitorWidth');

typedef _GetMonitorHeightRay = Int32 Function(Int32);
typedef _GetMonitorHeightDart = int Function(int);
final _getMonitorHeight = _dylib.lookupFunction<_GetMonitorHeightRay, _GetMonitorHeightDart>('GetMonitorHeight');

typedef _GetMonitorPhysicalWidthRay = Int32 Function(Int32);
typedef _GetMonitorPhysicalWidthDart = int Function(int);
final _getMonitorPhysicalWidth = _dylib.lookupFunction<_GetMonitorPhysicalWidthRay, _GetMonitorPhysicalWidthDart>('GetMonitorPhysicalWidth');

typedef _GetMonitorPhysicalHeightRay = Int32 Function(Int32);
typedef _GetMonitorPhysicalHeightDart = int Function(int);
final _getMonitorPhysicalHeight = _dylib.lookupFunction<_GetMonitorPhysicalHeightRay, _GetMonitorPhysicalHeightDart>('GetMonitorPhysicalHeight');

typedef _GetMonitorRefreshRateRay = Int32 Function(Int32);
typedef _GetMonitorRefreshRateDart = int Function(int);
final _getMonitorRefreshRate = _dylib.lookupFunction<_GetMonitorRefreshRateRay, _GetMonitorRefreshRateDart>('GetMonitorRefreshRate');

typedef _GetWindowPositionRay = _Vector2 Function();
typedef _GetWindowPositionDart = _Vector2 Function();
final _getWindowPosition = _dylib.lookupFunction<_GetWindowPositionRay, _GetWindowPositionDart>('GetWindowPosition');

typedef _GetWindowScaleDPIRay = _Vector2 Function();
typedef _GetWindowScaleDPIDart = _Vector2 Function();
final _getWindowScaleDPI = _dylib.lookupFunction<_GetWindowScaleDPIRay, _GetWindowScaleDPIDart>('GetWindowScaleDPI');

typedef _GetMonitorNameRay = Pointer<Utf8> Function(Int);
typedef _GetMonitorNameDart = Pointer<Utf8> Function(int);
final _getMonitorName = _dylib.lookupFunction<_GetMonitorNameRay, _GetMonitorNameDart>('GetMonitorName');

typedef _SetClipboardTextRay = Void Function(Pointer<Utf8>);
typedef _SetClipboardTextDart = void Function(Pointer<Utf8>);
final _setClipboardText = _dylib.lookupFunction<_SetClipboardTextRay, _SetClipboardTextDart>('SetClipboardText');

typedef _GetClipboardTextRay = Pointer<Utf8> Function();
typedef _GetClipboardTextDart = Pointer<Utf8> Function();
final _getClipboardText = _dylib.lookupFunction<_GetClipboardTextRay, _GetClipboardTextDart>('SetClipboardText');

typedef _GetClipboardImageRay = _Image Function();
typedef _GetClipboardImageDart = _Image Function();
final _getClipboardImage = _dylib.lookupFunction<_GetClipboardImageRay, _GetClipboardImageDart>('GetClipboardImage');

typedef _EnableEventWaitingRay = Void Function();
typedef _EnableEventWaitingDart = void Function();
final _enableEventWaiting = _dylib.lookupFunction<_EnableEventWaitingRay, _EnableEventWaitingDart>('EnableEventWaiting');

typedef _DisableEventWaitingRay = Void Function();
typedef _DisableEventWaitingDart = void Function();
final _disableEventWaiting = _dylib.lookupFunction<_DisableEventWaitingRay, _DisableEventWaitingDart>('DisableEventWaiting');

typedef _TakeScreenshotRay = Void Function(Pointer<Utf8>);
typedef _TakeScreenshotDart = void Function(Pointer<Utf8>);
final _takeScreenshot = _dylib.lookupFunction<_TakeScreenshotRay, _TakeScreenshotDart>('TakeScreenshot');

typedef _SetConfigFlagsRay = Void Function(Uint32);
typedef _SetConfigFlagsDart = void Function(int);
final _setConfigFlags = _dylib.lookupFunction<_SetConfigFlagsRay, _SetConfigFlagsDart>('SetConfigFlags');

//TODO: Open URL
/*
typedef _OpenURLRay = Void Function(Pointer<Utf8>);
typedef _OpenURLDart = void Function(Pointer<Utf8>);
final _openURL = _dylib.lookupFunction<_OpenURLRay, _OpenURLDart>('OpenURL');
*/

//------------------------------------------------------------------------------------
//                                   Cursor
//------------------------------------------------------------------------------------

typedef _ShowCursorRay = Void Function();
typedef _ShowCursorDart = void Function();
final _showCursor = _dylib.lookupFunction<_ShowCursorRay, _ShowCursorDart>('ShowCursor');

typedef _HideCursorRay = Void Function();
typedef _HideCursorDart = void Function();
final _hideCursor = _dylib.lookupFunction<_HideCursorRay, _HideCursorDart>('HideCursor');

typedef _IsCursorHiddenRay = Bool Function();
typedef _IsCursorHiddenDart = bool Function();
final _isCursorHidden = _dylib.lookupFunction<_IsCursorHiddenRay, _IsCursorHiddenDart>('IsCursorHidden');

typedef _EnableCursorRay = Void Function();
typedef _EnableCursorDart = void Function();
final _enableCursor = _dylib.lookupFunction<_EnableCursorRay, _EnableCursorDart>('EnableCursor');

typedef _DisableCursorRay = Void Function();
typedef _DisableCursorDart = void Function();
final _disableCursor = _dylib.lookupFunction<_DisableCursorRay, _DisableCursorDart>('DisableCursor');

typedef _IsCursorOnScreenRay = Bool Function();
typedef _IsCursorOnScreenDart = bool Function();
final _isCursorOnScreen = _dylib.lookupFunction<_IsCursorOnScreenRay, _IsCursorOnScreenDart>('IsCursorOnScreen');

//------------------------------------------------------------------------------------
//                                   Keyboard
//------------------------------------------------------------------------------------

typedef _IsKeyPressedRay = Bool Function(Int32);
typedef _IsKeyPressedDart = bool Function(int);
final _isKeyPressed = _dylib.lookupFunction<_IsKeyPressedRay, _IsKeyPressedDart>('IsKeyPressed');

typedef _IsKeyPressedRepeatRay = Bool Function(Int32);
typedef _IsKeyPressedRepeatDart = bool Function(int);
final _isKeyPressedRepeat = _dylib.lookupFunction<_IsKeyPressedRepeatRay, _IsKeyPressedRepeatDart>('IsKeyPressedRepeat');

typedef _IsKeyDownRay = Bool Function(Int32);
typedef _IsKeyDownDart = bool Function(int);
final _isKeyDown = _dylib.lookupFunction<_IsKeyDownRay, _IsKeyDownDart>('IsKeyDown');

typedef _IsKeyReleasedRay = Bool Function(Int32);
typedef _IsKeyReleasedDart = bool Function(int);
final _isKeyReleased = _dylib.lookupFunction<_IsKeyReleasedRay, _IsKeyReleasedDart>('IsKeyReleased');

typedef _IsKeyUpRay = Bool Function(Int32);
typedef _IsKeyUpDart = bool Function(int);
final _isKeyUp = _dylib.lookupFunction<_IsKeyUpRay, _IsKeyUpDart>('IsKeyUp');

typedef _GetKeyPressedRay = Int32 Function();
typedef _GetKeyPressedDart = int Function();
final _getKeyPressed = _dylib.lookupFunction<_GetKeyPressedRay, _GetKeyPressedDart>('GetKeyPressed');

typedef _GetCharPressedRay = Int32 Function();
typedef _GetCharPressedDart = int Function();
final _getCharPressed = _dylib.lookupFunction<_GetCharPressedRay, _GetCharPressedDart>('GetCharPressed');

typedef _GetKeyNameRay = Pointer<Utf8> Function(); 
typedef _GetKeyNameDart = Pointer<Utf8> Function();
final _getKeyName = _dylib.lookupFunction<_GetKeyNameRay, _GetKeyNameDart>('GetKeyName');

typedef _SetExitKeyRay = Void Function(Int32);
typedef _SetExitKeyDart = void Function(int);
final _setExitKey = _dylib.lookupFunction<_SetExitKeyRay, _SetExitKeyDart>('SetExitKey');

//------------------------------------------------------------------------------------
//                                   Mouse
//------------------------------------------------------------------------------------

typedef _IsMouseButtonPressedRay = Bool Function(Int32);
typedef _IsMouseButtonPressedDart = bool Function(int);
final _isMouseButtonPressed = _dylib.lookupFunction<_IsMouseButtonPressedRay, _IsMouseButtonPressedDart>('IsMouseButtonPressed');

typedef _IsMouseButtonDownRay = Bool Function(Int32);
typedef _IsMouseButtonDownDart = bool Function(int);
final _isMouseButtonDown = _dylib.lookupFunction<_IsMouseButtonDownRay, _IsMouseButtonDownDart>('IsMouseButtonDown');

typedef _IsMouseButtonReleasedRay = Bool Function(Int32);
typedef _IsMouseButtonReleasedDart = bool Function(int);
final _isMouseButtonReleased = _dylib.lookupFunction<_IsMouseButtonReleasedRay, _IsMouseButtonReleasedDart>('IsMouseButtonReleased');

typedef _IsMouseButtonUpRay = Bool Function(Int32);
typedef _IsMouseButtonUpDart = bool Function(int);
final _isMouseButtonUp = _dylib.lookupFunction<_IsMouseButtonUpRay, _IsMouseButtonUpDart>('IsMouseButtonUp');

typedef _GetMouseXRay = Int32 Function();
typedef _GetMouseXDart = int Function();
final _getMouseX = _dylib.lookupFunction<_GetMouseXRay, _GetMouseXDart>('GetMouseX');

typedef _GetMouseYRay = Int32 Function();
typedef _GetMouseYDart = int Function();
final _getMouseY = _dylib.lookupFunction<_GetMouseYRay, _GetMouseYDart>('GetMouseY');

typedef _GetMousePositionRay = _Vector2 Function();
typedef _GetMousePositionDart = _Vector2 Function();
final _getMousePosition = _dylib.lookupFunction<_GetMousePositionRay, _GetMousePositionDart>('GetMousePosition');

typedef _GetMouseDeltaRay = _Vector2 Function();
typedef _GetMouseDeltaDart = _Vector2 Function();
final _getMouseDelta = _dylib.lookupFunction<_GetMouseDeltaRay, _GetMouseDeltaDart>('GetMouseDelta');

typedef _SetMousePositionRay = Void Function(Int32, Int32);
typedef _SetMousePositionDart = void Function(int, int);
final _setMousePosition = _dylib.lookupFunction<_SetMousePositionRay, _SetMousePositionDart>('SetMousePosition');

typedef _SetMouseOffsetRay = Void Function(Int32, Int32);
typedef _SetMouseOffsetDart = void Function(int, int);
final _setMouseOffset = _dylib.lookupFunction<_SetMouseOffsetRay, _SetMouseOffsetDart>('SetMouseOffset');

typedef _SetMouseScaleRay = Void Function(Float, Float);
typedef _SetMouseScaleDart = void Function(double, double);
final _setMouseScale = _dylib.lookupFunction<_SetMouseScaleRay, _SetMouseScaleDart>('SetMouseScale');

typedef _GetMouseWheelMoveRay = Float Function();
typedef _GetMouseWheelMoveDart = double Function();
final _getMouseWheelMove = _dylib.lookupFunction<_GetMouseWheelMoveRay, _GetMouseWheelMoveDart>('GetMouseWheelMove');

typedef _GetMouseWheelMoveVRay = _Vector2 Function();
typedef _GetMouseWheelMoveVDart = _Vector2 Function();
final _getMouseWheelMoveV = _dylib.lookupFunction<_GetMouseWheelMoveVRay, _GetMouseWheelMoveVDart>('GetMouseWheelMoveV');

typedef _SetMouseCursorRay = Void Function(Int32);
typedef _SetMouseCursorDart = void Function(int);
final _setMouseCursor = _dylib.lookupFunction<_SetMouseCursorRay, _SetMouseCursorDart>('SetMouseCursor');

//------------------------------------------------------------------------------------
//                                   Touch
//------------------------------------------------------------------------------------

typedef _GetTouchXRay = Int32 Function();
typedef _GetTouchXDart = int Function();
final _getTouchX = _dylib.lookupFunction<_GetTouchXRay, _GetTouchXDart>('GetTouchX');

typedef _GetTouchYRay = Int32 Function();
typedef _GetTouchYDart = int Function();
final _getTouchY = _dylib.lookupFunction<_GetTouchYRay, _GetTouchYDart>('GetTouchY');

typedef _GetTouchPositionRay = _Vector2 Function(Int32);
typedef _GetTouchPositionDart = _Vector2 Function(int);
final _getTouchPosition = _dylib.lookupFunction<_GetTouchPositionRay, _GetTouchPositionDart>('GetTouchPosition');

typedef _GetTouchPointIdRay = Int32 Function(Int32);
typedef _GetTouchPointIdDart = int Function(int);
final _getTouchPointId = _dylib.lookupFunction<_GetTouchPointIdRay, _GetTouchPointIdDart>('GetTouchPointId');

typedef _GetTouchPointCountRay = Int32 Function();
typedef _GetTouchPointCountDart = int Function();
final _getTouchPointCount = _dylib.lookupFunction<_GetTouchPointCountRay, _GetTouchPointCountDart>('GetTouchPointCount');

//------------------------------------------------------------------------------------
//                                   Gesture
//------------------------------------------------------------------------------------

typedef _SetGesturesEnabledRay = Void Function(Uint32);
typedef _SetGesturesEnabledDart = void Function(int);
final _setGesturesEnabled = _dylib.lookupFunction<_SetGesturesEnabledRay, _SetGesturesEnabledDart>('SetGesturesEnabled');

typedef _IsGestureDetectedRay = Bool Function(Uint32);
typedef _IsGestureDetectedDart = bool Function(int);
final _isGestureDetected = _dylib.lookupFunction<_IsGestureDetectedRay, _IsGestureDetectedDart>('IsGestureDetected');

typedef _GetGestureDetectedRay = Int32 Function();
typedef _GetGestureDetectedDart = int Function();
final _getGestureDetected = _dylib.lookupFunction<_GetGestureDetectedRay, _GetGestureDetectedDart>('GetGestureDetected');

typedef _GetGestureHoldDurationRay = Float Function();
typedef _GetGestureHoldDurationDart = double Function();
final _getGestureHoldDuration = _dylib.lookupFunction<_GetGestureHoldDurationRay, _GetGestureHoldDurationDart>('GetGestureHoldDuration');

typedef _GetGestureDragVectorRay = _Vector2 Function();
typedef _GetGestureDragVectorDart = _Vector2 Function();
final _getGestureDragVector = _dylib.lookupFunction<_GetGestureDragVectorRay, _GetGestureDragVectorDart>('GetGestureDragVector');

typedef _GetGestureDragAngleRay = Float Function();
typedef _GetGestureDragAngleDart = double Function();
final _getGestureDragAngle = _dylib.lookupFunction<_GetGestureDragAngleRay, _GetGestureDragAngleDart>('GetGestureDragAngle');

typedef _GetGesturePinchVectorRay = _Vector2 Function();
typedef _GetGesturePinchVectorDart = _Vector2 Function();
final _getGesturePinchVector = _dylib.lookupFunction<_GetGesturePinchVectorRay, _GetGesturePinchVectorDart>('GetGesturePinchVector');

typedef _GetGesturePinchAngleRay = Float Function();
typedef _GetGesturePinchAngleDart = double Function();
final _getGesturePinchAngle = _dylib.lookupFunction<_GetGesturePinchAngleRay, _GetGesturePinchAngleDart>('GetGesturePinchAngle');

//------------------------------------------------------------------------------------
//                                   Gamepad
//------------------------------------------------------------------------------------

typedef _IsGamepadAvailableRay = Bool Function(Int32);
typedef _IsGamepadAvailableDart = bool Function(int);
final _isGamepadAvailable = _dylib.lookupFunction<_IsGamepadAvailableRay, _IsGamepadAvailableDart>('IsGamepadAvailable');

typedef _GetGamepadNameRay = Pointer<Utf8> Function(Int32);
typedef _GetGamepadNameDart = Pointer<Utf8> Function(int);
final _getGamepadName = _dylib.lookupFunction<_GetGamepadNameRay, _GetGamepadNameDart>('GetGamepadName');

typedef _IsGamepadButtonPressedRay = Bool Function(Int32, Int32);
typedef _IsGamepadButtonPressedDart = bool Function(int, int);
final _isGamepadButtonPressed = _dylib.lookupFunction<_IsGamepadButtonPressedRay, _IsGamepadButtonPressedDart>('IsGamepadButtonPressed');

typedef _IsGamepadButtonDownRay = Bool Function(Int32, Int32);
typedef _IsGamepadButtonDownDart = bool Function(int, int);
final _isGamepadButtonDown = _dylib.lookupFunction<_IsGamepadButtonDownRay, _IsGamepadButtonDownDart>('IsGamepadButtonDown');

typedef _IsGamepadButtonReleasedRay = Bool Function(Int32, Int32);
typedef _IsGamepadButtonReleasedDart = bool Function(int, int);
final _isGamepadButtonReleased = _dylib.lookupFunction<_IsGamepadButtonReleasedRay, _IsGamepadButtonReleasedDart>('IsGamepadButtonReleased');

typedef _IsGamepadButtonUpRay = Bool Function(Int32, Int32);
typedef _IsGamepadButtonUpDart = bool Function(int, int);
final _isGamepadButtonUp = _dylib.lookupFunction<_IsGamepadButtonUpRay, _IsGamepadButtonUpDart>('IsGamepadButtonUp');

typedef _GetGamepadButtonPressedRay = Int32 Function();
typedef _GetGamepadButtonPressedDart = int Function();
final _getGamepadButtonPressed = _dylib.lookupFunction<_GetGamepadButtonPressedRay, _GetGamepadButtonPressedDart>('GetGamepadButtonPressed');

typedef _GetGamepadAxisCountRay = Int32 Function(Int32);
typedef _GetGamepadAxisCountDart = int Function(int);
final _getGamepadAxisCount = _dylib.lookupFunction<_GetGamepadAxisCountRay, _GetGamepadAxisCountDart>('GetGamepadAxisCount');

typedef _GetGamepadAxisMovementRay = Float Function(Int32, Int32);
typedef _GetGamepadAxisMovementDart = double Function(int, int);
final _getGamepadAxisMovement = _dylib.lookupFunction<_GetGamepadAxisMovementRay, _GetGamepadAxisMovementDart>('GetGamepadAxisMovement');

typedef _SetGamepadMappingsRay = Int32 Function(Pointer<Utf8>);
typedef _SetGamepadMappingsDart = int Function(Pointer<Utf8>);
final _setGamepadMappings = _dylib.lookupFunction<_SetGamepadMappingsRay, _SetGamepadMappingsDart>('SetGamepadMappings');

typedef _SetGamepadVibrationRay = Void Function(Int32, Float, Float, Float);
typedef _SetGamepadVibrationDart = void Function(int, double, double, double);
final _setGamepadVibration = _dylib.lookupFunction<_SetGamepadVibrationRay, _SetGamepadVibrationDart>('SetGamepadVibration');


//------------------------------------------------------------------------------------
//                                   Frame
//------------------------------------------------------------------------------------

typedef _SetTargetFPSRay = Void Function(Int32);
typedef _SetTargetFPSDart = void Function(int);
final _setTargetFPS = _dylib.lookupFunction<_SetTargetFPSRay, _SetTargetFPSDart>('SetTargetFPS');

typedef _GetFrameTimeRay = Float Function();
typedef _GetFrameTimeDart = double Function();
final _getFrameTime = _dylib.lookupFunction<_GetFrameTimeRay, _GetFrameTimeDart>('GetFrameTime');

typedef _GetTimeRay = Double Function();
typedef _GetTimeDart = double Function();
final _getTime = _dylib.lookupFunction<_GetTimeRay, _GetTimeDart>('GetTime');

typedef _GetFPSRay = Int32 Function();
typedef _GetFPSDart = int Function();
final _getFPS = _dylib.lookupFunction<_GetFPSRay, _GetFPSDart>('GetFPS');

//------------------------------------------------------------------------------------
//                                   Image
//------------------------------------------------------------------------------------

typedef _LoadImageRay = _Image Function(Pointer<Utf8>);
typedef _LoadImageDart = _Image Function(Pointer<Utf8>);
final _loadImage = _dylib.lookupFunction<_LoadImageRay, _LoadImageDart>('LoadImage');

typedef _LoadImageRawRay = _Image Function(Pointer<Utf8>, Int32, Int32, Int32, Int32);
typedef _LoadImageRawDart = _Image Function(Pointer<Utf8>, int, int, int, int);
final _loadImageRaw = _dylib.lookupFunction<_LoadImageRawRay, _LoadImageRawDart>('LoadImageRaw');

typedef _LoadImageAnimRay = _Image Function(Pointer<Utf8>, Pointer<Int32>);
typedef _LoadImageAnimDart = _Image Function(Pointer<Utf8>, Pointer<Int32>);
final _loadImageAnim = _dylib.lookupFunction<_LoadImageAnimRay, _LoadImageAnimDart>('LoadImageAnim');

typedef _LoadImageAnimFromMemoryRay = _Image Function(Pointer<Utf8>, Pointer<Uint8>, Int32, Pointer<Int32>);
typedef _LoadImageAnimFromMemoryDart = _Image Function(Pointer<Utf8>, Pointer<Uint8>, int, Pointer<Int32>);
final _loadImageAnimFromMemory = _dylib.lookupFunction<_LoadImageAnimFromMemoryRay, _LoadImageAnimFromMemoryDart>('LoadImageAnimFromMemory');

typedef _LoadImageFromMemoryRay = _Image Function(Pointer<Utf8>, Pointer<Uint8>, Int32);
typedef _LoadImageFromMemoryDart = _Image Function(Pointer<Utf8>, Pointer<Uint8>, int);
final _loadImageFromMemory = _dylib.lookupFunction<_LoadImageFromMemoryRay, _LoadImageFromMemoryDart>('LoadImageFromMemory');

typedef _LoadImageFromTextureRay = _Image Function(_Texture2D);
typedef _LoadImageFromTextureDart = _Image Function(_Texture2D);
final _loadImageFromTexture = _dylib.lookupFunction<_LoadImageFromTextureRay, _LoadImageFromTextureDart>('LoadImageFromTexture');

typedef _LoadImageFromScreenRay = _Image Function();
typedef _LoadImageFromScreenDart = _Image Function();
final _loadImageFromScreen = _dylib.lookupFunction<_LoadImageFromScreenRay, _LoadImageFromScreenDart>('LoadImageFromScreen');

typedef _IsImageValidRay = Bool Function(_Image);
typedef _IsImageValidDart = bool Function(_Image);
final _isImageValid = _dylib.lookupFunction<_IsImageValidRay, _IsImageValidDart>('IsImageValid');

typedef _UnloadImageRay = Void Function(_Image);
typedef _UnloadImageDart = void Function(_Image);
final _unloadImage = _dylib.lookupFunction<_UnloadImageRay, _UnloadImageDart>('UnloadImage');

typedef _ExportImageRay = Bool Function(_Image, Pointer<Utf8>);
typedef _ExportImageDart = bool Function(_Image, Pointer<Utf8>);
final _exportImage = _dylib.lookupFunction<_ExportImageRay, _ExportImageDart>('ExportImage');

typedef _ExportImageToMemoryRay = Pointer<Uint8> Function(_Image, Pointer<Utf8>, Pointer<Int32>);
typedef _ExportImageToMemoryDart = Pointer<Uint8> Function(_Image, Pointer<Utf8>, Pointer<Int32>);
final _exportImageToMemory = _dylib.lookupFunction<_ExportImageToMemoryRay, _ExportImageToMemoryDart>('ExportImageToMemory');

typedef _ExportImageAsCodeRay = Bool Function(_Image, Pointer<Utf8>);
typedef _ExportImageAsCodeDart = bool Function(_Image, Pointer<Utf8>);
final _exportImageAsCode = _dylib.lookupFunction<_ExportImageAsCodeRay, _ExportImageAsCodeDart>('ExportImageAsCode');

typedef _GenImageColorRay = _Image Function(Int32, Int32, _Color);
typedef _GenImageColorDart = _Image Function(int, int, _Color);
final _genImageColor = _dylib.lookupFunction<_GenImageColorRay, _GenImageColorDart>('GenImageColor');

typedef _GenImageGradientLinearRay = _Image Function(Int32, Int32, Int32, _Color, _Color);
typedef _GenImageGradientLinearDart = _Image Function(int, int, int, _Color, _Color);
final _genImageGradientLinear = _dylib.lookupFunction<_GenImageGradientLinearRay, _GenImageGradientLinearDart>('GenImageGradientLinear');

typedef _GenImageGradientRadialRay = _Image Function(Int32, Int32, Float, _Color, _Color);
typedef _GenImageGradientRadialDart = _Image Function(int, int, double, _Color, _Color);
final _genImageGradientRadial = _dylib.lookupFunction<_GenImageGradientRadialRay, _GenImageGradientRadialDart>('GenImageGradientRadial');

typedef _GenImageGradientSquareRay = _Image Function(Int32, Int32, Float, _Color, _Color);
typedef _GenImageGradientSquareDart = _Image Function(int, int, double, _Color, _Color);
final _genImageGradientSquare = _dylib.lookupFunction<_GenImageGradientSquareRay, _GenImageGradientSquareDart>('GenImageGradientSquare');

typedef _GenImageCheckedRay = _Image Function(Int32, Int32, Int32, Int32, _Color, _Color);
typedef _GenImageCheckedDart = _Image Function(int, int, int, int, _Color, _Color);
final _genImageChecked = _dylib.lookupFunction<_GenImageCheckedRay, _GenImageCheckedDart>('GenImageChecked');

typedef _GenImageWhiteNoiseRay = _Image Function(Int32, Int32, Float);
typedef _GenImageWhiteNoiseDart = _Image Function(int, int, double);
final _genImageWhiteNoise = _dylib.lookupFunction<_GenImageWhiteNoiseRay, _GenImageWhiteNoiseDart>('GenImageWhiteNoise');

typedef _GenImagePerlinNoiseRay = _Image Function(Int32, Int32, Int32, Int32, Float);
typedef _GenImagePerlinNoiseDart = _Image Function(int, int, int, int, double);
final _genImagePerlinNoise = _dylib.lookupFunction<_GenImagePerlinNoiseRay, _GenImagePerlinNoiseDart>('GenImagePerlinNoise');

typedef _GenImageCellularRay = _Image Function(Int32, Int32, Int32);
typedef _GenImageCellularDart = _Image Function(int, int, int);
final _genImageCellular = _dylib.lookupFunction<_GenImageCellularRay, _GenImageCellularDart>('GenImageCellular');

typedef _GenImageTextRay = _Image Function(Int32, Int32, Pointer<Utf8>);
typedef _GenImageTextDart = _Image Function(int, int, Pointer<Utf8>);
final _genImageText = _dylib.lookupFunction<_GenImageTextRay, _GenImageTextDart>('GenImageText');

typedef _ImageCopyRay = _Image Function(_Image);
typedef _ImageCopyDart = _Image Function(_Image);
final _imageCopy = _dylib.lookupFunction<_ImageCopyRay, _ImageCopyDart>('ImageCopy');

typedef _ImageFromImageRay = _Image Function(_Image, _Rectangle);
typedef _ImageFromImageDart = _Image Function(_Image, _Rectangle);
final _imageFromImage = _dylib.lookupFunction<_ImageFromImageRay, _ImageFromImageDart>('ImageFromImage');

typedef _ImageFromChannelRay = _Image Function(_Image, Int32);
typedef _ImageFromChannelDart = _Image Function(_Image, int);
final _imageFromChannel = _dylib.lookupFunction<_ImageFromChannelRay, _ImageFromChannelDart>('ImageFromChannel');

typedef _ImageTextRay = _Image Function(Pointer<Utf8>, Int32, _Color);
typedef _ImageTextDart = _Image Function(Pointer<Utf8>, int, _Color);
final _imageText = _dylib.lookupFunction<_ImageTextRay, _ImageTextDart>('ImageText');

typedef _ImageTextExRay = _Image Function(_Font, Pointer<Utf8>, Float, Float, _Color);
typedef _ImageTextExDart = _Image Function(_Font, Pointer<Utf8>, double, double, _Color);
final _imageTextEx = _dylib.lookupFunction<_ImageTextExRay, _ImageTextExDart>('ImageTextEx');

typedef _ImageFormatRay = Void Function(Pointer<_Image>, Int32);
typedef _ImageFormatDart = void Function(Pointer<_Image>, int);
final _imageFormat = _dylib.lookupFunction<_ImageFormatRay, _ImageFormatDart>('ImageFormat');

typedef _ImageToPOTRay = Void Function(Pointer<_Image>, _Color);
typedef _ImageToPOTDart = void Function(Pointer<_Image>, _Color);
final _imageToPOT = _dylib.lookupFunction<_ImageToPOTRay, _ImageToPOTDart>('ImageToPOT');

typedef _ImageCropRay = Void Function(Pointer<_Image>, _Rectangle);
typedef _ImageCropDart = void Function(Pointer<_Image>, _Rectangle);
final _imageCrop = _dylib.lookupFunction<_ImageCropRay, _ImageCropDart>('ImageCrop');

typedef _ImageAlphaCropRay = Void Function(Pointer<_Image>, Float);
typedef _ImageAlphaCropDart = void Function(Pointer<_Image>, double);
final _imageAlphaCrop = _dylib.lookupFunction<_ImageAlphaCropRay, _ImageAlphaCropDart>('ImageAlphaCrop');

typedef _ImageAlphaClearRay = Void Function(Pointer<_Image>, _Color, Float);
typedef _ImageAlphaClearDart = void Function(Pointer<_Image>, _Color, double);
final _imageAlphaClear = _dylib.lookupFunction<_ImageAlphaClearRay, _ImageAlphaClearDart>('ImageAlphaClear');

typedef _ImageAlphaMaskRay = Void Function(Pointer<_Image>, _Image);
typedef _ImageAlphaMaskDart = void Function(Pointer<_Image>, _Image);
final _imageAlphaMask = _dylib.lookupFunction<_ImageAlphaMaskRay, _ImageAlphaMaskDart>('ImageAlphaMask');

typedef _ImageAlphaPremultiplyRay = Void Function(Pointer<_Image>);
typedef _ImageAlphaPremultiplyDart = void Function(Pointer<_Image>);
final _imageAlphaPremultiply = _dylib.lookupFunction<_ImageAlphaPremultiplyRay, _ImageAlphaPremultiplyDart>('ImageAlphaPremultiply');

typedef _ImageBlurGaussianRay = Void Function(Pointer<_Image>, Int32);
typedef _ImageBlurGaussianDart = void Function(Pointer<_Image>, int);
final _imageBlurGaussian = _dylib.lookupFunction<_ImageBlurGaussianRay, _ImageBlurGaussianDart>('ImageBlurGaussian');

typedef _ImageKernelConvolutionRay = Void Function(Pointer<_Image>, Pointer<Float>, Int32);
typedef _ImageKernelConvolutionDart = void Function(Pointer<_Image>, Pointer<Float>, int);
final _imageKernelConvolution = _dylib.lookupFunction<_ImageKernelConvolutionRay, _ImageKernelConvolutionDart>('ImageKernelConvolution');

typedef _ImageResizeRay = Void Function(Pointer<_Image>, Int32, Int32);
typedef _ImageResizeDart = void Function(Pointer<_Image>, int, int);
final _imageResize = _dylib.lookupFunction<_ImageResizeRay, _ImageResizeDart>('ImageResize');

typedef _ImageResizeNNRay = Void Function(Pointer<_Image>, Int32, Int32);
typedef _ImageResizeNNDart = void Function(Pointer<_Image>, int, int);
final _imageResizeNN = _dylib.lookupFunction<_ImageResizeNNRay, _ImageResizeNNDart>('ImageResizeNN');

typedef _ImageResizeCanvasRay = Void Function(Pointer<_Image>, Int32, Int32, Int32, Int32, _Color);
typedef _ImageResizeCanvasDart = void Function(Pointer<_Image>, int, int, int, int, _Color);
final _imageResizeCanvas = _dylib.lookupFunction<_ImageResizeCanvasRay, _ImageResizeCanvasDart>('ImageResizeCanvas');

typedef _ImageMipmapsRay = Void Function(Pointer<_Image>);
typedef _ImageMipmapsDart = void Function(Pointer<_Image>);
final _imageMipmaps = _dylib.lookupFunction<_ImageMipmapsRay, _ImageMipmapsDart>('ImageMipmaps');

typedef _ImageDitherRay = Void Function(Pointer<_Image>, Int32, Int32, Int32, Int32);
typedef _ImageDitherDart = void Function(Pointer<_Image>, int, int, int, int);
final _imageDither = _dylib.lookupFunction<_ImageDitherRay, _ImageDitherDart>('ImageDither');

typedef _ImageFlipVerticalRay = Void Function(Pointer<_Image>);
typedef _ImageFlipVerticalDart = void Function(Pointer<_Image>);
final _imageFlipVertical = _dylib.lookupFunction<_ImageFlipVerticalRay, _ImageFlipVerticalDart>('ImageFlipVertical');

typedef _ImageFlipHorizontalRay = Void Function(Pointer<_Image>);
typedef _ImageFlipHorizontalDart = void Function(Pointer<_Image>);
final _imageFlipHorizontal = _dylib.lookupFunction<_ImageFlipHorizontalRay, _ImageFlipHorizontalDart>('ImageFlipHorizontal');

typedef _ImageRotateRay = Void Function(Pointer<_Image>, Int32);
typedef _ImageRotateDart = void Function(Pointer<_Image>, int);
final _imageRotate = _dylib.lookupFunction<_ImageRotateRay, _ImageRotateDart>('ImageRotate');

typedef _ImageRotateCWRay = Void Function(Pointer<_Image>);
typedef _ImageRotateCWDart = void Function(Pointer<_Image>);
final _imageRotateCW = _dylib.lookupFunction<_ImageRotateCWRay, _ImageRotateCWDart>('ImageRotateCW');

typedef _ImageRotateCCWRay = Void Function(Pointer<_Image>);
typedef _ImageRotateCCWDart = void Function(Pointer<_Image>);
final _imageRotateCCW = _dylib.lookupFunction<_ImageRotateCCWRay, _ImageRotateCCWDart>('ImageRotateCCW');

typedef _ImageColorTintRay = Void Function(Pointer<_Image>, _Color);
typedef _ImageColorTintDart = void Function(Pointer<_Image>, _Color);
final _imageColorTint = _dylib.lookupFunction<_ImageColorTintRay, _ImageColorTintDart>('ImageColorTint');

typedef _ImageColorInvertRay = Void Function(Pointer<_Image>);
typedef _ImageColorInvertDart = void Function(Pointer<_Image>);
final _imageColorInvert = _dylib.lookupFunction<_ImageColorInvertRay, _ImageColorInvertDart>('ImageColorInvert');

typedef _ImageColorGrayscaleRay = Void Function(Pointer<_Image>);
typedef _ImageColorGrayscaleDart = void Function(Pointer<_Image>);
final _imageColorGrayscale = _dylib.lookupFunction<_ImageColorGrayscaleRay, _ImageColorGrayscaleDart>('ImageColorGrayscale');

typedef _ImageColorContrastRay = Void Function(Pointer<_Image>, Float);
typedef _ImageColorContrastDart = void Function(Pointer<_Image>, double);
final _imageColorContrast = _dylib.lookupFunction<_ImageColorContrastRay, _ImageColorContrastDart>('ImageColorContrast');

typedef _ImageColorBrightnessRay = Void Function(Pointer<_Image>, Int32);
typedef _ImageColorBrightnessDart = void Function(Pointer<_Image>, int);
final _imageColorBrightness = _dylib.lookupFunction<_ImageColorBrightnessRay, _ImageColorBrightnessDart>('ImageColorBrightness');

typedef _ImageColorReplaceRay = Void Function(Pointer<_Image>, _Color, _Color);
typedef _ImageColorReplaceDart = void Function(Pointer<_Image>, _Color, _Color);
final _imageColorReplace = _dylib.lookupFunction<_ImageColorReplaceRay, _ImageColorReplaceDart>('ImageColorReplace');

//------------------------------------------------------------------------------------
//                                   Texture
//------------------------------------------------------------------------------------

typedef _LoadTextureRay = _Texture2D Function(Pointer<Utf8>);
typedef _LoadTextureDart = _Texture2D Function(Pointer<Utf8>);
final _loadTexture = _dylib.lookupFunction<_LoadTextureRay, _LoadTextureDart>('LoadTexture');

typedef _LoadTextureFromImageRay = _Texture2D Function(_Image);
typedef _LoadTextureFromImageDart = _Texture2D Function(_Image);
final _loadTextureFromImage = _dylib.lookupFunction<_LoadTextureFromImageRay, _LoadTextureFromImageDart>('LoadTextureFromImage');

typedef _LoadTextureCubemapRay = _TextureCubemap Function(_Image, Int32);
typedef _LoadTextureCubemapDart = _TextureCubemap Function(_Image, int);
final _loadTextureCubemap = _dylib.lookupFunction<_LoadTextureCubemapRay, _LoadTextureCubemapDart>('LoadTextureCubemap');

typedef _LoadRenderTextureRay = _RenderTexture2D Function(Int32, Int32);
typedef _LoadRenderTextureDart = _RenderTexture2D Function(int, int);
final _loadRenderTexture = _dylib.lookupFunction<_LoadRenderTextureRay, _LoadRenderTextureDart>('LoadRenderTexture');

typedef _IsTextureValidRay = Bool Function(_Texture2D);
typedef _IsTextureValidDart = bool Function(_Texture2D);
final _isTextureValid = _dylib.lookupFunction<_IsTextureValidRay, _IsTextureValidDart>('IsTextureValid');

typedef _UnloadTextureRay = Void Function(_Texture2D);
typedef _UnloadTextureDart = void Function(_Texture2D);
final _unloadTexture = _dylib.lookupFunction<_UnloadTextureRay, _UnloadTextureDart>('UnloadTexture');

typedef _UpdateTextureRay = Void Function(_Texture2D, Pointer<Void>);
typedef _UpdateTextureDart = void Function(_Texture2D, Pointer<Void>);
final _updateTexture = _dylib.lookupFunction<_UpdateTextureRay, _UpdateTextureDart>('UpdateTexture');

typedef _UpdateTextureRecRay = Void Function(_Texture2D, _Rectangle, Pointer<Void>);
typedef _UpdateTextureRecDart = void Function(_Texture2D, _Rectangle, Pointer<Void>);
final _updateTextureRec = _dylib.lookupFunction<_UpdateTextureRecRay, _UpdateTextureRecDart>('UpdateTextureRec');

typedef _DrawTextureRay = Void Function(_Texture2D, Int32, Int32, _Color);
typedef _DrawTextureDart = void Function(_Texture2D, int, int, _Color);
final _drawTexture = _dylib.lookupFunction<_DrawTextureRay, _DrawTextureDart>('DrawTexture');

typedef _DrawTextureVRay = Void Function(_Texture2D, _Vector2, _Color);
typedef _DrawTextureVDart = void Function(_Texture2D, _Vector2, _Color);
final _drawTextureV = _dylib.lookupFunction<_DrawTextureVRay, _DrawTextureVDart>('DrawTextureV');

typedef _DrawTextureExRay = Void Function(_Texture2D, _Vector2, Float, Float, _Color);
typedef _DrawTextureExDart = void Function(_Texture2D, _Vector2, double, double, _Color);
final _drawTextureEx = _dylib.lookupFunction<_DrawTextureExRay, _DrawTextureExDart>('DrawTextureEx');

typedef _DrawTextureRecRay = Void Function(_Texture2D, _Rectangle, _Vector2, _Color);
typedef _DrawTextureRecDart = void Function(_Texture2D, _Rectangle, _Vector2, _Color);
final _drawTextureRec = _dylib.lookupFunction<_DrawTextureRecRay, _DrawTextureRecDart>('DrawTextureRec');

typedef _DrawTextureProRay = Void Function(_Texture2D, _Rectangle, _Rectangle, _Vector2, Float, _Color);
typedef _DrawTextureProDart = void Function(_Texture2D, _Rectangle, _Rectangle, _Vector2, double, _Color);
final _drawTexturePro = _dylib.lookupFunction<_DrawTextureProRay, _DrawTextureProDart>('DrawTexturePro');

typedef _DrawTextureNPatchRay = Void Function(_Texture2D, _NPatchInfo, _Rectangle, _Vector2, Float, _Color);
typedef _DrawTextureNPatchDart = void Function(_Texture2D, _NPatchInfo, _Rectangle, _Vector2, double, _Color);
final _drawTextureNPatch = _dylib.lookupFunction<_DrawTextureNPatchRay, _DrawTextureNPatchDart>('DrawTextureNPatch');

typedef _GenTextureMipmapsRay = Void Function(Pointer<_Texture2D>);
typedef _GenTextureMipmapsDart = void Function(Pointer<_Texture2D>);
final _genTextureMipmaps = _dylib.lookupFunction<_GenTextureMipmapsRay, _GenTextureMipmapsDart>('GenTextureMipmaps');

typedef _SetTextureFilterRay = Void Function(_Texture2D, Int32);
typedef _SetTextureFilterDart = void Function(_Texture2D, int);
final _setTextureFilter = _dylib.lookupFunction<_SetTextureFilterRay, _SetTextureFilterDart>('SetTextureFilter');

typedef _SetTextureWrapRay = Void Function(_Texture2D, Int32);
typedef _SetTextureWrapDart = void Function(_Texture2D, int);
final _setTextureWrap = _dylib.lookupFunction<_SetTextureWrapRay, _SetTextureWrapDart>('SetTextureWrap');

//------------------------------------------------------------------------------------
//                                RenderTexture
//------------------------------------------------------------------------------------

typedef _IsRenderTextureValidRay = Bool Function(_RenderTexture2D);
typedef _IsRenderTextureValidDart = bool Function(_RenderTexture2D);
final _isRenderTextureValid = _dylib.lookupFunction<_IsRenderTextureValidRay, _IsRenderTextureValidDart>('IsRenderTextureValid');

typedef _UnloadRenderTextureRay = Void Function(_RenderTexture2D);
typedef _UnloadRenderTextureDart = void Function(_RenderTexture2D);
final _unloadRenderTexture = _dylib.lookupFunction<_UnloadRenderTextureRay, _UnloadRenderTextureDart>('UnloadRenderTexture');

//------------------------------------------------------------------------------------
//                                   Window
//------------------------------------------------------------------------------------

typedef _ClearBackgroundRay = Void Function(_Color);
typedef _ClearBackgroundDart = void Function(_Color);
final _clearBackground = _dylib.lookupFunction<_ClearBackgroundRay, _ClearBackgroundDart>('ClearBackground');

typedef _BeginDrawingRay = Void Function();
typedef _BeginDrawingDart = void Function();
final _beginDrawing = _dylib.lookupFunction<_BeginDrawingRay, _BeginDrawingDart>('BeginDrawing');

typedef _EndDrawingRay = Void Function();
typedef _EndDrawingDart = void Function();
final _endDrawing = _dylib.lookupFunction<_EndDrawingRay, _EndDrawingDart>('EndDrawing');

typedef _BeginMode2DRay = Void Function(_Camera2D);
typedef _BeginMode2DDart = void Function(_Camera2D);
final _beginMode2D = _dylib.lookupFunction<_BeginMode2DRay, _BeginMode2DDart>('BeginMode2D');

typedef _EndMode2DRay = Void Function();
typedef _EndMode2DDart = void Function();
final _endMode2D = _dylib.lookupFunction<_EndMode2DRay, _EndMode2DDart>('EndMode2D');

typedef _BeginMode3DRay = Void Function(_Camera3D);
typedef _BeginMode3DDart = void Function(_Camera3D);
final _beginMode3D = _dylib.lookupFunction<_BeginMode3DRay, _BeginMode3DDart>('BeginMode3D');

typedef _EndMode3DRay = Void Function();
typedef _EndMode3DDart = void Function();
final _endMode3D = _dylib.lookupFunction<_EndMode3DRay, _EndMode3DDart>('EndMode3D');

typedef _BeginTextureModeRay = Void Function(_RenderTexture2D);
typedef _BeginTextureModeDart = void Function(_RenderTexture2D);
final _beginTextureMode = _dylib.lookupFunction<_BeginTextureModeRay, _BeginTextureModeDart>('BeginTextureMode');

typedef _EndTextureModeRay = Void Function();
typedef _EndTextureModeDart = void Function();
final _endTextureMode = _dylib.lookupFunction<_EndTextureModeRay, _EndTextureModeDart>('EndTextureMode');

//------------------------------------------------------------------------------------
//                                   Color
//------------------------------------------------------------------------------------

typedef _ColorIsEqualRay = Bool Function(_Color, _Color);
typedef _ColorIsEqualDart = bool Function(_Color, _Color);
final _colorIsEqual = _dylib.lookupFunction<_ColorIsEqualRay, _ColorIsEqualDart>('ColorIsEqual');

typedef _FadeRay = _Color Function(_Color, Float);
typedef _FadeDart = _Color Function(_Color, double);
final _fade = _dylib.lookupFunction<_FadeRay, _FadeDart>('Fade');

typedef _ColorToIntRay = Int32 Function(_Color);
typedef _ColorToIntDart = int Function(_Color);
final _colorToInt = _dylib.lookupFunction<_ColorToIntRay, _ColorToIntDart>('ColorToInt');

typedef _ColorNormalizeRay = _Vector4 Function(_Color);
typedef _ColorNormalizeDart = _Vector4 Function(_Color);
final _colorNormalize = _dylib.lookupFunction<_ColorNormalizeRay, _ColorNormalizeDart>('ColorNormalize');

typedef _ColorFromNormalizedRay = _Color Function(_Vector4);
typedef _ColorFromNormalizedDart = _Color Function(_Vector4);
final _colorFromNormalized = _dylib.lookupFunction<_ColorFromNormalizedRay, _ColorFromNormalizedDart>('ColorFromNormalized');

typedef _ColorToHSVRay = _Vector3 Function(_Color);
typedef _ColorToHSVDart = _Vector3 Function(_Color);
final _colorToHSV = _dylib.lookupFunction<_ColorToHSVRay, _ColorToHSVDart>('ColorToHSV');

typedef _ColorFromHSVRay = _Color Function(Float, Float, Float);
typedef _ColorFromHSVDart = _Color Function(double, double, double);
final _colorFromHSV = _dylib.lookupFunction<_ColorFromHSVRay, _ColorFromHSVDart>('ColorFromHSV');

typedef _ColorTintRay = _Color Function(_Color, _Color);
typedef _ColorTintDart = _Color Function(_Color, _Color);
final _colorTint = _dylib.lookupFunction<_ColorTintRay, _ColorTintDart>('ColorTint');

typedef _ColorBrightnessRay = _Color Function(_Color, Float);
typedef _ColorBrightnessDart = _Color Function(_Color, double);
final _colorBrightness = _dylib.lookupFunction<_ColorBrightnessRay, _ColorBrightnessDart>('ColorBrightness');

typedef _ColorContrastRay = _Color Function(_Color, Float);
typedef _ColorContrastDart = _Color Function(_Color, double);
final _colorContrast = _dylib.lookupFunction<_ColorContrastRay, _ColorContrastDart>('ColorContrast');

typedef _ColorAlphaRay = _Color Function(_Color, Float);
typedef _ColorAlphaDart = _Color Function(_Color, double);
final _colorAlpha = _dylib.lookupFunction<_ColorAlphaRay, _ColorAlphaDart>('ColorAlpha');

typedef _ColorAlphaBlendRay = _Color Function(_Color, _Color, _Color);
typedef _ColorAlphaBlendDart = _Color Function(_Color, _Color, _Color);
final _colorAlphaBlend = _dylib.lookupFunction<_ColorAlphaBlendRay, _ColorAlphaBlendDart>('ColorAlphaBlend');

typedef _ColorLerpRay = _Color Function(_Color, _Color, Float);
typedef _ColorLerpDart = _Color Function(_Color, _Color, double);
final _colorLerp = _dylib.lookupFunction<_ColorLerpRay, _ColorLerpDart>('ColorLerp');

typedef _GetColorRay = _Color Function(Uint32);
typedef _GetColorDart = _Color Function(int);
final _getColor = _dylib.lookupFunction<_GetColorRay, _GetColorDart>('GetColor');

typedef _GetPixelColorRay = _Color Function(Pointer<Void>, Int32);
typedef _GetPixelColorDart = _Color Function(Pointer<Void>, int);
final _getPixelColor = _dylib.lookupFunction<_GetPixelColorRay, _GetPixelColorDart>('GetPixelColor');

typedef _SetPixelColorRay = Void Function(Pointer<Void>, _Color, Int32);
typedef _SetPixelColorDart = void Function(Pointer<Void>, _Color, int);
final _setPixelColor = _dylib.lookupFunction<_SetPixelColorRay, _SetPixelColorDart>('SetPixelColor');

typedef _GetPixelDataSizeRay = Int32 Function(Int32, Int32, Int32);
typedef _GetPixelDataSizeDart = int Function(int, int, int);
final _getPixelDataSize = _dylib.lookupFunction<_GetPixelDataSizeRay, _GetPixelDataSizeDart>('GetPixelDataSize');

//------------------------------------------------------------------------------------
//                                   Font
//------------------------------------------------------------------------------------

typedef _GetFontDefaultRay = _Font Function();
typedef _GetFontDefaultDart = _Font Function();
final _getFontDefault = _dylib.lookupFunction<_GetFontDefaultRay, _GetFontDefaultDart>('GetFontDefault');

typedef _LoadFontRay = _Font Function(Pointer<Utf8>);
typedef _LoadFontDart = _Font Function(Pointer<Utf8>);
final _loadFont = _dylib.lookupFunction<_LoadFontRay, _LoadFontDart>('LoadFont');

typedef _LoadFontExRay = _Font Function(Pointer<Utf8>, Int32, Pointer<Int32>, Int32);
typedef _LoadFontExDart = _Font Function(Pointer<Utf8>, int, Pointer<Int32>, int);
final _loadFontEx = _dylib.lookupFunction<_LoadFontExRay, _LoadFontExDart>('LoadFontEx');

typedef _LoadFontFromImageRay = _Font Function(_Image, _Color, Int32);
typedef _LoadFontFromImageDart = _Font Function(_Image, _Color, int);
final _loadFontFromImage = _dylib.lookupFunction<_LoadFontFromImageRay, _LoadFontFromImageDart>('LoadFontFromImage');

typedef _LoadFontFromMemoryRay = _Font Function(Pointer<Utf8>, Pointer<Uint8>, Int32, Int32, Pointer<Int32>, Int32);
typedef _LoadFontFromMemoryDart = _Font Function(Pointer<Utf8>, Pointer<Uint8>, int, int, Pointer<Int32>, int);
final _loadFontFromMemory = _dylib.lookupFunction<_LoadFontFromMemoryRay, _LoadFontFromMemoryDart>('LoadFontFromMemory');

typedef _IsFontValidRay = Bool Function(_Font);
typedef _IsFontValidDart = bool Function(_Font);
final _isFontValid = _dylib.lookupFunction<_IsFontValidRay, _IsFontValidDart>('IsFontValid');

typedef _LoadFontDataRay = Pointer<_GlyphInfo> Function(Pointer<Uint8>, Int32, Int32, Pointer<Int32>, Int32, Int32, Pointer<Int32>);
typedef _LoadFontDataDart = Pointer<_GlyphInfo> Function(Pointer<Uint8>, int, int, Pointer<Int32>, int, int, Pointer<Int32>);
final _loadFontData = _dylib.lookupFunction<_LoadFontDataRay, _LoadFontDataDart>('LoadFontData');

typedef _GenImageFontAtlasRay = _Image Function(Pointer<_GlyphInfo>, Pointer<_Rectangle>, Int32, Int32, Int32, Int32);
typedef _GenImageFontAtlasDart = _Image Function(Pointer<_GlyphInfo>, Pointer<_Rectangle>, int, int, int, int);
final _genImageFontAtlas = _dylib.lookupFunction<_GenImageFontAtlasRay, _GenImageFontAtlasDart>('GenImageFontAtlas');

typedef _UnloadFontDataRay = Void Function(Pointer<_GlyphInfo>, Int32);
typedef _UnloadFontDataDart = void Function(Pointer<_GlyphInfo>, int);
final _unloadFontData = _dylib.lookupFunction<_UnloadFontDataRay, _UnloadFontDataDart>('UnloadFontData');

typedef _UnloadFontRay = Void Function(_Font);
typedef _UnloadFontDart = void Function(_Font);
final _unloadFont = _dylib.lookupFunction<_UnloadFontRay, _UnloadFontDart>('UnloadFont');

typedef _ExportFontAsCodeRay = Bool Function(_Font, Pointer<Utf8>);
typedef _ExportFontAsCodeDart = bool Function(_Font, Pointer<Utf8>);
final _exportFontAsCode = _dylib.lookupFunction<_ExportFontAsCodeRay, _ExportFontAsCodeDart>('ExportFontAsCode');

//TODO: Implement Shader Shadow Class

// typedef _BeginShaderModeRay = Void Function(Shader);
// typedef _BeginShaderModeDart = void Function(Shader);
// final _beginShaderMode = _dylib.lookupFunction<_BeginShaderModeRay, _BeginShaderModeDart>('BeginShaderMode');

// typedef _EndShaderModeRay = Void Function();
// typedef _EndShaderModeDart = void Function();
// final _endShaderMode = _dylib.lookupFunction<_EndShaderModeRay, _EndShaderModeDart>('EndShaderMode');

// typedef _BeginBlendModeRay = Void Function(Int32);
// typedef _BeginBlendModeDart = void Function(int);
// final _beginBlendMode = _dylib.lookupFunction<_BeginBlendModeRay, _BeginBlendModeDart>('BeginBlendMode');

// typedef _EndBlendModeRay = Void Function();
// typedef _EndBlendModeDart = void Function();
// final _endBlendMode = _dylib.lookupFunction<_EndBlendModeRay, _EndBlendModeDart>('EndBlendMode');

// typedef _BeginScissorModeRay = Void Function(Int32, Int32, Int32, Int32);
// typedef _BeginScissorModeDart = void Function(int, int, int, int);
// final _beginScissorMode = _dylib.lookupFunction<_BeginScissorModeRay, _BeginScissorModeDart>('BeginScissorMode');

// typedef _EndScissorModeRay = Void Function();
// typedef _EndScissorModeDart = void Function();
// final _endScissorMode = _dylib.lookupFunction<_EndScissorModeRay, _EndScissorModeDart>('EndScissorMode');

// typedef _BeginVrStereoModeRay = Void Function(VrStereoConfig);
// typedef _BeginVrStereoModeDart = void Function(VrStereoConfig);
// final _beginVrStereoMode = _dylib.lookupFunction<_BeginVrStereoModeRay, _BeginVrStereoModeDart>('BeginVrStereoMode');

// typedef _EndVrStereoModeRay = Void Function();
// typedef _EndVrStereoModeDart = void Function();
// final _endVrStereoMode = _dylib.lookupFunction<_EndVrStereoModeRay, _EndVrStereoModeDart>('EndVrStereoMode');

//------------------------------------------------------------------------------------
// Model 3d Loading and Drawing Functions (Module: models)
//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------
//                                   Mesh
//------------------------------------------------------------------------------------

typedef _UploadMeshRay = Void Function(Pointer<_Mesh>, Bool);
typedef _UploadMeshDart = void Function(Pointer<_Mesh>, bool);
final _uploadMesh = _dylib.lookupFunction<_UploadMeshRay, _UploadMeshDart>('UploadMesh');

typedef _UpdateMeshBufferRay = Void Function(_Mesh, Int32, Pointer<Void>, Int32, Int32);
typedef _UpdateMeshBufferDart = void Function(_Mesh, int, Pointer<Void>, int, int);
final _updateMeshBuffer = _dylib.lookupFunction<_UpdateMeshBufferRay, _UpdateMeshBufferDart>('UpdateMeshBuffer');

typedef _UnloadMeshRay = Void Function(_Mesh);
typedef _UnloadMeshDart = void Function(_Mesh);
final _unloadMesh = _dylib.lookupFunction<_UnloadMeshRay, _UnloadMeshDart>('UnloadMesh');

typedef _DrawMeshRay = Void Function(_Mesh, _Material, _Matrix);
typedef _DrawMeshDart = void Function(_Mesh, _Material, _Matrix);
final _drawMesh = _dylib.lookupFunction<_DrawMeshRay, _DrawMeshDart>('DrawMesh');

typedef _DrawMeshInstancedRay = Void Function(_Mesh, _Material, Pointer<_Matrix>, Int32);
typedef _DrawMeshInstancedDart = void Function(_Mesh, _Material, Pointer<_Matrix>, int);
final _drawMeshInstanced = _dylib.lookupFunction<_DrawMeshInstancedRay, _DrawMeshInstancedDart>('DrawMeshInstanced');

typedef _GetMeshBoundingBoxRay = _BoundingBox Function(_Mesh);
typedef _GetMeshBoundingBoxDart = _BoundingBox Function(_Mesh);
final _getMeshBoundingBox = _dylib.lookupFunction<_GetMeshBoundingBoxRay, _GetMeshBoundingBoxDart>('GetMeshBoundingBox');

typedef _GenMeshTangentsRay = Void Function(Pointer<_Mesh>);
typedef _GenMeshTangentsDart = void Function(Pointer<_Mesh>);
final _genMeshTangents = _dylib.lookupFunction<_GenMeshTangentsRay, _GenMeshTangentsDart>('GenMeshTangents');

typedef _ExportMeshRay = Bool Function(_Mesh, Pointer<Utf8>);
typedef _ExportMeshDart = bool Function(_Mesh, Pointer<Utf8>);
final _exportMesh = _dylib.lookupFunction<_ExportMeshRay, _ExportMeshDart>('ExportMesh');

typedef _ExportMeshAsCodeRay = Bool Function(_Mesh, Pointer<Utf8>);
typedef _ExportMeshAsCodeDart = bool Function(_Mesh, Pointer<Utf8>);
final _exportMeshAsCode = _dylib.lookupFunction<_ExportMeshAsCodeRay, _ExportMeshAsCodeDart>('ExportMeshAsCode');

typedef _GenMeshPolyRay = _Mesh Function(Int32, Float);
typedef _GenMeshPolyDart = _Mesh Function(int, double);
final _genMeshPoly = _dylib.lookupFunction<_GenMeshPolyRay, _GenMeshPolyDart>('GenMeshPoly');

typedef _GenMeshPlaneRay = _Mesh Function(Float, Float, Int32, Int32);
typedef _GenMeshPlaneDart = _Mesh Function(double, double, int, int);
final _genMeshPlane = _dylib.lookupFunction<_GenMeshPlaneRay, _GenMeshPlaneDart>('GenMeshPlane');

typedef _GenMeshCubeRay = _Mesh Function(Float, Float, Float);
typedef _GenMeshCubeDart = _Mesh Function(double, double, double);
final _genMeshCube = _dylib.lookupFunction<_GenMeshCubeRay, _GenMeshCubeDart>('GenMeshCube');

typedef _GenMeshSphereRay = _Mesh Function(Float, Int32, Int32);
typedef _GenMeshSphereDart = _Mesh Function(double, int, int);
final _genMeshSphere = _dylib.lookupFunction<_GenMeshSphereRay, _GenMeshSphereDart>('GenMeshSphere');

typedef _GenMeshHemiSphereRay = _Mesh Function(Float, Int32, Int32);
typedef _GenMeshHemiSphereDart = _Mesh Function(double, int, int);
final _genMeshHemiSphere = _dylib.lookupFunction<_GenMeshHemiSphereRay, _GenMeshHemiSphereDart>('GenMeshHemiSphere');

typedef _GenMeshCylinderRay = _Mesh Function(Float, Float, Int32);
typedef _GenMeshCylinderDart = _Mesh Function(double, double, int);
final _genMeshCylinder = _dylib.lookupFunction<_GenMeshCylinderRay, _GenMeshCylinderDart>('GenMeshCylinder');

typedef _GenMeshConeRay = _Mesh Function(Float, Float, Int32);
typedef _GenMeshConeDart = _Mesh Function(double, double, int);
final _genMeshCone = _dylib.lookupFunction<_GenMeshConeRay, _GenMeshConeDart>('GenMeshCone');

typedef _GenMeshTorusRay = _Mesh Function(Float, Float, Int32, Int32);
typedef _GenMeshTorusDart = _Mesh Function(double, double, int, int);
final _genMeshTorus = _dylib.lookupFunction<_GenMeshTorusRay, _GenMeshTorusDart>('GenMeshTorus');

typedef _GenMeshKnotRay = _Mesh Function(Float, Float, Int32, Int32);
typedef _GenMeshKnotDart = _Mesh Function(double, double, int, int);
final _genMeshKnot = _dylib.lookupFunction<_GenMeshKnotRay, _GenMeshKnotDart>('GenMeshKnot');

typedef _GenMeshHeightmapRay = _Mesh Function(_Image, _Vector3);
typedef _GenMeshHeightmapDart = _Mesh Function(_Image, _Vector3);
final _genMeshHeightmap = _dylib.lookupFunction<_GenMeshHeightmapRay, _GenMeshHeightmapDart>('GenMeshHeightmap');

typedef _GenMeshCubicmapRay = _Mesh Function(_Image, _Vector3);
typedef _GenMeshCubicmapDart = _Mesh Function(_Image, _Vector3);
final _genMeshCubicmap = _dylib.lookupFunction<_GenMeshCubicmapRay, _GenMeshCubicmapDart>('GenMeshCubicmap');

//------------------------------------------------------------------------------------
//                                   Material
//------------------------------------------------------------------------------------

typedef _LoadMaterialsRay = Pointer<_Material> Function(Pointer<Utf8> fileName, Pointer<Int32> materialCount);
typedef _LoadMaterialsDart = Pointer<_Material> Function(Pointer<Utf8> fileName, Pointer<Int32> materialCount);
final _loadMaterials = _dylib.lookupFunction<_LoadMaterialsRay, _LoadMaterialsDart>('LoadMaterials');

typedef _LoadMaterialDefaultRay = _Material Function();
typedef _LoadMaterialDefaultDart = _Material Function();
final _loadMaterialDefault = _dylib.lookupFunction<_LoadMaterialDefaultRay, _LoadMaterialDefaultDart>('LoadMaterialDefault');

typedef _IsMaterialValidRay = Bool Function(_Material);
typedef _IsMaterialValidDart = bool Function(_Material);
final _isMaterialValid = _dylib.lookupFunction<_IsMaterialValidRay, _IsMaterialValidDart>('IsMaterialValid');

typedef _UnloadMaterialRay = Void Function(_Material);
typedef _UnloadMaterialDart = void Function(_Material);
final _unloadMaterial = _dylib.lookupFunction<_UnloadMaterialRay, _UnloadMaterialDart>('UnloadMaterial');

typedef _SetMaterialTextureRay = Void Function(Pointer<_Material>, Int32, _Texture2D);
typedef _SetMaterialTextureDart = void Function(Pointer<_Material>, int, _Texture2D);
final _setMaterialTexture = _dylib.lookupFunction<_SetMaterialTextureRay, _SetMaterialTextureDart>('SetMaterialTexture');

//------------------------------------------------------------------------------------
//                                   Model
//------------------------------------------------------------------------------------

typedef _LoadModelRay = _Model Function(Pointer<Utf8>);
typedef _LoadModelDart = _Model Function(Pointer<Utf8>);
final _loadModel = _dylib.lookupFunction<_LoadModelRay, _LoadModelDart>('LoadModel');

typedef _LoadModelFromMeshRay = _Model Function(_Mesh);
typedef _LoadModelFromMeshDart = _Model Function(_Mesh);
final _loadModelFromMesh = _dylib.lookupFunction<_LoadModelFromMeshRay, _LoadModelFromMeshDart>('LoadModelFromMesh');

typedef _IsModelValidRay = Bool Function(_Model);
typedef _IsModelValidDart = bool Function(_Model);
final _isModelValid = _dylib.lookupFunction<_IsModelValidRay, _IsModelValidDart>('IsModelValid');

typedef _UnloadModelRay = Void Function(_Model);
typedef _UnloadModelDart = void Function(_Model);
final _unloadModel = _dylib.lookupFunction<_UnloadModelRay, _UnloadModelDart>('UnloadModel');

typedef _GetModelBoundingBoxRay = _BoundingBox Function(_Model);
typedef _GetModelBoundingBoxDart = _BoundingBox Function(_Model);
final _getModelBoundingBox = _dylib.lookupFunction<_GetModelBoundingBoxRay, _GetModelBoundingBoxDart>('GetModelBoundingBox');

typedef _DrawModelRay = Void Function(_Model, _Vector3, Float, _Color);
typedef _DrawModelDart = void Function(_Model, _Vector3, double, _Color);
final _drawModel = _dylib.lookupFunction<_DrawModelRay, _DrawModelDart>('DrawModel');

typedef _DrawModelExRay = Void Function(_Model, _Vector3, _Vector3, Float, _Vector3, _Color);
typedef _DrawModelExDart = void Function(_Model, _Vector3, _Vector3, double, _Vector3, _Color);
final _drawModelEx = _dylib.lookupFunction<_DrawModelExRay, _DrawModelExDart>('DrawModelEx');

typedef _DrawModelWiresRay = Void Function(_Model, _Vector3, Float, _Color);
typedef _DrawModelWiresDart = void Function(_Model, _Vector3, double, _Color);
final _drawModelWires = _dylib.lookupFunction<_DrawModelWiresRay, _DrawModelWiresDart>('DrawModelWires');

typedef _DrawModelWiresExRay = Void Function(_Model, _Vector3, _Vector3, Float, _Vector3, _Color);
typedef _DrawModelWiresExDart = void Function(_Model, _Vector3, _Vector3, double, _Vector3, _Color);
final _drawModelWiresEx = _dylib.lookupFunction<_DrawModelWiresExRay, _DrawModelWiresExDart>('DrawModelWiresEx');

typedef _DrawModelPointsRay = Void Function(_Model, _Vector3, Float, _Color);
typedef _DrawModelPointsDart = void Function(_Model, _Vector3, double, _Color);
final _drawModelPoints = _dylib.lookupFunction<_DrawModelPointsRay, _DrawModelPointsDart>('DrawModelPoints');

typedef _DrawModelPointsExRay = Void Function(_Model, _Vector3, _Vector3, Float, _Vector3, _Color);
typedef _DrawModelPointsExDart = void Function(_Model, _Vector3, _Vector3, double, _Vector3, _Color);
final _drawModelPointsEx = _dylib.lookupFunction<_DrawModelPointsExRay, _DrawModelPointsExDart>('DrawModelPointsEx');

typedef _DrawBoundingBoxRay = Void Function(_BoundingBox, _Color);
typedef _DrawBoundingBoxDart = void Function(_BoundingBox, _Color);
final _drawBoundingBox = _dylib.lookupFunction<_DrawBoundingBoxRay, _DrawBoundingBoxDart>('DrawBoundingBox');

typedef _DrawBillboardRay = Void Function(_Camera, _Texture2D, _Vector3, Float, _Color);
typedef _DrawBillboardDart = void Function(_Camera, _Texture2D, _Vector3, double, _Color);
final _drawBillboard = _dylib.lookupFunction<_DrawBillboardRay, _DrawBillboardDart>('DrawBillboard');

typedef _DrawBillboardRecRay = Void Function(_Camera, _Texture2D, _Rectangle, _Vector3, _Vector2, _Color);
typedef _DrawBillboardRecDart = void Function(_Camera, _Texture2D, _Rectangle, _Vector3, _Vector2, _Color);
final _drawBillboardRec = _dylib.lookupFunction<_DrawBillboardRecRay, _DrawBillboardRecDart>('DrawBillboardRec');

typedef _DrawBillboardProRay = Void Function(_Camera, _Texture2D, _Rectangle, _Vector3, _Vector3, _Vector2, _Vector2, Float, _Color);
typedef _DrawBillboardProDart = void Function(_Camera, _Texture2D, _Rectangle, _Vector3, _Vector3, _Vector2, _Vector2, double, _Color);
final _drawBillboardPro = _dylib.lookupFunction<_DrawBillboardProRay, _DrawBillboardProDart>('DrawBillboardPro');

// typedef _SetModelMeshMaterialRay = Void Function(Pointer<Model>, Int32, Int32);
// typedef _SetModelMeshMaterialDart = void Function(Pointer<Model>, int, int);
// final _setModelMeshMaterial = _dylib.lookupFunction<_SetModelMeshMaterialRay, _SetModelMeshMaterialDart>('SetModelMeshMaterial');

