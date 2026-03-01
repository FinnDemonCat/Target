part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                    Font
//------------------------------------------------------------------------------------

class Font implements Disposeable
{
  NativeResource<_Font>? _memory;
  _Font get ref => _memory!.pointer.ref;
  int get baseSize => ref.baseSize;
  int get glyphPadding => ref.glyphPadding;
  _Texture2D get texture => ref.texture; 

  late final GlyphInfo glyphs;
  late final Rectangle recs;

  void _setmemory(_Font result)
  {
    Pointer<_Font> pointer = malloc.allocate<_Font>(sizeOf<_Font>());
    pointer.ref = result;

    glyphs = GlyphInfo._internal(pointer.ref.glyphs, length: pointer.ref.glyphCount);
    recs = Rectangle._internal(pointer.ref.recs, length: pointer.ref.glyphCount);

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Font>(pointer);
  }

  /// Get the default Font
  Font.Default()
  {
    _Font result = _getFontDefault();
    _setmemory(result);
  }

  /// Load font from file into GPU memory (VRAM)
  Font(String fileName)
  {
    using ((Arena arena) {
      Pointer<Utf8> cfileName = fileName.toNativeUtf8(allocator: arena);
      _Font result = _loadFont(cfileName);

      _setmemory(result);
    });
  }

  /// Load font from file with extended parameters, use NULL for codepoints and 0 for codepointCount to load the default character set, font size is provided in pixels height
  Font.LoadEx(String fileName,{ required int fontSize, required Pointer<Int32> codepoints, required int codepointCount })
  {
    using ((Arena arena) {
      Pointer<Utf8> cfileName = fileName.toNativeUtf8(allocator: arena);
      _Font result = _loadFontEx(cfileName, fontSize, codepoints, codepointCount);

      _setmemory(result);
    });
  }

  Font.FromImage(Image image, Color key, int firstChar)
  {
    _Font result = _loadFontFromImage(image.ref, key.ref, firstChar);
    _setmemory(result);
  }

  /// Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  Font.FromMemory(
   {required String fileType,
   required Uint8List fileData,
   required int fontsize,
   List<int>? codepoints}
  ) {
    using ((Arena arena) {
      Pointer<Utf8> cfileType = fileType.toNativeUtf8(allocator: arena);
      Pointer<Uint8> cfileData = arena.allocate<Uint8>(sizeOf<Uint8>() * fileData.length);
      cfileData.asTypedList(fileData.length).setAll(0, fileData);

      Pointer<Int32> codepointsPtr = nullptr;
      int codepointsCount = 0;
      if (codepoints != null)
      {
        codepointsPtr = arena.allocate<Int32>(sizeOf<Int32>() * codepoints.length);
        for (int x = 0; x < codepoints.length; x++) {
          codepointsPtr[x] = codepoints[x];
        }

        codepointsCount = codepoints.length;
      }

      _Font result = _loadFontFromMemory(cfileType, cfileData, fileData.length, fontsize, codepointsPtr, codepointsCount);
      _setmemory(result);
    });
  }

  /// Generate image font atlas using chars info
  Image GenAtlas({required int fontSize, required int padding, required int packMethod})
  {
    _Image image = _genImageFontAtlas(
      glyphs._memory!.pointer,
      recs._memory!.pointer,
      glyphs.length,
      fontSize,
      padding,
      packMethod
    );

    return Image._internal(image);
  }

  /// Generate image font atlas using chars info
  GlyphInfo loadFontData(
    {required Uint8List fileData,
     required int fontSize,
     List<int>? codepoints,
     int type = 0}
  ) {
    return using((Arena arena) {
      Pointer<Uint8> cfileData = arena.allocate<Uint8>(fileData.length);
      cfileData.asTypedList(fileData.length).setAll(0, fileData);

      Pointer<Int32> glyphCountPtr = arena.allocate<Int32>(sizeOf<Int32>());

      Pointer<Int32> codepointsPtr = nullptr;
      int codepointsCount = 0;

      if (codepoints != null && codepoints.isNotEmpty)
      {
        codepointsPtr = arena.allocate<Int32>(sizeOf<Int32>() * codepoints.length);
        for (int x = 0; x < codepoints.length; x++) {
          codepointsPtr[x] = codepoints[x];
        }
        codepointsCount = codepoints.length;
      } else {
        codepointsCount = 95; 
      }

      Pointer<_GlyphInfo> pointer = _loadFontData(
        cfileData,
        fileData.length,
        fontSize,
        codepointsPtr,
        codepointsCount,
        type,
        glyphCountPtr
      );
      return GlyphInfo._internal(pointer, length: glyphCountPtr.value);
    });
  }

  /// Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
  GlyphInfo GetGlyphInfo(int codepoint)
  {
    int index = _getGlyphIndex(ref, codepoint);
    return glyphs[index];
  }

  /// Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found
  Rectangle GetAtlasRec(int codepoint)
  {
    int index = _getGlyphIndex(ref, codepoint);
    return recs[index];
  }

  bool IsValid() => _isFontValid(ref);
  /// Export font as code file, returns true on success
  void ExportAsCode(String fileName)
  {
    using ((Arena arena) {
      Pointer<Utf8> cfileName = fileName.toNativeUtf8(allocator: arena);

      _exportFontAsCode(ref, cfileName);
    });
  }

  /// Measure string size for Font
  Vector2 MeasureText(Text text,{ required double fontSize, required double spacing })
  {
    _Vector2 result = _measureTextEx(ref, text.ref, fontSize, spacing);
    return Vector2._internal(result);
  }
  
  /// Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
  int GetGlyphIndex(int codepoint) => _getGlyphIndex(ref, codepoint);

  /// Unload font from GPU memory (VRAM)
  void Unload() => dispose();

  /// Unload font chars info data (RAM)
  void UnloadData() => _unloadFontData(glyphs._memory!.pointer, glyphs.length);

  static final Finalizer _finalizer = Finalizer<Pointer<_Font>>((pointer) {
    _unloadFont(pointer.ref);
    malloc.free(pointer);
  });

  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadFont(ref);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                 GlyphInfo
//------------------------------------------------------------------------------------
class GlyphInfo implements Disposeable
{
  NativeResource<_GlyphInfo>? _memory;
  final int _length;

  int get length => length;

  GlyphInfo._internal(Pointer<_GlyphInfo> pointer,{ int length = 1, bool owner = true }) : _length = length
  {
    if (_memory != null) dispose();
    _memory = NativeResource<_GlyphInfo>(pointer, IsOwner: owner);

    if (owner)
      _finalizer.attach(this, pointer, detach: this);
  }

  // ignore: unused_element
  void _setmemory(_GlyphInfo result)
  {
    Pointer<_GlyphInfo> pointer = malloc.allocate<_GlyphInfo>(sizeOf<_GlyphInfo>());
    pointer.ref = result;

    this._memory = NativeResource<_GlyphInfo>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer((pointer) {
    malloc.free(pointer);
  });

  GlyphInfo operator [](int index)
  {
    if (index < 0 || index >= _length) throw RangeError(index);
    return GlyphInfo._internal(_memory!.pointer + index, owner: false);
  }

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
