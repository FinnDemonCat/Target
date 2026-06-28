part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                     Text
//------------------------------------------------------------------------------------
class Text implements Disposeable {
  final _buffer = StringBuffer();
  late Pointer<Uint8> _array;
  int _length = 1024;
  bool _isDirt = true;

  int get length => _length;
  StringBuffer get text { _isDirt = true; return _buffer; }

  void _EnsureCapacity(int size)
  {
    final int required = size + 1;
    if (required <= length) return;

    int newlength = length;
    while(newlength < size) newlength *= 2;

    _finalizer.detach(this);
    malloc.free(_array);

    _length = newlength;
    _array = malloc.allocate<Uint8>(sizeOf<Uint8>() * newlength);

    _finalizer.attach(this, _array, detach: this);
  }
  
  Pointer<Utf8> get ref
  {
    if (_isDirt) {
      final units = utf8.encode(_buffer.toString());
      _EnsureCapacity(units.length);
      _array.asTypedList(_length).setAll(0, units);
      _array[units.length] = 0;
      _isDirt = false;
    }

    return _array.cast<Utf8>();
  }

  Text(String text) {
    _buffer.write(text);

    _array = malloc.allocate<Uint8>(sizeOf<Uint8>() * length);
    _finalizer.attach(this, _array, detach: this);
  }

  /// Draw current FPS
  static void DrawFPS(int posX, int posY) => _drawFPS(posX, posY);

  /// Draw text (using default font)
  static void Draw(Text text, int fontSize, { int posX = 0, int posY = 0, Color? color })
  {
    final finalColor = color ?? Color.WHITE;
    _drawText(text.ref, posX, posY, fontSize, finalColor.ref);
  }

  /// Draw text using font and additional parameters
  static void DrawEx(Font font, Text text,{ Vector2? position, required double fontSize, required double spacing, Color? tint })
  {
    final finalPos = position ?? Vector2.Zero();
    final colorTint = tint ?? Color.WHITE;
    _drawTextEx(font.ref, text.ref, finalPos.ref, fontSize, spacing, colorTint.ref); 
  }

  /// Draw text using Font and pro parameters (rotation)
  static void DrawPro(
    Font font, Text text,
    {Vector2? position, Vector2? origin,
     double rotation = 0.0, required double fontSize,
     required double spacing, Color? tint}
  ) {
    final finalPos = position ?? Vector2.Zero();
    final finalOrigin = origin ?? Vector2.Zero();
    final colorTint = tint ?? Color.WHITE;

    _drawTextPro(
      font.ref, text.ref, finalPos.ref, finalOrigin.ref,
      rotation, fontSize, spacing, colorTint.ref
    ); 
  }

  /// Open URL with default system browser (if available)
  static void OpenUrl(Text url) => _openURL(url.ref);

  static final Finalizer _finalizer = Finalizer<Pointer<Utf8>>((ptr) {
    malloc.free(ptr);
  });

  @override
  void Free()
  {
    _finalizer.detach(this);
    _length = 1024;
    malloc.free(_array);
    _isDirt = true;
  }
}

class TextCodepoint implements Disposeable {
  Int32List _buffer;
  Int32List get buffer => _buffer;

  late Pointer<Int32> _codepoints;
  Pointer<Int32> get codepoints {
    if (_isDirty) {
      malloc.free(_codepoints);
      _codepoints = malloc.allocate<Int32>(sizeOf<Int32>() * _capacity);

      _codepoints.asTypedList(_length).setAll(0, buffer.sublist(0, _length));
      _codepoints[_length] = 0;
      _isDirty = false;
    }

    return _codepoints;
  }

  int _length = 0;
  int get length => _length;

  int _capacity;
  int get capacity => _capacity;

  bool _isDirty = true;

  String get text => String.fromCharCodes(_buffer.sublist(0, _length));
  set text(String value) {
    if (value.length >= capacity) {
      int newCapacity = _capacity;
      while (newCapacity < value.length)
        newCapacity *= 2;
      
      _capacity = newCapacity;
      
      final newBuffer = Int32List(newCapacity)..setAll(0, value.runes);
      _buffer = newBuffer;
    } else {
      _buffer.setAll(0, value.runes);
    }

    _length = value.length;
    _isDirty = true;
  }

  TextCodepoint({int capacity = 64}) :
    _capacity = capacity,
    _codepoints = malloc.allocate<Int32>(sizeOf<Int32>() * capacity),
    _buffer = Int32List(capacity),
    _length = 0 {
    _finalizer.attach(this, _codepoints, detach: this);
  }

  factory TextCodepoint.fromString(String text) {
    final textCodepoint = TextCodepoint(capacity: text.length + 8);
    textCodepoint.text = text;
    return textCodepoint;
  }

  /// Draw one character (codepoint)
  static void DrawCodepoint(
    Font font, int codepoint,
   {Vector2? position, required double fontSize, Color? tint}
  ) {
    final finalPos = position ?? Vector2.Zero();
    final finalTint = tint ?? Color.WHITE;

    _drawTextCodepoint(font.ref, codepoint, finalPos.ref, fontSize, finalTint.ref);
  }

  /// Draw multiple character (codepoint)
  static void DrawCodepoints(
    Font font, TextCodepoint codepoints, int length, {
    required double fontSize, required double spacing, Vector2? position, Color? tint,
    int index = 0
  }) {
    final finalPos = position ?? Vector2.Zero();
    final finalTint = Color.WHITE;

    _drawTextCodepoints(
      font.ref,
      codepoints.codepoints + index,
      math.min(length, codepoints.length),
      finalPos.ref,
      fontSize,
      spacing,
      finalTint.ref
    );
  }

  static final Finalizer _finalizer = Finalizer<Pointer<Int32>>((ptr) {
    malloc.free(ptr);
  });

  @override
  void Free() {
    malloc.free(_codepoints);
    _finalizer.detach(this);
  }
}
