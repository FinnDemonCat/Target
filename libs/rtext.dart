part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                     Text
//------------------------------------------------------------------------------------

abstract class Text
{
  /// Draw current FPS
  static void DrawFPS(int posX, int posY) => _drawFPS(posX, posY);

  /// Draw text (using default font)
  static void Draw(String text, int fontSize, { int posX = 0, int posY = 0, Color? color })
  {
    final finalColor = color ?? Color.WHITE;
    using ((Arena arena) {
      Pointer<Utf8> ctext = text.toNativeUtf8(allocator: arena);

      _drawText(ctext, posX, posY, fontSize, finalColor.ref);
    });
  }

  /// Draw text using font and additional parameters
  static void DrawEx(Font font, String text,{ Vector2? position, required double fontSize, required double spacing, Color? tint })
  {
    using ((Arena arena) {
      Pointer<Utf8> ctext = text.toNativeUtf8(allocator: arena);
      final finalPos = position ?? Vector2.Zero();
      final colorTint = tint ?? Color.WHITE;

      _drawTextEx(font.ref, ctext, finalPos.ref, fontSize, spacing, colorTint.ref); 
    });
  }

  /// Draw text using Font and pro parameters (rotation)
  static void DrawPro(Font font, String text,
    {Vector2? position, Vector2? origin,
     double rotation = 0.0, required double fontSize,
     required double spacing, Color? tint}
  ) {
    using ((Arena arena) {
      Pointer<Utf8> ctext = text.toNativeUtf8(allocator: arena);
      final finalPos = position ?? Vector2.Zero();
      final finalOrigin = origin ?? Vector2.Zero();
      final colorTint = tint ?? Color.WHITE;

      _drawTextPro(
        font.ref, ctext, finalPos.ref, finalOrigin.ref,
        rotation, fontSize, spacing, colorTint.ref
      ); 
    });
  }

  /// Draw one character (codepoint)
  static void DrawCodepoint(
    Font font, int codepoint,
   {Vector2? position, required double fontSize, Color? tint}
  ) {
    final finalPos = position ?? Vector2.Zero();
    final finalTint = Color.WHITE;

    _drawTextCodepoint(font.ref, codepoint, finalPos.ref, fontSize, finalTint.ref);
  }

  /// Draw multiple character (codepoint)
  static DrawCodepoints(
    Font font, List<int> codepoints,
   {Vector2? position, required double fontSize, required double spacing, Color? tint}
  ) {
    final finalPos = position ?? Vector2.Zero();
    final finalTint = Color.WHITE;

    using ((Arena arena) {
      Pointer<Int32> pointer = arena.allocate<Int32>(sizeOf<Int32>() * codepoints.length);
      pointer.asTypedList(codepoints.length).setAll(0, codepoints);

      _drawTextCodepoints(font.ref, pointer, codepoints.length, finalPos.ref, fontSize, spacing, finalTint.ref);
    });
  }

  /// Open URL with default system browser (if available)
  static void OpenUrl(String url)
  {
    using ((Arena arena) {
      final cUrl = url.toNativeUtf8(allocator: arena);
      _openURL(cUrl);
    });
  }
}

//------------------------------------------------------------------------------------
//                                   Unicode
//------------------------------------------------------------------------------------

abstract class Unicode
{
  /// Load all codepoints from a UTF-8 text string, codepoints count returned by parameter
  static List<int> LoadCodepoints(String text)
  {
    return using ((Arena arena) {
      Pointer<Utf8> ctext = text.toNativeUtf8(allocator: arena);
      Pointer<Int32> codepointsCountPtr = arena.allocate<Int32>(sizeOf<Int32>());

      Pointer<Int32> loadedCodepoints = _loadCodepoints(ctext, codepointsCountPtr);
      List<int> codepoints = [];

      if (loadedCodepoints == nullptr) return codepoints;

      codepoints = List<int>.from(loadedCodepoints.asTypedList(codepointsCountPtr.value));
      _unloadCodepoints(loadedCodepoints);

      return codepoints;
    });
  }
  
  /// Load UTF-8 text encoded from codepoints array
  static String LoadUTF8(List<int> codepoints)
  {
    return using ((Arena arena) {
      Pointer<Int32> ccodepoints = arena.allocate<Int32>(sizeOf<Int32>() * codepoints.length);
      for (int x = 0; x < codepoints.length; x++) {
        ccodepoints[x] = codepoints[x];
      }

      Pointer<Utf8> pointer = _loadUTF8(ccodepoints, codepoints.length);

      final String string = pointer.toDartString();
      _unloadUTF8(pointer);

      return string;
    });
  }

  /// Encode one codepoint into UTF-8 byte array (array length returned as parameter)
  static String CodepointToUTF8(int codepoint)
  {
    return using ((Arena arena) {
      Pointer<Int32> sizePtr = arena.allocate<Int32>(sizeOf<Int32>());
      Pointer<Utf8> utf8 = _codepointToUTF8(codepoint, sizePtr);

      return utf8.toDartString();
    });
  }
}