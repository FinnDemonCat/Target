part of 'raylib.dart';

abstract interface class Disposeable
{
  void dispose();
}

// C memory resourcers manager class
class NativeResource<T extends NativeType> implements Disposeable {
  final Pointer<T> pointer;
  NativeResource(this.pointer);

  bool get isDisposed { return pointer.address == 0; }

  @override
  void dispose()
  {
    if (!isDisposed)
      malloc.free(this.pointer);
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
typedef Quaternion = _Vector4;

// Matrix, 4x4 components, column major, OpenGL style, right-handed
// ToDO: Implement native Raylib Matrix constructors inside struct
final class Matrix extends Struct
{
  @Float() external double m0; @Float() external double m4; @Float() external double m8;  @Float() external double m12;
  @Float() external double m1; @Float() external double m5; @Float() external double m9;  @Float() external double m13;
  @Float() external double m2; @Float() external double m6; @Float() external double m10; @Float() external double m14;
  @Float() external double m3; @Float() external double m7; @Float() external double m11; @Float() external double m15;
}

// Color, 4 components, R8G8B8A8 (32bit)
// Use Colors.NewColor to instantiate a new Color
final class Color extends Struct
{
  @Uint8() external int r;             // Color red value
  @Uint8() external int g;             // Color green value
  @Uint8() external int b;             // Color blue value
  @Uint8() external int a;             // Color alpha value
}

// Equivalent to typedef definitions of Default Raylib colors
// Default members's pointers are held on the class. Call dispose() to clean memory
/*
final class Colors implements Disposeable
{
  static final Pointer<Color> LIGHTGRAY  = NewColor(200, 200, 200, 255);
  static final Pointer<Color> GRAY       = NewColor(130, 130, 130, 255);
  static final Pointer<Color> DARKGRAY   = NewColor( 80,  80,  80, 255);
  static final Pointer<Color> YELLOW     = NewColor( 53, 249,   0, 255);
  static final Pointer<Color> GOLD       = NewColor(255, 203,   0, 255);
  static final Pointer<Color> ORANGE     = NewColor(255, 161,   0, 255);
  static final Pointer<Color> PINK       = NewColor(255, 109, 194, 255);
  static final Pointer<Color> RED        = NewColor(230,  41,  55, 255);
  static final Pointer<Color> MAROON     = NewColor(190,  33,  55, 255);
  static final Pointer<Color> GREEN      = NewColor(  0, 228,  48, 255);
  static final Pointer<Color> LIME       = NewColor(  0, 158,  47, 255);
  static final Pointer<Color> DARKGREEN  = NewColor(  0, 117,  44, 255);
  static final Pointer<Color> SKYBLUE    = NewColor(102, 191, 255, 255);
  static final Pointer<Color> BLUE       = NewColor(  0, 121, 241, 255);
  static final Pointer<Color> DARKBLUE   = NewColor(  0,  82, 172, 255);
  static final Pointer<Color> VIOLET     = NewColor(135,  60, 190, 255);
  static final Pointer<Color> DARKPURPLE = NewColor(112,  31, 126, 255);
  static final Pointer<Color> BEIGE      = NewColor(211, 176, 131, 255);
  static final Pointer<Color> BROWN      = NewColor(127, 106,  79, 255);
  static final Pointer<Color> DARKBROWN  = NewColor( 76,  63,  47, 255);
  static final Pointer<Color> WHITE      = NewColor(255, 255, 255, 255);
  static final Pointer<Color> BLACK      = NewColor(  0,   0,   0, 255);
  static final Pointer<Color> BLANK      = NewColor(  0,   0,   0,   0); // Transparent
  static final Pointer<Color> RAYWHITE   = NewColor(245, 245, 245, 255);

  static List<NativeResource> _allocs = [];

  static Pointer<Color> NewColor(int r, int g, int b, int a)
  {
    NativeResource<Color> placeholder = Color._create(r, g, b, a); 
    _allocs.add(placeholder);

    return placeholder.pointer;
  }

  @override
  void dispose() {
    for(NativeResource pointer in _allocs)
    {
      pointer.dispose();
    }
  }
}
*/
// Rectangle, 4 components
final class Rectangle extends Struct
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
final class NPatchInfo extends Struct
{
  external Rectangle source;  // Texture source rectangle
  @Int32() external int left;          // Left border offset
  @Int32() external int top;           // Top border offset
  @Int32() external int right;         // Right border offset
  @Int32() external int bottom;        // Bottom border offset
  @Int32() external int layout;        // Layout of the n-patch: 3x3, 1x3 or 3x1
}

// GlyphInfo, font characters glyphs info
final class GlyphInfo extends Struct
{
  @Int32() external int value;         // Character value (Unicode)
  @Int32() external int offsetX;       // Character offset X when drawing
  @Int32() external int offsetY;       // Character offset Y when drawing
  @Int32() external int advanceX;      // Character advance position X
  external _Image image;       // Character image data
}

// Font, font texture and GlyphInfo array data
final class Font extends Struct
{
  @Int32() external int baseSize;      // Base size (default chars height)
  @Int32() external int glyphCount;    // Number of glyph characters
  @Int32() external int glyphPadding;  // Padding around the glyph characters
  external _Texture texture;   // Texture atlas containing the glyphs
  external Rectangle recs;    // Rectangles in texture for the glyphs. It's a pointer by default on Raylib
  external GlyphInfo glyphs;  // Glyphs info data. It's a pointer by default on Raylib
}

// Camera, defines position/orientation in 3d space
final class Camera3D extends Struct
{
  external _Vector3 position;  // Camera position
  external _Vector3 target;    // Camera target it looks-at
  external _Vector3 up;        // Camera up vector (rotation over its axis)
  @Float() external double fovy;       // Camera field-of-view aperture in Y (degrees) in perspective, used as near plane height in world units in orthographic
  @Int32() external int projection;    // Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

typedef Camera = Camera3D;             // Camera type fallback, defaults to Camera3D

// Camera2D, defines position/orientation in 2d space
final class Camera2D extends Struct
{
  external _Vector2 offset;    // Camera offset (screen space offset from window origin)
  external _Vector2 target;    // Camera target (world space target point that is mapped to screen space offset)
  @Float() external double rotation;   // Camera rotation in degrees (pivots around target)
  @Float() external double zoom;       // Camera zoom (scaling around target), must not be set to 0, set to 1.0f for no scale
}

// Mesh, vertex data and vao/vbo
final class Mesh extends Struct
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
  external Pointer<Matrix> boneMatrices; // Bones animated transformation matrices
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
  external Color color;                // Material map color
  @Float() external double value;      // Material map value
}

// Material, includes shader and maps
final class Material extends Struct
{
  external Shader shader;              // Material shader
  external Pointer<MaterialMap> maps;  // Material maps array (MAX_MATERIAL_MAPS)
  @Array(4) external Array<Float> params; // Material generic parameters (if required)
}

// Transform, vertex transformation data
final class Transform extends Struct
{
  external _Vector3 translation;        // Translation
  external Quaternion rotation;        // Rotation
  external _Vector3 scale;              // Scale
}

// Bone, skeletal animation bone
final class BoneInfo extends Struct
{
  @Array(32) external Array<Uint8> name;// Bone name
  @Int32() external int parent;        // Bone parent
}

// Model, meshes, materials and animation data
final class Model extends Struct
{
  external Matrix transform;           // Local transform matrix

  @Int32() external int meshCount;     // Number of meshes
  @Int32() external int materialCount; // Number of materials
  external Pointer<Mesh> meshes;       // Meshes array
  external Pointer<Material> materials;// Materials array
  external Pointer<Int32> meshMaterial;// Mesh material number

  // Animation data
  @Int32() external int boneCount;     // Number of bones
  external Pointer<BoneInfo> bones;    // Bones information (skeleton)
  external Pointer<Transform> bindPose;// Bones base transformation (pose)
}

// ModelAnimation
final class ModelAnimation extends Struct
{
  @Int32() external int boneCount;     // Number of bones
  @Int32() external int frameCount;    // Number of animation frames
  external Pointer<BoneInfo> bones;    // Bones information (skeleton)
  external Pointer<Pointer<Transform>> framePoses; // Poses array by frame
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
final class BoundingBox extends Struct
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
  @Array(2) external Array<Matrix> projection;
  @Array(2) external Array<Matrix> viewOffset;
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
// System/Window config flags
// NOTE: Every bit registers one state (use it with bit masks)
// By default all flags are set to 0
abstract class ConfigFlags
{
  static const int FLAG_VSYNC_HINT         = 0x00000040;   // Set to try enabling V-Sync on GPU
  static const int FLAG_FULLSCREEN_MODE    = 0x00000002;   // Set to run program in fullscreen
  static const int FLAG_WINDOW_RESIZABLE   = 0x00000004;   // Set to allow resizable window
  static const int FLAG_WINDOW_UNDECORATED = 0x00000008;   // Set to disable window decoration (frame and buttons)
  static const int FLAG_WINDOW_HIDDEN      = 0x00000080;   // Set to hide window
  static const int FLAG_WINDOW_MINIMIZED   = 0x00000200;   // Set to minimize window (iconify)
  static const int FLAG_WINDOW_MAXIMIZED   = 0x00000400;   // Set to maximize window (expanded to monitor)
  static const int FLAG_WINDOW_UNFOCUSED   = 0x00000800;   // Set to window non focused
  static const int FLAG_WINDOW_TOPMOST     = 0x00001000;   // Set to window always on top
  static const int FLAG_WINDOW_ALWAYS_RUN  = 0x00000100;   // Set to allow windows running while minimized
  static const int FLAG_WINDOW_TRANSPARENT = 0x00000010;   // Set to allow transparent framebuffer
  static const int FLAG_WINDOW_HIGHDPI     = 0x00002000;   // Set to support HighDPI
  static const int FLAG_WINDOW_MOUSE_PASSTHROUGH = 0x00004000; // Set to support mouse passthrough only supported when FLAG_WINDOW_UNDECORATED
  static const int FLAG_BORDERLESS_WINDOWED_MODE = 0x00008000; // Set to run program in borderless windowed mode
  static const int FLAG_MSAA_4X_HINT       = 0x00000020;   // Set to try enabling MSAA 4X
  static const int FLAG_INTERLACED_HINT    = 0x00010000;   // Set to try enabling interlaced video format (for V3D)
}

// Trace log level
// NOTE: Organized by priority level
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

// Keyboard keys (US keyboard layout)
// NOTE: Use GetKeyPressed() to allow redefining required keys for alternative layouts
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

// Add backwards compatibility support for deprecated names
final int MOUSE_LEFT_BUTTON = MouseButton.MOUSE_BUTTON_LEFT.index;
final int MOUSE_RIGHT_BUTTON = MouseButton.MOUSE_BUTTON_RIGHT.index;
final int MOUSE_MIDDLE_BUTTON = MouseButton.MOUSE_BUTTON_MIDDLE.index;

// Mouse buttons
enum MouseButton {
  MOUSE_BUTTON_LEFT,                 // Mouse button left
  MOUSE_BUTTON_RIGHT,                // Mouse button right
  MOUSE_BUTTON_MIDDLE,               // Mouse button middle (pressed wheel)
  MOUSE_BUTTON_SIDE,                 // Mouse button side (advanced mouse device)
  MOUSE_BUTTON_EXTRA,                // Mouse button extra (advanced mouse device)
  MOUSE_BUTTON_FORWARD,              // Mouse button forward (advanced mouse device)
  MOUSE_BUTTON_BACK,                 // Mouse button back (advanced mouse device)
}

// Mouse cursor
enum MouseCursor {
  MOUSE_CURSOR_DEFAULT,              // Default pointer shape
  MOUSE_CURSOR_ARROW,                // Arrow shape
  MOUSE_CURSOR_IBEAM,                // Text writing cursor shape
  MOUSE_CURSOR_CROSSHAIR,            // Cross shape
  MOUSE_CURSOR_POINTING_HAND,        // Pointing hand cursor
  MOUSE_CURSOR_RESIZE_EW,            // Horizontal resize/move arrow shape
  MOUSE_CURSOR_RESIZE_NS,            // Vertical resize/move arrow shape
  MOUSE_CURSOR_RESIZE_NWSE,          // Top-left to bottom-right diagonal resize/move arrow shape
  MOUSE_CURSOR_RESIZE_NESW,          // The top-right to bottom-left diagonal resize/move arrow shape
  MOUSE_CURSOR_RESIZE_ALL,           // The omnidirectional resize/move cursor shape
  MOUSE_CURSOR_NOT_ALLOWED,          // The operation-not-allowed shape
}

// Gamepad buttons
enum GamepadButton {
  GAMEPAD_BUTTON_UNKNOWN,            // Unknown button, just for error checking
  GAMEPAD_BUTTON_LEFT_FACE_UP,       // Gamepad left DPAD up button
  GAMEPAD_BUTTON_LEFT_FACE_RIGHT,    // Gamepad left DPAD right button
  GAMEPAD_BUTTON_LEFT_FACE_DOWN,     // Gamepad left DPAD down button
  GAMEPAD_BUTTON_LEFT_FACE_LEFT,     // Gamepad left DPAD left button
  GAMEPAD_BUTTON_RIGHT_FACE_UP,      // Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
  GAMEPAD_BUTTON_RIGHT_FACE_RIGHT,   // Gamepad right button right (i.e. PS3: Circle, Xbox: B)
  GAMEPAD_BUTTON_RIGHT_FACE_DOWN,    // Gamepad right button down (i.e. PS3: Cross, Xbox: A)
  GAMEPAD_BUTTON_RIGHT_FACE_LEFT,    // Gamepad right button left (i.e. PS3: Square, Xbox: X)
  GAMEPAD_BUTTON_LEFT_TRIGGER_1,     // Gamepad top/back trigger left (first), it could be a trailing button
  GAMEPAD_BUTTON_LEFT_TRIGGER_2,     // Gamepad top/back trigger left (second), it could be a trailing button
  GAMEPAD_BUTTON_RIGHT_TRIGGER_1,    // Gamepad top/back trigger right (first), it could be a trailing button
  GAMEPAD_BUTTON_RIGHT_TRIGGER_2,    // Gamepad top/back trigger right (second), it could be a trailing button
  GAMEPAD_BUTTON_MIDDLE_LEFT,        // Gamepad center buttons, left one (i.e. PS3: Select)
  GAMEPAD_BUTTON_MIDDLE,             // Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
  GAMEPAD_BUTTON_MIDDLE_RIGHT,       // Gamepad center buttons, right one (i.e. PS3: Start)
  GAMEPAD_BUTTON_LEFT_THUMB,         // Gamepad joystick pressed button left
  GAMEPAD_BUTTON_RIGHT_THUMB         // Gamepad joystick pressed button right
}

// Gamepad axes
enum GamepadAxis {
  GAMEPAD_AXIS_LEFT_X,               // Gamepad left stick X axis
  GAMEPAD_AXIS_LEFT_Y,               // Gamepad left stick Y axis
  GAMEPAD_AXIS_RIGHT_X,              // Gamepad right stick X axis
  GAMEPAD_AXIS_RIGHT_Y,              // Gamepad right stick Y axis
  GAMEPAD_AXIS_LEFT_TRIGGE,          // Gamepad back trigger left, pressure level: [1..-1]
  GAMEPAD_AXIS_RIGHT_TRIGGER,        // Gamepad back trigger right, pressure level: [1..-1]
}

// Material map index
enum MaterialMapIndex {
  MATERIAL_MAP_ALBEDO,            // Albedo material (same as: MATERIAL_MAP_DIFFUSE)
  MATERIAL_MAP_METALNESS,         // Metalness material (same as: MATERIAL_MAP_SPECULAR)
  MATERIAL_MAP_NORMAL,            // Normal material
  MATERIAL_MAP_ROUGHNESS,         // Roughness material
  MATERIAL_MAP_OCCLUSION,         // Ambient occlusion material
  MATERIAL_MAP_EMISSION,          // Emission material
  MATERIAL_MAP_HEIGHT,            // Heightmap material
  MATERIAL_MAP_CUBEMAP,           // Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  MATERIAL_MAP_IRRADIANCE,        // Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  MATERIAL_MAP_PREFILTER,         // Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  MATERIAL_MAP_BRDF               // Brdf material
}

final int MATERIAL_MAP_DIFFUSE = MaterialMapIndex.MATERIAL_MAP_ALBEDO.index;
final int MATERIAL_MAP_SPECULAR = MaterialMapIndex.MATERIAL_MAP_METALNESS.index;

// Shader location index
enum ShaderLocationIndex {
  SHADER_LOC_VERTEX_POSITION,     // Shader location: vertex attribute: position
  SHADER_LOC_VERTEX_TEXCOORD01,   // Shader location: vertex attribute: texcoord01
  SHADER_LOC_VERTEX_TEXCOORD02,   // Shader location: vertex attribute: texcoord02
  SHADER_LOC_VERTEX_NORMAL,       // Shader location: vertex attribute: normal
  SHADER_LOC_VERTEX_TANGENT,      // Shader location: vertex attribute: tangent
  SHADER_LOC_VERTEX_COLOR,        // Shader location: vertex attribute: color
  SHADER_LOC_MATRIX_MVP,          // Shader location: matrix uniform: model-view-projection
  SHADER_LOC_MATRIX_VIEW,         // Shader location: matrix uniform: view (camera transform)
  SHADER_LOC_MATRIX_PROJECTION,   // Shader location: matrix uniform: projection
  SHADER_LOC_MATRIX_MODEL,        // Shader location: matrix uniform: model (transform)
  SHADER_LOC_MATRIX_NORMAL,       // Shader location: matrix uniform: normal
  SHADER_LOC_VECTOR_VIEW,         // Shader location: vector uniform: view
  SHADER_LOC_COLOR_DIFFUSE,       // Shader location: vector uniform: diffuse color
  SHADER_LOC_COLOR_SPECULAR,      // Shader location: vector uniform: specular color
  SHADER_LOC_COLOR_AMBIENT,       // Shader location: vector uniform: ambient color
  SHADER_LOC_MAP_ALBEDO,          // Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
  SHADER_LOC_MAP_METALNESS,       // Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
  SHADER_LOC_MAP_NORMAL,          // Shader location: sampler2d texture: normal
  SHADER_LOC_MAP_ROUGHNESS,       // Shader location: sampler2d texture: roughness
  SHADER_LOC_MAP_OCCLUSION,       // Shader location: sampler2d texture: occlusion
  SHADER_LOC_MAP_EMISSION,        // Shader location: sampler2d texture: emission
  SHADER_LOC_MAP_HEIGHT,          // Shader location: sampler2d texture: height
  SHADER_LOC_MAP_CUBEMAP,         // Shader location: samplerCube texture: cubemap
  SHADER_LOC_MAP_IRRADIANCE,      // Shader location: samplerCube texture: irradiance
  SHADER_LOC_MAP_PREFILTER,       // Shader location: samplerCube texture: prefilter
  SHADER_LOC_MAP_BRDF,            // Shader location: sampler2d texture: brdf
  SHADER_LOC_VERTEX_BONEIDS,      // Shader location: vertex attribute: boneIds
  SHADER_LOC_VERTEX_BONEWEIGHTS,  // Shader location: vertex attribute: boneWeights
  SHADER_LOC_BONE_MATRICES,       // Shader location: array of matrices uniform: boneMatrices
  SHADER_LOC_VERTEX_INSTANCE_TX   // Shader location: vertex attribute: instanceTransform
}

final int SHADER_LOC_MAP_DIFFUSE = ShaderLocationIndex.SHADER_LOC_MAP_ALBEDO.index;
final int SHADER_LOC_MAP_SPECULAR = ShaderLocationIndex.SHADER_LOC_MAP_METALNESS.index;

// Shader uniform data type
enum ShaderUniformDataType {
  SHADER_UNIFORM_FLOAT,           // Shader uniform type: float
  SHADER_UNIFORM_VEC2,            // Shader uniform type: vec2 (2 float)
  SHADER_UNIFORM_VEC3,            // Shader uniform type: vec3 (3 float)
  SHADER_UNIFORM_VEC4,            // Shader uniform type: vec4 (4 float)
  SHADER_UNIFORM_INT,             // Shader uniform type: int
  SHADER_UNIFORM_IVEC2,           // Shader uniform type: ivec2 (2 int)
  SHADER_UNIFORM_IVEC3,           // Shader uniform type: ivec3 (3 int)
  SHADER_UNIFORM_IVEC4,           // Shader uniform type: ivec4 (4 int)
  SHADER_UNIFORM_UINT,            // Shader uniform type: unsigned int
  SHADER_UNIFORM_UIVEC2,          // Shader uniform type: uivec2 (2 unsigned int)
  SHADER_UNIFORM_UIVEC3,          // Shader uniform type: uivec3 (3 unsigned int)
  SHADER_UNIFORM_UIVEC4,          // Shader uniform type: uivec4 (4 unsigned int)
  SHADER_UNIFORM_SAMPLER2D        // Shader uniform type: sampler2d
}

// Shader attribute data types
enum ShaderAttributeDataType {
  SHADER_ATTRIB_FLOAT,            // Shader attribute type: float
  SHADER_ATTRIB_VEC2,             // Shader attribute type: vec2 (2 float)
  SHADER_ATTRIB_VEC3,             // Shader attribute type: vec3 (3 float)
  SHADER_ATTRIB_VEC4              // Shader attribute type: vec4 (4 float)
}

// Pixel formats
// NOTE: Support depends on OpenGL version and platform
abstract class PixelFormat {
  static const int PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1;     // 8 bit per pixel (no alpha)
  static const int PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA = 2;    // 8*2 bpp (2 channels)
  static const int PIXELFORMAT_UNCOMPRESSED_R5G6B5 = 3;        // 16 bpp
  static const int PIXELFORMAT_UNCOMPRESSED_R8G8B8 = 4;        // 24 bpp
  static const int PIXELFORMAT_UNCOMPRESSED_R5G5B5A1 = 5;      // 16 bpp (1 bit alpha)
  static const int PIXELFORMAT_UNCOMPRESSED_R4G4B4A4 = 6;      // 16 bpp (4 bit alpha)
  static const int PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 = 7;      // 32 bpp
  static const int PIXELFORMAT_UNCOMPRESSED_R32 = 8;           // 32 bpp (1 channel - float)
  static const int PIXELFORMAT_UNCOMPRESSED_R32G32B32 = 9;     // 32*3 bpp (3 channels - float)
  static const int PIXELFORMAT_UNCOMPRESSED_R32G32B32A32 = 10; // 32*4 bpp (4 channels - float)
  static const int PIXELFORMAT_UNCOMPRESSED_R16 = 11;          // 16 bpp (1 channel - half float)
  static const int PIXELFORMAT_UNCOMPRESSED_R16G16B16 = 12;    // 16*3 bpp (3 channels - half float)
  static const int PIXELFORMAT_UNCOMPRESSED_R16G16B16A16 = 13; // 16*4 bpp (4 channels - half float)
  static const int PIXELFORMAT_COMPRESSED_DXT1_RGB = 14;       // 4 bpp (no alpha)
  static const int PIXELFORMAT_COMPRESSED_DXT1_RGBA = 15;      // 4 bpp (1 bit alpha)
  static const int PIXELFORMAT_COMPRESSED_DXT3_RGBA = 16;      // 8 bpp
  static const int PIXELFORMAT_COMPRESSED_DXT5_RGBA = 17;      // 8 bpp
  static const int PIXELFORMAT_COMPRESSED_ETC1_RGB = 18;       // 4 bpp
  static const int PIXELFORMAT_COMPRESSED_ETC2_RGB = 19;       // 4 bpp
  static const int PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA = 20;  // 8 bpp
  static const int PIXELFORMAT_COMPRESSED_PVRT_RGB = 21;       // 4 bpp
  static const int PIXELFORMAT_COMPRESSED_PVRT_RGBA = 22;      // 4 bpp
  static const int PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA = 23;  // 8 bpp
  static const int PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA = 24;  // 2 bpp
}

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification
enum TextureFilter {
  TEXTURE_FILTER_POINT,                   // No filter, just pixel approximation
  TEXTURE_FILTER_BILINEAR,                // Linear filtering
  TEXTURE_FILTER_TRILINEAR,               // Trilinear filtering (linear with mipmaps)
  TEXTURE_FILTER_ANISOTROPIC_4X,          // Anisotropic filtering 4x
  TEXTURE_FILTER_ANISOTROPIC_8X,          // Anisotropic filtering 8x
  TEXTURE_FILTER_ANISOTROPIC_16X,         // Anisotropic filtering 16x
}

// Texture parameters: wrap mode
enum TextureWrap {
  TEXTURE_WRAP_REPEAT,                    // Repeats texture in tiled mode
  TEXTURE_WRAP_CLAMP,                     // Clamps texture to edge pixel in tiled mode
  TEXTURE_WRAP_MIRROR_REPEAT,             // Mirrors and repeats the texture in tiled mode
  TEXTURE_WRAP_MIRROR_CLAMP               // Mirrors and clamps to border the texture in tiled mode
}

// Cubemap layouts
enum CubemapLayout {
  CUBEMAP_LAYOUT_AUTO_DETECT,             // Automatically detect layout type
  CUBEMAP_LAYOUT_LINE_VERTICAL,           // Layout is defined by a vertical line with faces
  CUBEMAP_LAYOUT_LINE_HORIZONTAL,         // Layout is defined by a horizontal line with faces
  CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR,     // Layout is defined by a 3x4 cross with cubemap faces
  CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE      // Layout is defined by a 4x3 cross with cubemap faces
}

// Font type, defines generation method
enum FontType {
  FONT_DEFAULT,                           // Default font generation, anti-aliased
  FONT_BITMAP,                            // Bitmap font generation, no anti-aliasing
  FONT_SDF                                // SDF font generation, requires external shader
}


// Color blending modes (pre-defined)
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

// Gesture
// NOTE: Provided as bit-wise flags to enable only desired gestures
abstract class  Gesture {
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

// Camera system modes
enum CameraMode {
  CAMERA_CUSTOM,                  // Camera custom, controlled by user (UpdateCamera() does nothing)
  CAMERA_FREE,                    // Camera free mode
  CAMERA_ORBITAL,                 // Camera orbital, around target, zoom supported
  CAMERA_FIRST_PERSON,            // Camera first person
  CAMERA_THIRD_PERSON             // Camera third person
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
  if (Platform.isWindows) return DynamicLibrary.open('raylib.dll');
  if (Platform.isLinux) return DynamicLibrary.open('raylib.so');
  if (Platform.isMacOS) return DynamicLibrary.open('raylib.dylib');

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
/* 
typedef _SetWindowIconRay = Void Function(Image);
typedef _SetWindowIconDart = void Function(Image);
final _setWindowIcon = _dylib.lookupFunction<_SetWindowIconRay, _SetWindowIconDart>('SetWindowIcon');

typedef _SetWindowIconsRay = Void Function(Pointer<Image>, Int32);
typedef _SetWindowIconsDart = void Function(Pointer<Image>, int);
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
*/

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

typedef _IsRenderTextureValidRay = Bool Function(_RenderTexture2D);
typedef _IsRenderTextureValidDart = bool Function(_RenderTexture2D);
final _isRenderTextureValid = _dylib.lookupFunction<_IsRenderTextureValidRay, _IsRenderTextureValidDart>('IsRenderTextureValid');

typedef _UnloadRenderTextureRay = Void Function(_RenderTexture2D);
typedef _UnloadRenderTextureDart = void Function(_RenderTexture2D);
final _unloadRenderTexture = _dylib.lookupFunction<_UnloadRenderTextureRay, _UnloadRenderTextureDart>('UnloadRenderTexture');

typedef _UpdateTextureRay = Void Function(_Texture2D, Pointer<Void>);
typedef _UpdateTextureDart = void Function(_Texture2D, Pointer<Void>);
final _updateTexture = _dylib.lookupFunction<_UpdateTextureRay, _UpdateTextureDart>('UpdateTexture');

typedef _UpdateTextureRecRay = Void Function(_Texture2D, Rectangle, Pointer<Void>);
typedef _UpdateTextureRecDart = void Function(_Texture2D, Rectangle, Pointer<Void>);
final _updateTextureRec = _dylib.lookupFunction<_UpdateTextureRecRay, _UpdateTextureRecDart>('UpdateTextureRec');

