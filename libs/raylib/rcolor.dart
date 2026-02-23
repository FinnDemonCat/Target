part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Color
//------------------------------------------------------------------------------------
class Color implements Disposeable
{
  NativeResource<_Color>? _memory;

  // Creates a new pointer in heap and copies the value  
  _setMemory(_Color result)
  {
    Pointer<_Color> pointer = malloc.allocate<_Color>(sizeOf<_Color>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Color>(pointer);
  }

  _Color get ref => _memory!.pointer.ref;
  set ref(_Color result) => _memory!.pointer.ref = result;

  static final Color LIGHTGRAY  = Color(200, 200, 200);
  static final Color GRAY       = Color(130, 130, 130);
  static final Color DARKGRAY   = Color( 80,  80,  80);
  static final Color YELLOW     = Color( 53, 249,   0);
  static final Color GOLD       = Color(255, 203,   0);
  static final Color ORANGE     = Color(255, 161,   0);
  static final Color PINK       = Color(255, 109, 194);
  static final Color RED        = Color(230,  41,  55);
  static final Color MAROON     = Color(190,  33,  55);
  static final Color GREEN      = Color(  0, 228,  48);
  static final Color LIME       = Color(  0, 158,  47);
  static final Color DARKGREEN  = Color(  0, 117,  44);
  static final Color SKYBLUE    = Color(102, 191, 255);
  static final Color BLUE       = Color(  0, 121, 241);
  static final Color DARKBLUE   = Color(  0,  82, 172);
  static final Color VIOLET     = Color(135,  60, 190);
  static final Color DARKPURPLE = Color(112,  31, 126);
  static final Color BEIGE      = Color(211, 176, 131);
  static final Color BROWN      = Color(127, 106,  79);
  static final Color DARKBROWN  = Color( 76,  63,  47);
  static final Color WHITE      = Color(255, 255, 255);
  static final Color BLACK      = Color(  0,   0,   0);
  static final Color BLANK      = Color(  0,   0,   0); // Transparent
  static final Color RAYWHITE   = Color(245, 245, 245);
  /* 
  Color._internal(Pointer<_Color> pointer,{ int length = 1, bool owner = true })
  {
    if (_memory != null) dispose();

    _memory = NativeResource<_Color>(pointer, IsOwner: owner);
    if (owner)
      _finalizer.attach(this, pointer, detach: this);
  }
   */
  Color._recieve(_Color result) { _setMemory(result); }

  Color(int r, int g, int b,{ int a = 255 })
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
  /// Get Color from normalized values [0..1]
  Color.FromNormalized(Vector4 normalized)
  {
    _Color result = _colorFromNormalized(normalized.ref);
    _setMemory(result);
  }
  /// Get a Color from HSV values, hue [0..360], saturation/value [0..1]
  Color.FromHSV(double hue, double saturation, double value)
  {
    _Color result = _colorFromHSV(hue, saturation, value);
    _setMemory(result);
  }
  /// Get Color structure from hexadecimal value
  Color.FromHex(int hex)
  {
    _Color result = _getColor(hex);
    _setMemory(result);
  }
  /// Get Color from a source pixel pointer of certain format
  Color.FromPointer(Pointer<Void> srcPtr, int format)
  {
    _Color result = _getPixelColor(srcPtr, format);
    _setMemory(result);
  }
  /// Set color formatted into destination pixel pointer
  static void SetPixelColor(Pointer<Void> dstPtr, Color color, int format) => _setPixelColor(dstPtr, color.ref, format);
  /// Get pixel data size in bytes for certain format
  static int GetPixelDataSize(int width, int height, int format) => _getPixelDataSize(width, height, format);
  
  /// Check if two colors are equal
  static bool IsEqual(Color col1, Color col2) => _colorIsEqual(col1.ref, col2.ref);
  /// Get color with alpha applied, alpha goes from 0.0f to 1.0f
  void Fade(double alpha) => _fade(ref, alpha);
  /// Get hexadecimal value for a Color (0xRRGGBBAA)
  int ToInt() => _colorToInt(ref);
  /// Get Color normalized as float [0..1]
  Vector4 Normalize() => Vector4._recieve(_colorNormalize(ref));
  /// Get HSV values for a Color, hue [0..360], saturation/value [0..1]
  Vector3 ToHSV() => Vector3._recieve(_colorToHSV(ref));
  /// Get color multiplied with another color
  void Tint(Color color, Color tint)
  {
    _Color result = _colorTint(color.ref, tint.ref);
    ref = result;
  }
  /// Get color with brightness correction, brightness factor goes from -1.0f to 1.0f (New Instance)
  void Brightness(double factor)
  {
    _Color result = _colorBrightness(ref, factor);
    ref = result;
  }
  /// Get color with contrast correction, contrast values between -1.0f and 1.0f
  void Contrast(double contrast)
  {
    _Color result = _colorContrast(ref, contrast);
    ref = result;
  }
  /// Get color with alpha applied, alpha goes from 0.0f to 1.0f
  void Alpha(double alpha)
  {
    _Color result = _colorAlpha(ref, alpha);
    ref = result;
  }
  /// Get src alpha-blended into dst color with tint
  void AlphaBlend(Color src, Color tint)
  {
    _Color result = _colorAlphaBlend(ref, src.ref, tint.ref);
    ref = result;
  }
  /// Get color lerp interpolation between two colors, factor [0.0f..1.0f]
  void Lerp(Color color2, double factor)
  {
    _Color result = _colorLerp(ref, color2.ref, factor);
    ref = result;
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
