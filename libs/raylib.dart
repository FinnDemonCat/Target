library raylib;

import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:math' as math;
part 'raylib_bindings.dart';

//------------------------------------------------------------------------------------
/// Module Functions Definition - Vector2 math
//------------------------------------------------------------------------------------
class Vector2 implements Disposeable
{
	NativeResource<_Vector2>? _memory;

	void _setmemory(_Vector2 result)
	{
    if (_memory != null) dispose();

    Pointer<_Vector2> pointer = malloc.allocate<_Vector2>(sizeOf<_Vector2>());
    _memory = NativeResource(pointer);

    _finalizer.attach(this, pointer, detach: this);
  }

  double get x { return _memory!.pointer.ref.x; }
  double get y { return _memory!.pointer.ref.y; }
  set x (double value) { _memory!.pointer.ref.x = value; }
  set y (double value) { _memory!.pointer.ref.y = value; }

  _Vector2 get vector => _memory!.pointer.ref;

  /// Set `x` and `y`  at once
  void Set(double x, double y) { this.x = x; this.y = y; }

  /// Vector with components of value x and y. Defaults to 0.0 and 0.0
  Vector2([double x = 0.0, double y = 0.0])
  {
    Pointer<_Vector2> pointer = malloc.allocate<_Vector2>(sizeOf<_Vector2>());

    pointer.ref
    ..x = x
    ..y = y;

    _memory = NativeResource<_Vector2>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  /// Vector with components value 0.0f
  factory Vector2.Zero() => Vector2();

  /// Vector with components value 1.0f
  factory Vector2.One() => Vector2(1.0, 1.0);

  /// Get max value for each pair of components
  /// 
  /// Developer Note: This method returns a new instance of Vecto2
  static Vector2 Max(Vector2 v1, Vector2 v2) => Vector2(math.max(v1.x, v2.x));

  /// Calculate two vectors dot product
  static double Dot(Vector2 v1, Vector2 v2) => (v1.x * v2.x) + (v1.y * v2.y);

  /// Calculate two vectors cross product
  static double Cross(Vector2 v1, Vector2 v2) => (v1.x * v2.x) - (v1.y * v2.y); 

  /// Calculate reflected vector to normal
  static Vector2 Reflect(Vector2 v, Vector2 normal)
  {
    double dotProduct = (v.x * normal.x) + (v.y * normal.y);

    return Vector2(
      v.x - (2.0 * normal.x) * dotProduct,
      v.y - (2.0 * normal.y) * dotProduct
    );
  }
  
  /// Check whether two given vectors are almost equal
  static bool Equals(Vector2 p, Vector2 q)
  {
    return ((p.x - q.x).abs() <= (EPSILON * math.max(1.0, math.max(p.x.abs(), q.x.abs())))) &&
                ((p.y - q.y).abs() <= (EPSILON * math.max(1.0, math.max(p.y.abs(), q.y.abs()))));
  }

  /// Compute the direction of a refracted ray
  /// 
  /// v: normalized direction of the incoming ray
  /// 
  /// n: normalized normal vector of the interface of two optical media
  /// 
  /// r: ratio of the refractive index of the medium from where the ray comes
  /// 
  /// to the refractive index of the medium on the other side of the surface
  Vector2 Refract(Vector2 v, Vector2 n, double r)
  {
    Vector2 result = Vector2.Zero();

    double dot = (v.x * v.x) + (v.y * v.y);
    double d = 1.0 - r * r * (1.0 - dot * dot);

    if (d >= 0)
    {
      d = math.sqrt(d);
      result.x = r * v.x - (r * dot + d) * n.x;
      result.y = r * v.y - (r * dot + d) * n.y;
    }

    return result;
  }
  
  static final Finalizer _finalizer = Finalizer<Pointer<_Vector2>>((pointer) {
    if (pointer.address == 0) return;

    malloc.free(pointer);
  });
  
  @override
  void dispose() {
    if(_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

/// **Performance Note:** Performed *in-place* to prevent GC pressure 
/// and avoid redundant `malloc` calls in the loop.
///
/// * **Address:** Remains constant.
/// * **Memory:** Zero new allocations.
extension Vector2Math on Vector2
{
  /// Add two vectors (v1 + v2)
  void operator +(Vector2 other) { this.x + other.x; this.y + other.y; }
  
  /// Subtract two vectors (v1 - v2)
  void operator -(Vector2 other) { this.x - other.x; this.y - other.y; }

  /// Subtract vector by float value
  void SubractValue(double sub) { this.x -= sub; this.y -= sub; }

  /// Calculate vector length
  double Length() => math.sqrt((this.x * this.x) + (this.y + this.y));

  /// Calculate vector square length
  double LengthSqr() => ((this.x * this.x) + (this.y + this.y));

  /// Calculate distance between two vectors
  double Distance(Vector2 v2)
  {
	  return math.sqrt((this.x - v2.x) * (this.x - v2.x)) + ((this.y - v2.y) + (this.y - v2.y));
  }

  /// Calculate square distance between two vectors
  double DistanceSqr(Vector2 v2)
  {
	  return ((this.x - v2.x) * (this.x - v2.x)) + ((this.y - v2.y) + (this.y - v2.y));
  }

  /// Calculate the signed angle from this to v2, relative to the origin (0, 0)
  ///
  /// NOTE: Coordinate system convention: positive X right, positive Y down
  ///
  /// positive angles appear clockwise, and negative angles appear counterclockwise
  double Angle(Vector2 v2)
  {
    double dot = (this.x * v2.x) + (this.y * v2.y);
    double det = (this.x * v2.y) - (this.y * v2.x);

    return math.atan2(det, dot);
  }

  /// Calculate angle defined by a two vectors line
  ///
  /// NOTE: Parameters need to be normalized
  /// 
  /// DEVELOPER NOTE: Calculates LineAngle with `this` as start and `arg` as end
  ///
  /// Current implementation should be aligned with glm::angle
  double LineAngle(Vector2 end) => -math.atan2(end.y - this.y, end.x - this.x);
  
  /// Scale vector (multiply by value)
  void Scale(double value) { this.x *= value; this.y *= value; }

  /// Multiply `this` vector by `arg` vector
  void Multiply(Vector2 v2) { this.x * v2.x; this.y * v2.y; }

  /// Negate `this` vector
  void Negate() { this.x *= -1; this.y *= -1; }

  /// Divide `this` vector by `arg` vector
  void Divide(Vector2 value) { this.x /= value.x; this.y /= value.y; }

  /// Transforms a Vector2 by a given Matrix
  void Transform() {}

  /// Calculate linear interpolation between two vectors
  /// 
  /// Developer Note: For memory persistance, this extension modifies `this` to be the result of LERP of `v1`, `v2` and `ammount`
  void LerpOf(Vector2 v1, Vector2 v2, double ammount)
  {
    this.x = v1.x + ammount * (v2.x - v1.x);
    this.y = v1.y + ammount * (v2.y - v1.y);
  }

  /// Rotate vector by angle
  void Rotate(double angle)
  {
    double cosresult = math.cos(angle);
    double sinresult = math.sin(angle);

    this.x = (this.x * cosresult - this.y * sinresult);
    this.y = (this.x * sinresult + this.y * cosresult);
  }

  /// Move Vector towards target
  void MoveTowards(Vector2 target, double maxDistance)
  {
    double dx = target.x - this.x;
    double dy = target.y - this.y;
    double value = (dx * dx) + (dy * dy);

    if ((value == 0) || (maxDistance >= 0) && (value <= maxDistance * maxDistance)) return;

    double dist = math.sqrt(value);

    this.x = this.x + dx / dist * maxDistance;
    this.y = this.y + dy / dist * maxDistance;
  }

  void Invert()
  {
    this.x = 1.0 / this.x;
    this.y = 1.0 / this.y;
  }

  /// Clamp the components of the vector between
  ///
  /// min and max values specified by the given vectors
  void Clamp(Vector2 min, Vector2 max)
  {
    this.x = math.min(max.x, math.max(min.x, this.x));
    this.y = math.min(max.y, math.max(min.y, this.y));
  }

  /// Clamp the magnitude of the vector between two min and max values
  void ClampValue(double min, double max)
  {
    double length = (this.x * this.x) + (this.y * this.y);
    if (length > 0.0)
    {
      length = math.sqrt(length);
      double scale = 1.0;

      if (length < min)
      {
        scale = min/length;
      }
      else if (length > max)
      {
        scale = max/length;
      }

      this.x = this.x * scale;
      this.y = this.y * scale;
    }
  }
}

//------------------------------------------------------------------------------------
//                                  Rectangle
//------------------------------------------------------------------------------------

/// Rectangle, 4 components
class Rectangle implements Disposeable
{
  NativeResource<_Rectangle>? _memory;

  // ignore: unused_element
  void _setMemory(_Rectangle result)
  {
    Pointer<_Rectangle> pointer = malloc.allocate<_Rectangle>(sizeOf<_Rectangle>());
    pointer.ref = result;


    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Rectangle>(pointer);
  }

  _Rectangle get rect => _memory!.pointer.ref;

  Rectangle([double x = 0.0, double y = 0.0, double width = 0.0, double height = 0.0])
  {
    Pointer<_Rectangle> pointer = malloc.allocate<_Rectangle>(sizeOf<_Rectangle>());
    pointer.ref
    ..x = x
    ..y = y
    ..width = width
    ..height = height;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Rectangle>(pointer);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Rectangle>>((pointer)
  {
    malloc.free(pointer);
  });
  
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                   Window
//------------------------------------------------------------------------------------

/// Window-related functions
abstract class Window
{
  // Initialize window and OpenGL context
  static void Init({required int width, required int height, required String title})
  {
    using ((Arena arena) {
      final cTitle = title.toNativeUtf8(allocator: arena);

      _initWindow(width, height, cTitle);
    });
  }
  /// Close window and unload OpenGL context
  static void Close() => _closeWindow();            
  /// Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)      
  static bool ShouldClose() => _windowShouldClose();
  /// Check if window has been initialized successfully
  static bool IsReady() => _isWindowReady();
  /// Check if window is currently fullscreen
  static bool IsFullScreen() => _isFullScreen();
  /// Check if window is currently hidden
  static bool IsHidden() => _isHidden();
  /// Check if window is currently minimized
  static bool IsMinimized() => _isMinimized();
  /// Check if window is currently maximized
  static bool IsMaximized() => _isMaximized();
  /// Check if window is currently focused
  static bool IsFocused() => _isFocused();
  /// Check if window has been resized last frame
  static bool IsResized() => _isResized();
  /// Check if one specific window flag is enabled
  /// 
  /// The parameter `flag` expects a ConfigFlags value
  static bool IsState(int flag) => _isWindowState(flag) != 0;
  /// Set window configuration state using flags
  /// 
  /// The parameter `flag` expects a ConfigFlags value
  static void SetState(int flag) => _setWindowState(flag);
  /// Clear window configuration state flags
  /// 
  /// The parameter `flag` expects a ConfigFlags value
  static void ClearState(int flag) => _clearWindowState(flag);
  /// Toggle window state: fullscreen/windowed, resizes monitor to match window resolution
  static void ToggleFullscreen() => _toggleFullscreen();
  /// Toggle window state: borderless windowed, resizes window to match monitor resolution
  static void ToggleBorderlessWindowed() => _toggleBorderlessWindowed();
  /// Set window state: maximized, if resizable
  static void Maximize() => _maximizeWindow();
  /// Set window state: minimized, if resizable
  static void Minimize() => _minimizeWindow();
  /// Restore window from being minimized/maximized
  static void Restore() => _restoreWindow();
  /// Set icon for window (single image, RGBA 32bit)
  static void SetIcon(Image image) => _setWindowIcon(image.image);
  /// Set icon for window (multiple images, RGBA 32bit)
  static void SetIcons(List<Image> images)
  {
    using((Arena arena) {
      Pointer<_Image> ref = arena.allocate<_Image>(sizeOf<_Image>() * images.length);

      for(int x = 0; x < images.length; x++)
        ref[x] = images[x].image;

      _setWindowIcons(ref, images.length);      
    });
  }
  /// Set title for window
  static void SetTitle(String title)
  {
    using((Arena arena) {
      Pointer<Utf8> pointer = title.toNativeUtf8(allocator: arena);

      _setWindowTitle(pointer);
    });
  }

  /// Set window position on screen
  static void SetPosition(int x, int y) => _setWindowPosition(x, y);
  /// Set monitor for the current window
  static void SetMonitor(int monitor) => _setWindowMonitor(monitor);
  /// Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
  static void SetMinSize(int width, int height) => _setWindowMinSize(width, height);
  /// Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)
  static void SetMaxSize(int width, int height) => _setWindowMaxSize(width, height);
  /// Set window dimensions
  static void SetSize(int width, int height) => _setWindowSize(width, height);
  /// Set window opacity [0.0f..1.0f]
  static void SetOpacity(double opacity) => _setWindowOpacity(opacity);
  /// Set window focused
  static void SetFocused() => _setWindowFocused();
  /// Get native window handle
  static Pointer<Void> GetHandle() => _getWindowHandle();
  /// Get current screen width
  static int Width() => _getScreenWidth();
  /// Get current screen height
  static int Height() => _getScreenHeight();
  /// Get current render width (it considers HiDPI)
  static int RenderWidth() => _getRenderWidth();
  /// Get current render height (it considers HiDPI)
  static int RenderHeight() => _getRenderHeight();
  /// Get number of connected monitors
  static int GetMonitorCount() => _getMonitorCount();
  /// Get specified monitor position
  static int GetCurrentMonitor() => _getCurrentMonitor();
  /// Get specified monitor position
  static Vector2 GetMonintorPosition(int monitor)
  {
    Vector2 position = Vector2();
    position._setmemory(_getMonitorPosition(monitor));

    return position;
  }
  /// Get specified monitor width (current video mode used by monitor)
  static int GetMonitorWidth(int monitor) => _getMonitorWidth(monitor);
  /// Get specified monitor height (current video mode used by monitor)
  static int GetMonitorHeight(int monitor) => _getMonitorHeight(monitor);
  /// Get specified monitor physical width in millimetres
  static int GetMonitorPhysicalWidth(int monitor) => _getMonitorPhysicalWidth(monitor);
  /// Get specified monitor physical height in millimetres
  static int GetMonitorPhysicalHeight(int monitor) => _getMonitorPhysicalHeight(monitor);
  /// Get specified monitor refresh rate
  static int GetMonitorRefreshRate(int monitor) => _getMonitorRefreshRate(monitor);
  /// Get window position XY on monitor
  static Vector2 GetPosition()
  {
    Vector2 position = Vector2();
    position._setmemory(_getWindowPosition());

    return position;
  }
  /// Get window scale DPI factor
  static Vector2 GetScaleDPI()
  {
    Vector2 position = Vector2();
    position._setmemory(_getWindowScaleDPI());
    
    return position;
  }
  /// Get the human-readable, UTF-8 encoded name of the specified monitor
  static String GetMonitorName(int monitor) => _getMonitorName(monitor).toDartString();
  /// Set clipboard text content
  static void SetClipboardText(String text)
  {
    using((Arena arena) {
      Pointer<Utf8> cText = text.toNativeUtf8(allocator: arena);

      _setClipboardText(cText);
    });
  }
  /// Get clipboard text content
  static String GetClipboardText() => _getClipboardText().toDartString();
  /// Get clipboard image content
  static Image GetClipboardImage() => Image._Recieve(_getClipboardImage());
  /// Enable waiting for events on EndDrawing(), no automatic event polling
  static void EnableEventWaiting() => _enableEventWaiting();
  /// Disable waiting for events on EndDrawing(), automatic events polling
  static void DisabelEventWaiting() => _disableEventWaiting();
}

//------------------------------------------------------------------------------------
//                                   Cursor
//------------------------------------------------------------------------------------

abstract class Cursor
{
  /// Shows cursor
  static void Show() => _showCursor();
  /// Hides cursor
  static void Hide() => _hideCursor();
  /// Check if cursor is not visible
  static bool IsHidden() => _isCursorHidden();
  /// Enables cursor (unlock cursor)
  static void Enable() => _enableCursor();
  /// Disables cursor (lock cursor)
  static void Disable() => _disableCursor();
  /// Check if cursor is on the screen
  static bool IsOnScreen() => _isCursorOnScreen();
}

//------------------------------------------------------------------------------------
//                                   Frame
//------------------------------------------------------------------------------------

/// Timing-related functions
abstract class Frame
{
  /// Set target FPS (maximum)
  static void SetTargetFPS(int fps) => _setTargetFPS(fps);
  /// Get time in seconds for last frame drawn (delta time)
  static double GetFrameTime() => _getFrameTime();
  /// Get elapsed time in seconds since InitWindow()
  static double GetTime() => _getTime();
  /// Get current FPS
  static int GetFPS() => _getFPS();
}

//------------------------------------------------------------------------------------
//                                   Color
//------------------------------------------------------------------------------------

class Color implements Disposeable
{
  NativeResource<_Color>? _memory;

  // ignore: unused_element
  _setMemory(_Color result)
  {
    Pointer<_Color> pointer = malloc.allocate<_Color>(sizeOf<_Color>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource(pointer);
  }

  _Color get color => _memory!.pointer.ref;

  static final Color LIGHTGRAY  = Color(200, 200, 200, 255);
  static final Color GRAY       = Color(130, 130, 130, 255);
  static final Color DARKGRAY   = Color( 80,  80,  80, 255);
  static final Color YELLOW     = Color( 53, 249,   0, 255);
  static final Color GOLD       = Color(255, 203,   0, 255);
  static final Color ORANGE     = Color(255, 161,   0, 255);
  static final Color PINK       = Color(255, 109, 194, 255);
  static final Color RED        = Color(230,  41,  55, 255);
  static final Color MAROON     = Color(190,  33,  55, 255);
  static final Color GREEN      = Color(  0, 228,  48, 255);
  static final Color LIME       = Color(  0, 158,  47, 255);
  static final Color DARKGREEN  = Color(  0, 117,  44, 255);
  static final Color SKYBLUE    = Color(102, 191, 255, 255);
  static final Color BLUE       = Color(  0, 121, 241, 255);
  static final Color DARKBLUE   = Color(  0,  82, 172, 255);
  static final Color VIOLET     = Color(135,  60, 190, 255);
  static final Color DARKPURPLE = Color(112,  31, 126, 255);
  static final Color BEIGE      = Color(211, 176, 131, 255);
  static final Color BROWN      = Color(127, 106,  79, 255);
  static final Color DARKBROWN  = Color( 76,  63,  47, 255);
  static final Color WHITE      = Color(255, 255, 255, 255);
  static final Color BLACK      = Color(  0,   0,   0, 255);
  static final Color BLANK      = Color(  0,   0,   0,   0); // Transparent
  static final Color RAYWHITE   = Color(245, 245, 245, 255);

  Color(int r, int g, int b, int a)
  {
    Pointer<_Color> pointer = malloc.allocate<_Color>(sizeOf<_Color>());
    pointer.ref
    ..r = r
    ..g = g
    ..b = b
    ..a = a;

    _memory = NativeResource<_Color>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }
  
  static final Finalizer _finalizer = Finalizer<Pointer<_Color>>((pointer)
  {
    if (pointer.address != 0)
    {
      malloc.free(pointer);
    }
  });
  
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                   Image
//------------------------------------------------------------------------------------

class Image implements Disposeable
{
  NativeResource<_Image>? _memory;
  int frameCount = 0;
  int fileSize = 0;

  void _setMemory(_Image result)
  {
    if (result.data.address == 0) throw Exception("[Dart] Could not load image!");
    if (_memory != null) dispose();

    // Allocating memory in C heap
    Pointer<_Image> pointer = malloc.allocate<_Image>(sizeOf<_Image>());
    pointer.ref = result;

    this._memory = NativeResource<_Image>(pointer);

    // Attaching the process to Dart Garbage Collector
    _finalizer.attach(this, pointer, detach: this);
  }

  int get width {
    if (_memory == null || _memory!.isDisposed) return 0;

    return _memory!.pointer.ref.width;
  }

  int get height {
    if (_memory == null || _memory!.isDisposed) return 0;

    return _memory!.pointer.ref.height;
  }

  int get format {
    if (_memory == null || _memory!.isDisposed) return 0;

    return _memory!.pointer.ref.format;
  }

  int get mipmaps {
    if (_memory == null || _memory!.isDisposed) return 0;

    return _memory!.pointer.ref.mipmaps;
  }

  _Image get image 
  {
    if (_memory == null) throw StateError("Null reference");
    return _memory!.pointer.ref;
  }

  Pointer<Void> get data {
    if (!IsValid()) return nullptr;
    return _memory!.pointer.ref.data;
  }

  Image._Recieve(_Image image)
  {
    _setMemory(image);
  }

  /// Load image from file into CPU memory (RAM)
  Image(String path)
  {
    Pointer<Utf8> cPath = path.toNativeUtf8();
    try {
      _setMemory(_loadImage(cPath));
    } finally {
      malloc.free(cPath);      
    }
  }

  /// Load image from RAW file data
  Image.Raw(String path, int width, int height, int format, int headerSize)
  {
    Pointer<Utf8> cPath = path.toNativeUtf8();
    try {
      _Image result = _loadImageRaw(cPath, width, height, format, headerSize);
      _setMemory(result);
    } finally {
      malloc.free(cPath);      
    }
  }

  /// Load image sequence from file (frames appended to image.data)
  Image.Anim(String path)
  {
    Pointer<Utf8> cPath = path.toNativeUtf8();
	  Pointer<Int32> frameCount = malloc.allocate<Int32>(sizeOf<Int32>());

    try {
      this.frameCount = frameCount.value;
      _Image result = _loadImageAnim(cPath, frameCount); 
      _setMemory(result);
    } finally {
      malloc.free(cPath);
      malloc.free(frameCount);
    }
  }

  /// Load image sequence from memory buffer
  Image.AnimFromMemory(String fileType, Uint8List bytes)
  {
    if (bytes.length == 0) throw Exception("[Dart] byte array passed is empty!");
    
    Pointer<Utf8> cFileType = fileType.toNativeUtf8();
	  Pointer<Int32> frameCount = malloc.allocate<Int32>(sizeOf<Int32>());

    // Transform byte list into a pointer to pass over C
    Pointer<Uint8> data = malloc.allocate<Uint8>(bytes.length);
    data.asTypedList(bytes.length).setAll(0, bytes);

    try {
      this.frameCount = frameCount.value;
      _Image result = _loadImageAnimFromMemory(cFileType, data, bytes.length, frameCount); 
      _setMemory(result);
    } finally {
      malloc.free(cFileType);
      malloc.free(frameCount);
      malloc.free(data);
    }
  }

  /// Load image from memory buffer, fileType refers to extension: i.e. '.png'
  Image.FromMemory(String fileType, Uint8List fileData, int dataSize)
  {
    Pointer<Utf8> cFileType = fileType.toNativeUtf8();
    Pointer<Uint8> data = malloc.allocate<Uint8>(dataSize);

    try {
      _Image result = _loadImageFromMemory(cFileType, data, dataSize);
      _setMemory(result);
    } finally {
      malloc.free(cFileType);
      malloc.free(data);
    }
  }

  /// Load image from GPU texture data
	//  Texture2D shadow class not yet implemented
	//  uncommment when done
  Image.LoadFromTexture(_Texture2D texture)
  {
    _Image result = _loadImageFromTexture(texture);
    _setMemory(result);
  }

  /// Load image from screen buffer and (screenshot)
  Image.FromScreen()
  {
    _Image result = _loadImageFromScreen();
    _setMemory(result);
  }

  // Check if an image is valid (data and parameters)
  bool IsValid()
  {
    if (_memory == null || _memory!.isDisposed) return false;

    return _isImageValid(this._memory!.pointer.ref);
  }
  
  /// Export image data to file, returns true on success
  bool Export(String fileName)
  {
    if(!IsValid()) return false;

    return using ((Arena arena) {
      Pointer<Utf8> cFileName = fileName.toNativeUtf8(allocator: arena);

      return _exportImage(_memory!.pointer.ref, cFileName);
    });
  }

  Uint8List ExportToMemory(String fileType)
  {
    return using ((Arena arena) {
      final cFiletype = fileType.toNativeUtf8(allocator: arena);
      final cFileSize = arena.allocate<Int32>(sizeOf<Int32>());

      final Pointer<Uint8> data = _exportImageToMemory(
        _memory!.pointer.ref,
        cFiletype,
        cFileSize
      ).cast<Uint8>();

      if (data.address == 0) return Uint8List(0);

      try {
        fileSize = cFileSize.value;
        final Uint8List result = Uint8List.fromList(data.asTypedList(fileSize));
        return result;
      } finally {
        malloc.free(cFiletype);
        malloc.free(cFileSize);
        // Not yet implemented
        // _unloadFileData(data);
      }
    });
  }

  bool ExportAsCode(String fileName)
  {
    if(!IsValid()) return false;

    return using((Arena arena) {
      Pointer<Utf8> cFileName = fileName.toNativeUtf8(allocator: arena);

      return _exportImageAsCode(_memory!.pointer.ref, cFileName);
    });
  }

  // Garbage Colector dispose reference
  static final Finalizer<Pointer<_Image>> _finalizer = Finalizer((ptr) 
  {
    if (ptr.address == 0) return;

    _unloadImage(ptr.ref);

    malloc.free(ptr);
  });
  
  /// Unload image from CPU memory (RAM)
  // Manual dispose
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadImage(_memory!.pointer.ref);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                   Texture
//------------------------------------------------------------------------------------

// ToDo: Update Rect
// In case Rectangle class was implemented, continue
class Texture2D implements Disposeable
{
	NativeResource<_Texture2D>? _memory;

	void _setmemory(_Texture2D result)
	{
		if(result.id == 0) throw Exception("[Dart] Couldn't load Texture2D!");
    if (_memory != null) dispose();

    // Allocating memory in C heap
    Pointer<_Texture2D> pointer = malloc.allocate<_Texture2D>(sizeOf<_Texture2D>());
    pointer.ref = result;
    this._memory = NativeResource<_Texture2D>(pointer);

    _finalizer.attach(this, pointer, detach: this);
	}

  // Used for TextureCubeMap constructor
  Texture2D._internal(_Texture struct)
  {
    _setmemory(struct);
  }

  _Texture2D get texture => _memory!.pointer.ref;

  /// Load texture from file into GPU memory (VRAM)
  Texture2D(String fileName)
  {
    Pointer<Utf8> cFileName = fileName.toNativeUtf8();

    try {
      _Texture2D result = _loadTexture(cFileName);
      _setmemory(result);
    } finally {
      malloc.free(cFileName);
    }
  }

  /// Load texture from image data
  Texture2D.FromImage(Image image)
  {
    if (image._memory == null) throw Exception("[Dart] Image passed is invalid!");

    _Texture2D result = _loadTextureFromImage(image._memory!.pointer.ref);
    _setmemory(result);
  }

  /// Check if a texture is valid (loaded in GPU)
  bool isValid()
  {
    if (_memory == null) return false;
    return _isTextureValid(_memory!.pointer.ref);
  }

  void Update(Pointer<Void> pixels)
  {
    if (!isValid()) return;
    _updateTexture(texture, pixels);
  }

  void UpdateRect(Rectangle rect, Pointer<Void> pixels)
  {
    if (!isValid()) return;
    _updateTextureRec(texture, rect.rect, pixels);
  }

  

  // Garbage collector setup
  static final Finalizer<Pointer<_Texture>> _finalizer = Finalizer((ptr)
  {
    if(ptr.address == 0) return;

    _unloadTexture(ptr.ref);

    malloc.free(ptr);
  });

  /// Unload texture from GPU memory (VRAM)
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadTexture(_memory!.pointer.ref);
      _memory!.dispose();
    }
  }
}

class TextureCubemap extends Texture2D
{
  TextureCubemap._internal(_Texture texture) : super._internal(texture);

  /// Load cubemap from image, multiple image cubemap layouts supported
  factory TextureCubemap(Image image, int layout)
  {
    _TextureCubemap result = _loadTextureCubemap(image._memory!.pointer.ref, layout);

    return TextureCubemap._internal(result);
  }
}

class RenderTexture2D implements Disposeable
{
  NativeResource<_RenderTexture2D>? _memory;

  _RenderTexture2D get ref => _memory!.pointer.ref;

	void _setmemory(_RenderTexture2D result)
	{
		if(result.id == 0) throw Exception("[Dart] Couldn't load Texture2D!");
    if (_memory != null) dispose();

    // Allocating memory in C heap
    Pointer<_RenderTexture2D> pointer = malloc.allocate<_RenderTexture2D>(sizeOf<_RenderTexture2D>());
    pointer.ref = result;
    this._memory = NativeResource<_RenderTexture2D>(pointer);

    _finalizer.attach(this, pointer, detach: this);
	}

  /// Load texture for rendering (framebuffer)
  RenderTexture2D(int width, int height)
  {
    _RenderTexture2D result = _loadRenderTexture(width, height);
    _setmemory(result);
  }

  /// Check if a render texture is valid (loaded in GPU)
  bool isValid()
  {
    if(_memory == null) return false;
    return _isRenderTextureValid(_memory!.pointer.ref);
  }
  
  // Garbage collector setup
  static final Finalizer<Pointer<_RenderTexture2D>> _finalizer = Finalizer((ptr)
  {
    if(ptr.address == 0) return;

    _unloadRenderTexture(ptr.ref);

    malloc.free(ptr);
  });

  /// Unload render texture from GPU memory (VRAM)
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadRenderTexture(_memory!.pointer.ref);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                   Camera2D
//------------------------------------------------------------------------------------

class Camera2D implements Disposeable
{
  NativeResource<_Camera2D>? _memory;

  _Camera2D get camera => _memory!.pointer.ref;

  Camera2D({
    required Vector2 offset,
    required Vector2 target,
    required double rotation,
    required double zoom
  }) {
    Pointer<_Camera2D> pointer = malloc.allocate<_Camera2D>(sizeOf<_Camera2D>());
    pointer.ref
    ..offset = offset.vector
    ..target = target.vector
    ..rotation = rotation
    ..zoom = zoom;

    _memory = NativeResource<_Camera2D>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Camera2D>>((pointer) {
    malloc.free(pointer);
  });
  
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

// Todo
class Camera3D implements Disposeable
{
  NativeResource<_Camera3D>? _memory;

  // Camera3D({
  //   required Vector3 offset,
  //   required Vector3 target,
  //   required double rotation,
  //   required double zoom
  // }) {
  //   Pointer<_Camera3D> pointer = malloc.allocate<_Camera3D>(sizeOf<_Camera3D>());
  //   pointer.ref
  //   ..
  // }

  static final Finalizer _finalizer = Finalizer<Pointer<_Camera3D>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                   Draw
//------------------------------------------------------------------------------------
/// Drawing-related functions
abstract class Draw
{
  /// Set background color (framebuffer clear color)
  static void ClearBackground(Color color) => _clearBackground(color.color);
  /// Setup canvas (framebuffer) to start drawing
  static void Begin() => _beginDrawing();
  /// End canvas drawing and swap buffers (double buffering)
  static void End() => _endDrawing();
  /// Update screen by calling `Begin()` `renderLogic()` and `End()` while also clearing the background
  static void RenderFrame({required void Function() renderLogic, required Color color})
  {
    Begin();
    ClearBackground(color);
    renderLogic();
    End();
  }

  /// Begin 2D mode with custom camera (2D)
  static void Begin2D(Camera2D camera) => _beginMode2D(camera.camera);
  /// Ends 2D mode with custom camera
  static void End2D() => _endMode2D();
  /// Update screen by calling `Begin2D()` `renderLogic()` and `End2D()` while also clearing the background
  static void RenderFrame2D({
    required void Function() renderLogic,
    required Camera2D camera,
    required Color color
  }) {
    Begin2D(camera);
    ClearBackground(color);
    renderLogic();
    End2D();
  }

  /// Begin drawing to render texture
  static void BeginTextureMode(RenderTexture2D render) => _beginTextureMode(render.ref);
  /// Ends drawing to render texture
  static void EndTextureMode() => _endTextureMode();
  /// Update screen by calling `BeginTextureMode()` `renderLogic()` and `EndTextureMode()` while also clearing the background
  static void RenderTextureFrame({
    required void Function() renderLogic,
    required RenderTexture2D render,
    required Color color
  }) {
    BeginTextureMode(render);
    ClearBackground(color);
    renderLogic();
    EndTextureMode();
  }
}
