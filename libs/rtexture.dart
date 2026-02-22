part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Texture
//------------------------------------------------------------------------------------

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

  _Texture2D get ref => _memory!.pointer.ref;
  int get width => ref.width;
  int get heigth => ref.heigth;
  int get format => ref.format;
  int get id => ref.id;
  int get mipmaps => ref.mipmaps;

  //--------------------------------Constructors----------------------------------------

  // Used for TextureCubeMap constructor
  Texture2D._internal(_Texture struct) { _setmemory(struct); }

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

  //---------------------------------Utilities-----------------------------------------
  /// Generate GPU mipmaps for a texture
  void GenMipmaps() => _genTextureMipmaps(_memory!.pointer);
  /// Set texture scaling filter mode
  void SetFilter(int filter) => _setTextureFilter(ref, filter);
  /// Set texture wrapping mode
  void SetWrap(int wrap) => _setTextureWrap(ref, wrap);

  /// Check if a texture is valid (loaded in GPU)
  bool isValid()
  {
    if (_memory == null) return false;
    return _isTextureValid(_memory!.pointer.ref);
  }

  /// Update GPU texture with new data (pixels should be able to fill texture)
  void Update(Pointer<Void> pixels)
  {
    if (!isValid()) return;
    _updateTexture(ref, pixels);
  }

  /// Update GPU texture rectangle with new data (pixels and rec should fit in texture)
  void UpdateRect(Rectangle rect, Pointer<Void> pixels)
  {
    if (!isValid()) return;
    _updateTextureRec(ref, rect.ref, pixels);
  }

  /// Draw a Texture2D
  static void Draw(Texture2D texture,{ int posX = 0, int posY = 0, Color? tint })
  {
    tint ??= Color.WHITE;
    _drawTexture(texture.ref, posX, posY, tint.ref);
  }
  /// Draw a Texture2D with position defined as Vector2
  static void DrawV(Texture2D texture,{ required Vector2 position, Color? tint })
  {
    tint ??= Color.WHITE;
    _drawTextureV(texture.ref, position.ref, tint.ref);
  }

  /// Draw a Texture2D with extended parameters
  static void DrawEx(Texture2D texture,{ Vector2? position, double rotation = 0.0, double scale = 1.0, Color? tint })
  {
    tint ??= Color.WHITE;
    position ??= Vector2.Zero();
    _drawTextureEx(texture.ref, position.ref, rotation, scale, tint.ref);
  }

  /// Draw a part of a texture defined by a rectangle
  static void DrawRec(Texture2D texture, Rectangle source,{ Vector2? position, Color? tint })
  {
    tint ??= Color.WHITE;
    position ??= Vector2.Zero();
    _drawTextureRec(texture.ref, source.ref, position.ref, tint.ref);
  }

  /// Draw a part of a texture defined by a rectangle with 'pro' parameters
  static void DrawPro(Texture2D texture, Rectangle source, Rectangle dest,{ Vector2? origin, double rotation = 0.0, Color? tint })
  {
    tint ??= Color.WHITE;
    origin ??= Vector2.Zero();
    _drawTexturePro(texture.ref, source.ref, dest.ref, origin.ref, rotation, tint.ref);
  }

  /// Draws a texture (or part of it) that stretches or shrinks nicely
  static void DrawNPatch(
    Texture2D texture, NPatchInfo nPatchInfo, Rectangle dest,
    { Vector2? origin, double rotation = 0.0, Color? tint }
  ) {
    tint ??= Color.WHITE;
    origin ??= Vector2.Zero();
    _drawTextureNPatch(texture.ref, nPatchInfo.ref, dest.ref, origin.ref, rotation, tint.ref);
  }

  /// Draw a billboard texture
  static void DrawBillboard(Texture2D texture, Vector3 position, {required Camera camera, double scale = 0.0, Color? tint})
  {
    tint ??= Color.WHITE;
    _drawBillboard(camera.ref, texture.ref, position.ref, scale, tint.ref);
  }

  /// Draw a billboard texture defined by source
  static void DrawBillboardRec(Texture2D texture, Vector3 position, Rectangle source,{ required Camera camera, Vector2? size, Color? tint})
  {
    size ??= Vector2.One();
    tint ??= Color.WHITE;
    _drawBillboardRec(camera.ref, texture.ref, source.ref, position.ref, size.ref, tint.ref);
  }

  /// Draw a billboard texture defined by source and rotation
  static void DrawBillboardPro(
    Texture2D texture, Rectangle source, Vector3 position,
   { required Camera camera, required Vector3 up, Vector2? size, Vector2? origin, double rotation = 0.0, Color? tint}) {
    size ??= Vector2.One();
    origin ??= Vector2.One();
    tint ??= Color.WHITE;
    _drawBillboardPro(camera.ref, texture.ref, source.ref, position.ref, up.ref, size.ref, origin.ref, rotation, tint.ref);
  }

  //--------------------------------Deconstructors--------------------------------------

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

//------------------------------------------------------------------------------------
//                                 RenderTexture2D
//------------------------------------------------------------------------------------

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
