part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   Texture
//------------------------------------------------------------------------------------

class Texture2D extends NativeWrapper<_Texture2D>
{
	// NativeWrapper<_Texture2D>? _memory;

	/* void _setmemory(_Texture2D result)
	{
		if(result.id == 0) throw Exception("[Dart] Couldn't load Texture2D!");
    if (_memory != null) Free();

    // Allocating memory in C heap
    Pointer<_Texture2D> pointer = malloc.allocate<_Texture2D>(sizeOf<_Texture2D>());
    pointer.ref = result;
    this._memory = NativeWrapper<_Texture2D>(pointer);

    _finalizer.attach(this, pointer, detach: this);
	}
 */
  _Texture2D get ref => pointer.ref;
  set ref (_Texture2D value) => pointer.ref = value;
  int get width => ref.width;
  int get heigth => ref.heigth;
  int get format => ref.format;
  int get id => ref.id;
  int get mipmaps => ref.mipmaps;

  //--------------------------------Constructors----------------------------------------

  // ignore: unused_element_parameter
  Texture2D._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  // Used for TextureCubeMap constructor
  Texture2D._Recieve(_Texture value,{ super.IsOwner, super.length }) : super(sizeOf<_Texture2D>()) {
    ref = value;
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  /// Load texture from file into GPU memory (VRAM)
  factory Texture2D(String fileName) {
    Pointer<Utf8> cFileName = fileName.toNativeUtf8();
    _Texture2D result;

    try {
      result = _loadTexture(cFileName);
    }
    catch (error) {
      rethrow;
    } 
    finally {
      malloc.free(cFileName);
    }

    return Texture2D._Recieve(result);
  }

  /// Load texture from image data
  factory Texture2D.FromImage(Image image) {
    _Texture2D result;

    try {
      result = _loadTextureFromImage(image.ref);
    }
    catch(error) {
      rethrow;
    }

    return Texture2D._Recieve(result);
  }

  //---------------------------------Utilities-----------------------------------------
  /// Generate GPU mipmaps for a texture
  void GenMipmaps() => _genTextureMipmaps(pointer);
  /// Set texture scaling filter mode
  void SetFilter(TextureFilter filter) => _setTextureFilter(ref, filter.index);
  /// Set texture wrapping mode
  void SetWrap(TextureWrap wrap) => _setTextureWrap(ref, wrap.index);

  /// Check if a texture is valid (loaded in GPU)
  bool isValid() => _isTextureValid(pointer.ref);

  /// Update GPU texture with new data (pixels should be able to fill texture)
  void Update(Pointer<Void> pixels) {
    if (!isValid()) return;
    _updateTexture(ref, pixels);
  }

  /// Update GPU texture rectangle with new data (pixels and rec should fit in texture)
  void UpdateRect(Rectangle rect, Pointer<Void> pixels) {
    if (!isValid()) return;
    _updateTextureRec(ref, rect.ref, pixels);
  }

  /// Draw a Texture2D
  static void Draw(Texture2D texture,{ int posX = 0, int posY = 0, Color? tint }) {
    tint ??= Color.WHITE;
    _drawTexture(texture.ref, posX, posY, tint.ref);
  }
  /// Draw a Texture2D with position defined as Vector2
  static void DrawV(Texture2D texture,{ required Vector2 position, Color? tint }) {
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
  static final Finalizer<Pointer<_Texture>> _finalizer = Finalizer((ptr) {
    _unloadTexture(ptr.ref);
    malloc.free(ptr);
  });

  /// Unload texture from GPU memory (VRAM)
  @override
  void Free() {
    _unloadTexture(pointer.ref);
    _finalizer.detach(this);
    super.Free();
  }
}

typedef Texture = Texture2D;

class TextureCubemap extends Texture2D {
  TextureCubemap._Recieve(super.texture) : super._Recieve();

  /// Load cubemap from image, multiple image cubemap layouts supported
  factory TextureCubemap(Image image, CubemapLayout layout) {
    final result = _loadTextureCubemap(image.pointer.ref, layout.index);

    return TextureCubemap._Recieve(result);
  }
}

//------------------------------------------------------------------------------------
//                                 RenderTexture2D
//------------------------------------------------------------------------------------

class RenderTexture2D extends NativeWrapper<_RenderTexture>
{
  // NativeWrapper<_RenderTexture2D>? _memory;

  _RenderTexture2D get ref => pointer.ref;
  set ref (_RenderTexture2D value) => pointer.ref = value;

  late final Texture texture;
  late final Texture depth;
  int get width => ref.texture.width;
  int get height => ref.texture.heigth;
  
  // Texture get texture {
  //   final address = pointer.address + sizeOf<Uint32>();
  //   final ptr = Pointer<_Texture>.fromAddress(address);

  //   return Texture._Encapsulate(ptr, IsOwner: false);
  // }

	/*
  void _setmemory(_RenderTexture2D result)
	{
		if(result.id == 0) throw Exception("[Dart] Couldn't load Texture2D!");
    if (_memory != null) Free();

    // Allocating memory in C heap

    Pointer<_RenderTexture2D> pointer = malloc.allocate<_RenderTexture2D>(sizeOf<_RenderTexture2D>());
    pointer.ref = result;
    this._memory = NativeWrapper<_RenderTexture2D>(pointer);

    _finalizer.attach(this, pointer, detach: this);
	} 
  */

  void _setReferences() {
    int address = pointer.address + sizeOf<Int32>();
    texture = Texture._Encapsulate(.fromAddress(address));

    address += sizeOf<_Texture>();
    depth = Texture._Encapsulate(.fromAddress(address));
  }

  // ignore: unused_element_parameter, unused_element
  RenderTexture2D._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  RenderTexture2D._Recieve(_RenderTexture result) : super(sizeOf<_RenderTexture>()) {
    ref = result;
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  /// Load texture for rendering (framebuffer)
  factory RenderTexture2D(num width, num height) {
    final renderTexture2D = _loadRenderTexture(width.toInt(), height.toInt());
    return RenderTexture2D._Recieve(renderTexture2D);
  }

  /// Check if a render texture is valid (loaded in GPU)
  bool isValid() => _isRenderTextureValid(ref);
  
  // Garbage collector setup
  static final Finalizer<Pointer<_RenderTexture2D>> _finalizer = Finalizer((ptr) {
    _unloadRenderTexture(ptr.ref);
    malloc.free(ptr);
  });

  /// Unload render texture from GPU memory (VRAM)
  @override
  void Free() {
    _finalizer.detach(this);
    _unloadRenderTexture(pointer.ref);
    super.Free();
  }
}

typedef RenderTexture = RenderTexture2D;