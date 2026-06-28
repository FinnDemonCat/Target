part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                    Font
//------------------------------------------------------------------------------------

class Font extends NativeWrapper<_Font> {
  _Font get ref => pointer.ref;
  set ref(_Font value) => pointer.ref = value;
  int get baseSize => ref.baseSize;
  int get glyphPadding => ref.glyphPadding;

  late final Texture texture;
  late final GlyphInfo glyphs;
  late final Rectangle recs;

  Font._Recieve(_Font result) : super(sizeOf<_Font>()) {
    ref = result;
    glyphs = GlyphInfo._Encapsulate(Pointer<_GlyphInfo>.fromAddress(result.glyphs.address), length: result.glyphCount, IsOwner: false);
    recs = Rectangle._Encapsulate(Pointer<_Rectangle>.fromAddress(result.recs.address), length: result.glyphCount, IsOwner: false);
    texture = Texture._Recieve(result.texture);
    _finalizer.attach(this, pointer, detach: this);
  }

  /// Get the default Font
  factory Font.Default([RaylibArena? arena]) {
    _Font result = _getFontDefault();
    Font font = Font._Recieve(result);
    arena?.register(font);
    return font;
  }

  /// Load font from file into GPU memory (VRAM)
  factory Font(String fileName,[ RaylibArena? arena ]) {
    _Font result;
    Pointer<Utf8> cfileName = fileName.toNativeUtf8();

    try {
      result = _loadFont(cfileName);
    }
    catch (error) {
      rethrow;
    }
    finally {
      malloc.free(cfileName);
    }
    
    Font font = Font._Recieve(result);
    arena?.register(font);
    return font;
  }

  /// Load font from file with extended parameters, use NULL for codepoints and 0 for codepointCount to load the default character set, font size is provided in pixels height
  factory Font.LoadEx(String fileName,{ required int fontSize, required List<int> codepoints, RaylibArena? arena }) {
    _Font result;
    Pointer<Utf8> cfileName = fileName.toNativeUtf8();
    Pointer<Int32> ccodepoints = malloc.allocate<Int32>(sizeOf<Int32>() * codepoints.length);
    ccodepoints.asTypedList(codepoints.length).setAll(0, codepoints);

    try {
      result = _loadFontEx(cfileName, fontSize, ccodepoints, codepoints.length);
    }
    catch(error) {
      rethrow;
    }
    finally {
      malloc.free(cfileName);
    }

    Font font = Font._Recieve(result);
    arena?.register(font);
    return font;
  }

  factory Font.FromImage(Image image, Color key, int firstChar,[ RaylibArena? arena ]) {
    final result = _loadFontFromImage(image.ref, key.ref, firstChar);
    Font font = Font._Recieve(result);
    arena?.register(font);
    return font;
  }

  /// Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  factory Font.FromMemory({
    required String fileType,
    required Uint8List fileData,
    required int fontsize,
    List<int>? codepoints,
    RaylibArena? arena
  }) {
    Pointer<Utf8> cfileType = fileType.toNativeUtf8();
    Pointer<Uint8> cfileData = malloc.allocate<Uint8>(sizeOf<Uint8>() * fileData.length);
    cfileData.asTypedList(fileData.length).setAll(0, fileData);

    Pointer<Int32> codepointsPtr;
    int codepointsCount = 0;
    if (codepoints != null) {
      codepointsCount = codepoints.length;

      codepointsPtr = malloc.allocate<Int32>(sizeOf<Int32>() * codepointsCount);
      codepointsPtr.asTypedList(codepointsCount).setAll(0, codepoints);
    }
    else
      codepointsPtr = nullptr;
    
    _Font result;
    try {
      result = _loadFontFromMemory(cfileType, cfileData, fileData.length, fontsize, codepointsPtr, codepointsCount);
    }
    catch(error) {
      rethrow;
    }
    finally {
      malloc.free(cfileData);
      malloc.free(cfileType);
    }

    Font font = Font._Recieve(result);
    arena?.register(font);
    return font;
  }

  /// Generate image font atlas using chars info
  Image GenAtlas({required int fontSize, required int padding, required int packMethod, RaylibArena? arena}) {
    _Image result = _genImageFontAtlas(
      glyphs.pointer,
      recs.pointer,
      glyphs.length,
      fontSize,
      padding,
      packMethod
    );

    Image image = Image._Recieve(result);
    arena?.register(image);
    return image;
  }

  /// Generate image font atlas using chars info
  GlyphInfo LoadFontData({
    required Uint8List fileData,
    required int fontSize,
    List<int>? codepoints,
    int type = 0
  }) {
    Pointer<Uint8> cfileData = malloc.allocate<Uint8>(fileData.length);
    Pointer<Int32> glyphCountPtr = malloc.allocate<Int32>(sizeOf<Int32>());

    cfileData.asTypedList(fileData.length).setAll(0, fileData);

    Pointer<Int32> codepointsPtr;
    int codepointsCount = 0;
    if (codepoints != null) {
      codepointsCount = codepoints.length;

      codepointsPtr = malloc.allocate<Int32>(sizeOf<Int32>() * codepointsCount);
      codepointsPtr.asTypedList(codepointsCount).setAll(0, codepoints);
    }
    else
      codepointsPtr = nullptr;
    
    GlyphInfo result;
    
    try {
      Pointer<_GlyphInfo> pointer = _loadFontData(
        cfileData,
        fileData.length,
        fontSize,
        codepointsPtr,
        codepointsCount,
        type,
        glyphCountPtr
      );
      result = GlyphInfo._Encapsulate(pointer, length: glyphCountPtr.value);
    }
    catch (error) {
      rethrow;
    }
    finally {
      malloc.free(cfileData);
      malloc.free(glyphCountPtr);
    }

    return result;
  }

  /// Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
  GlyphInfo GetGlyphInfo(int codepoint) {
    int index = _getGlyphIndex(ref, codepoint);
    return glyphs[index];
  }
  
  /// Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
  int GetGlyphIndex(int codepoint) => _getGlyphIndex(ref, codepoint);

  /// Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found
  Rectangle GetAtlasRec(int codepoint) {
    int index = _getGlyphIndex(ref, codepoint);
    return recs[index];
  }

  bool IsValid() => _isFontValid(ref);
  /// Export font as code file, returns true on success
  void ExportAsCode(String fileName) {
    using ((Arena arena) {
      Pointer<Utf8> cfileName = fileName.toNativeUtf8(allocator: arena);

      _exportFontAsCode(ref, cfileName);
    });
  }

  /// Measure string size for Font
  Vector2 MeasureText(Text text,{ required double fontSize, required double spacing }) {
    _Vector2 result = _measureTextEx(ref, text.ref, fontSize, spacing);
    return Vector2._Recieve(result);
  }

  Vector2 MeasureCodepoints(
    TextCodepoint codepoints,{
      required double fontSize,
      required double spacing
  }) {
    Vector2 size = Vector2(0, fontSize);
    double scale = fontSize / ref.baseSize;

    for (int x = 0; x < codepoints.length; x++)
    {
      int index = GetGlyphIndex(codepoints.buffer[x]);

      double advance;
      if ((advance = ref.glyphs[index].advanceX.toDouble()) == 0)
        advance = ref.recs[index].width;
      
      size.x += (advance + spacing) * scale;
    }

    if (size.x > 0) size.x -= (spacing * fontSize);
    return size;
  }

  /// Unload font from GPU memory (VRAM)
  void Unload() => Free();

  /// Unload font chars info data (RAM)
  void UnloadData() => _unloadFontData(glyphs.pointer, glyphs.length);

  static final Finalizer _finalizer = Finalizer<Pointer<_Font>>((pointer) {
    _unloadFont(pointer.ref);
    malloc.free(pointer);
  });

  @override
  void Free() {
    _unloadFont(ref);
    _finalizer.detach(this);
    super.Free();
  }
}

//------------------------------------------------------------------------------------
//                                 GlyphInfo
//------------------------------------------------------------------------------------
class GlyphInfo extends NativeWrapper<_GlyphInfo> {
  _GlyphInfo get ref => pointer.ref;

  late final Image image;
  int get value => ref.value;
  int get offsetX => ref.offsetX;
  int get offsetY => ref.offsetY;
  int get advanceX => ref.advanceX;

  // ignore: unused_element_parameter
  GlyphInfo._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    image = Image._Encapsulate(.fromAddress(pointer.address + (sizeOf<Int32>() * 3)));
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer((pointer) {
    malloc.free(pointer);
  });

  GlyphInfo operator [](int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    return GlyphInfo._Encapsulate(pointer + index, IsOwner: false);
  }

  void operator []=(GlyphInfo value, int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    (pointer + index).ref = value.ref;
  }

  @override
  Iterable<GlyphInfo> get values sync* {
    for (int x = 0; x < length; x++)
      yield this[x];
  }

  @override
  void Free() {
    super.Free();
    _finalizer.detach(this);
  }
}
