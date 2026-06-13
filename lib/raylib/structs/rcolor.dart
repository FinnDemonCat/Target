part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   Color
//------------------------------------------------------------------------------------
class Color extends NativeWrapper<_Color>
{
  // NativeWrapper<_Color>? _memory;
  _Color get ref => pointer.ref;
  set ref(_Color result) => pointer.ref = result;

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
  static final Color BLANK      = Color(  0,   0,   0,  0); // Transparent
  static final Color RAYWHITE   = Color(245, 245, 245);
  
  // ignore: unused_element_parameter
  Color._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }
 
  Color._Recieve(_Color result) : super(sizeOf<_Color>()) {
    ref = result;
    _finalizer.attach(this, pointer, detach: this);
  }

  Color(int r, int g, int b,[ int a = 255, RaylibArena? arena ]) : super(sizeOf<_Color>(), arena: arena) {
    ref
      ..r = r
      ..g = g
      ..b = b
      ..a = a;

    _finalizer.attach(this, pointer, detach: this);
  }
  /// Get Color from normalized values [0..1]
  factory Color.FromNormalized(Vector4 normalized) {
    final result = _colorFromNormalized(normalized.ref);
    return Color._Recieve(result);
  }
  /// Get a Color from HSV values, hue [0..360], saturation/value [0..1]
  factory Color.FromHSV(double hue, double saturation, double value) {
    final result = _colorFromHSV(hue, saturation, value);
    return Color._Recieve(result);
  }
  /// Get Color structure from hexadecimal value
  factory Color.FromHex(int hex) {
    final result = _getColor(hex);
    return Color._Recieve(result);
  }
  /// Get Color from a source pixel pointer of certain format
  factory Color.FromPointer(Pointer<Void> srcPtr, int format) {
    final result = _getPixelColor(srcPtr, format);
    return Color._Recieve(result);
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
  Vector4 Normalize() => Vector4._Recieve(_colorNormalize(ref));
  /// Get HSV values for a Color, hue [0..360], saturation/value [0..1]
  Vector3 ToHSV() => Vector3._Recieve(_colorToHSV(ref));
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

  Color operator[](int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    return Color._Encapsulate(pointer + index, IsOwner: false);
  }

  void operator []=(Color value, int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    (pointer + index).ref = value.ref;
  }

  @override
  Iterable<Color> get values sync* {
    for (int x = 0; x < length; x++)
      yield this[x];
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Color>>((pointer) {
    malloc.free(pointer);
  });
  
  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}
