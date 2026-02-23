part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Image
//------------------------------------------------------------------------------------

class Image implements Disposeable
{
  NativeResource<_Image>? _memory;
  int frameCount = 0;
  int fileSize = 0;

  Pointer<_Color>? _colorsPtr;
  Pointer<_Color>? _palletPtr;
  Uint8List? _pixels;
  Uint8List? _pallet;
  Uint8List get pixels => _pixels ?? (throw Exception("Pixels not loaded yet"));
  Uint8List get pallet => _pallet ?? (throw Exception("Pallet not loaded yet"));

  void _loadColors()
  {
    if (_memory == null) return;

    final ptr = _loadImageColors(_memory!.pointer.ref);
    if (ptr.address == 0) return;

    _colorsPtr = ptr;
    _pixels = ptr.cast<Uint8>().asTypedList(width * height * 4);
  }

  void _loadPallet(int maxPalletSize)
  {
    if (_memory == null || _pallet == null) return;
    using ((Arena arena) {
      Pointer<Int32> colorCount = arena.allocate<Int32>(sizeOf<Int32>());

      final colorPtr = _loadImagePalette(ref, maxPalletSize, colorCount);
      if (colorPtr.address == 0) return;

      _palletPtr = colorPtr;
      _pallet = colorPtr.cast<Uint8>().asTypedList(colorCount.value * 4);
    });
  }

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

  _Image get ref => _memory!.pointer.ref;
  Pointer<Void> get data => ref.data;
  int get width => ref.width;
  int get height => ref.height;
  int get format => ref.format;
  int get mipmaps => ref.mipmaps;

  Image._internal(_Image result) { _setMemory(result); }

  //------------------------------Constructors------------------------------------------
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
    data.asTypedList(fileData.length).setAll(0, fileData);

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

//---------------------------------Generators-----------------------------------------
/// Generate image: plain color
static Image FromColor(int width, int height, Color color)
{
  _Image result = _genImageColor(width, height, color.ref);
  return Image._internal(result);
}

/// Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient
static Image GradientLinear(
  int width, int height,
 {required int direction, required Color start, required Color end}
) {
  _Image result = _genImageGradientLinear(width, height, direction, start.ref, end.ref);
  return Image._internal(result);
}

/// Generate image: radial gradient
static Image GradientRadial(
  int width, int height,
 {required double density, required Color inner, required Color outer}
) {
  _Image result = _genImageGradientRadial(width, height, density, inner.ref, outer.ref);
  return Image._internal(result);
}

/// Generate image: square gradient
static Image GradientSquare(
  int width, int height,
 {required double density, required Color inner, required Color outer}
) {
  _Image result = _genImageGradientSquare(width, height, density, inner.ref, outer.ref);
  return Image._internal(result);
}

/// Generate image: checked
static Image Checked(
  int width, int height,
 {required int checksX, required int checksY, required Color col1, required Color col2}
) {
  _Image result = _genImageChecked(width, height, checksX, checksY, col1.ref, col2.ref);
  return Image._internal(result);
}

/// Generate image: white noise
static Image WhiteNoise(int width, int height,{ required double factor })
{
  _Image result = _genImageWhiteNoise(width, height, factor);
  return Image._internal(result);
}

/// Generate image: perlin noise
static Image PerlinNoise(int width, int height,{ required int offsetX, required int offsetY, required double scale })
{
  _Image result = _genImagePerlinNoise(width, height, offsetX, offsetY, scale);
  return Image._internal(result);
}

/// Generate image: cellular algorithm, bigger tileSize means bigger cells
static Image Cellular(int width, int height, int tileSize)
{
  _Image result = _genImageCellular(width, height, tileSize);
  return Image._internal(result);
}

static Image GenText(int width, int height, String text)
{
  return using ((Arena arena) {
    Pointer<Utf8> ctext = text.toNativeUtf8(allocator: arena);

    _Image result = _genImageText(width, height, ctext);
    return Image._internal(result);
  });
}

  /// Create an image duplicate (useful for transformations)
  static Image Copy(Image image)
  {
    _Image result = _imageCopy(image.ref);
    return Image._internal(result); 
  }

  /// Create an image from another image piece
  static Image FromImage(Image image, Rectangle rect)
  {
    _Image result = _imageFromImage(image.ref, rect.ref);
    return Image._internal(result);
  }

  /// Create an image from a selected channel of another image (GRAYSCALE)
  static Image FromChannel(Image image, int selectedChannel)
  {
    _Image result = _imageFromChannel(image.ref, selectedChannel);
    return Image._internal(result);
  }

  /// Create an image from text (default font)
  static Image Text(String text,{ required int fontSize, Color? color })
  {
    return using ((Arena arena) {
      Pointer<Utf8> ctext = text.toNativeUtf8(allocator: arena);
      final finalcolor = color ?? Color.WHITE;

      _Image result = _imageText(ctext, fontSize, finalcolor.ref);
      return Image._internal(result);
    });
  }

  /// Create an image from text (custom sprite font)
  static Image TextEx(Font font, String text,{ required double fontSize, required double spacing, Color? tint })
  {
    return using ((Arena arena) {
      Pointer<Utf8> ctext = text.toNativeUtf8(allocator: arena);
      final finaltint = tint ?? Color.WHITE;

      _Image result = _imageTextEx(font.ref, ctext, fontSize, spacing, finaltint.ref);
      return Image._internal(result);
    });
  }
//----------------------------------Methods-------------------------------------------
  Pointer<_Image> get _pointer => _memory!.pointer;

  /// Convert image data to desired format
  void Format(int newFormat) => _imageFormat(_pointer, newFormat);
  /// Convert image to POT (power-of-two)
  void ToPOT(Color fill) => _imageToPOT(_pointer, fill.ref);
  /// Crop an image to a defined rectangle
  void Crop(Rectangle crop) => _imageCrop(_pointer, crop.ref);
  /// Crop image depending on alpha value
  void AlphaCrop(double threshold) => _imageAlphaCrop(_pointer, threshold);
  /// Clear alpha channel to desired color
  void AlphaClear(Color color, double threshold) => _imageAlphaClear(_pointer, color.ref, threshold);
  /// Apply alpha mask to image
  void AlphaMask(Image alphaMask) => _imageAlphaMask(_pointer, alphaMask.ref);
  /// Premultiply alpha channel
  void AlphaPremultiply() => _imageAlphaPremultiply(_pointer);
  /// Apply Gaussian blur using a box blur approximation
  void BlurGaussian(int blurSize) => _imageBlurGaussian(_pointer, blurSize);
  /// Apply custom square convolution kernel to image
  void KernelConvolution({ required List<double> kernel, required int kernelSize })
  {
    if (kernel.length != kernelSize*kernelSize) throw ArgumentError("Invalid kernel. Expected: ${kernelSize*kernelSize}, Recieved: ${kernel.length}");

    using ((Arena arena) {
      Pointer<Float> ckernel = arena.allocate<Float>(sizeOf<Float>() * kernel.length);
      ckernel.asTypedList(kernelSize).setAll(0, kernel);

      _imageKernelConvolution(_pointer, ckernel, kernelSize);
    });
  }
  /// Resize image (Bicubic scaling algorithm)
  void Resize(int newWidth, int newHeight) => _imageResize(_pointer, newWidth, newHeight);
  /// Resize image (Nearest-Neighbor scaling algorithm)
  void ResizeNN(int newWidth, int newHeight) => _imageResizeNN(_pointer, newWidth, newHeight);
  /// Resize canvas and fill with color
  void ResizeCanvas(int newWidth, int newHeight,{ required int offsetX, required int offsetY, required Color fill }) => _imageResizeCanvas(_pointer, newWidth, newHeight, offsetX, offsetY, fill.ref);
  /// Compute all mipmap levels for a provided image
  void Mipmaps() => _imageMipmaps(_pointer);
  /// Flip image vertically
  void Dither(int rBpp, int gBpp, int bBpp, int aBpp) => _imageDither(_pointer, rBpp, gBpp, bBpp, aBpp);
  /// Flip image vertically
  void FlipVertical() => _imageFlipVertical(_pointer);
  /// Flip image horizontally
  void FlipHorizontal() => _imageFlipHorizontal(_pointer);
  /// Rotate image by input angle in degrees (-359 to 359)
  void Rotate(int degrees) => _imageRotate(_pointer, degrees);
  /// Rotate image clockwise 90deg
  void RotateCW() => _imageRotateCW(_pointer);
  /// Rotate image counter-clockwise 90deg
  void RotateCCW() => _imageRotateCCW(_pointer);
  /// Modify image color: tint
  void ColorTint(Color color) => _imageColorTint(_pointer, color.ref);
  /// Modify image color: invert
  void ColorInvert() => _imageColorInvert(_pointer);
  /// Modify image color: grayscale
  void ColorGrayscale() => _imageColorGrayscale(_pointer);
  // Modify image color: contrast (-100 to 100)
  void ColorContrast(double contrast) => _imageColorContrast(_pointer, contrast);
  /// Modify image color: brightness (-255 to 255)
  void ColorBrightness(int brightness) => _imageColorBrightness(_pointer, brightness);
  /// Modify image color: replace color
  void ColorReplace(Color color, Color replace) => _imageColorReplace(_pointer, color.ref, replace.ref);
  /// Load color data from image as a Color array (RGBA - 32bit)
  /// 
  /// Accessed through instance member [pixels]
  void LoadColors() => _loadColors();
  /// Load colors palette from image as a Color array (RGBA - 32bit)
  /// 
  /// Accessed through intance member [pallet]
  void LoadPallet(int maxPalletSize) => _loadPallet(maxPalletSize);
  /// Get image alpha border rectangle
  Rectangle GetAlphaBorder(double threshold) => Rectangle._recieve(_getImageAlphaBorder(ref, threshold));
  /// Get image pixel color at (x, y) position
  Color GetColor(int x, int y) => Color._recieve(_getImageColor(ref, x, y));

//----------------------------------Utility-------------------------------------------

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

  /// Clear image background with given color
  void ClearBackgroud(Color color) => _imageClearBackground(_pointer, color.ref);
  /// Draw pixel within an image
  void DrawPixel(int posX, int posY, Color color) => _imageDrawPixel(_pointer, posX, posY, color.ref);
  /// Draw pixel within an image (Vector version)
  void DrawPixelV(Vector2 position, Color color) => _imageDrawPixelV(_pointer, position.ref, color.ref);
  /// Draw line within an image
  void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color) => _imageDrawLine(_pointer, startPosX, startPosY, endPosX, endPosY, color.ref);
  /// Draw line within an image (Vector version)
  void DrawLineV(Vector2 start, Vector2 end, Color color) => _imageDrawLineV(_pointer, start.ref, end.ref, color.ref);
  /// Draw a line defining thickness within an image
  void DrawLineEx(Vector2 start, Vector2 end, int thick, Color color) => _imageDrawLineEx(_pointer, start.ref, end.ref, thick, color.ref);
  /// Draw a filled circle within an image
  void DrawCircle(int centerX, int centerY, int radius, Color color) => _imageDrawCircle(_pointer, centerX, centerY, radius, color.ref);
  /// Draw a filled circle within an image (Vector version)
  void DrawCircleV(Vector2 center, int radius, Color color) => _imageDrawCircleV(_pointer, center.ref, radius, color.ref);
  /// Draw circle outline within an image (Vector version)
  void DrawCircleLines(int centerX, int centerY, int radius, Color color) => _imageDrawCircleLines(_pointer, centerX, centerY, radius, color.ref);
  /// Draw circle outline within an image (Vector version)
  void DrawCircleLinesV(Vector2 center, int radius, Color color) => _imageDrawCircleLinesV(_pointer, center.ref, radius, color.ref);
  /// Draw rectangle within an image
  void DrawRectangle(int posX, int posY, int width, int height, Color color) => _imageDrawRectangle(_pointer, posX, posY, width, height, color.ref);
  /// Draw rectangle within an image (Vector version)
  void DrawRectangleV(Vector2 position, Vector2 size, Color color) => _imageDrawRectangleV(_pointer, position.ref, size.ref, color.ref);
  /// Draw rectangle within an image
  void DrawRectangleRec(Rectangle rec, Color color) => _imageDrawRectangleRec(_pointer, rec.ref, color.ref);
  /// Draw rectangle lines within an image
  void DrawRectangleLines(Rectangle rec, int thick, Color color) => _imageDrawRectangleLines(_pointer, rec.ref, thick, color.ref);
  /// Draw triangle within an image
  void DrawTriangle(Vector2 v1, Vector2 v2, Vector2 v3, Color color) => _imageDrawTriangle(_pointer, v1.ref, v2.ref, v3.ref, color.ref);
  /// Draw triangle with interpolated colors within an image
  void DrawTriangleEx(Vector2 v1, Vector2 v2, Vector2 v3, Color c1, Color c2, Color c3) => _imageDrawTriangleEx(_pointer, v1.ref, v2.ref, v3.ref, c1.ref, c2.ref, c3.ref );
  /// Draw triangle outline within an image
  void DrawTriangleLines(Vector2 v1, Vector2 v2, Vector2 v3, Color color) => _imageDrawTriangleLines(_pointer, v1.ref, v2.ref, v3.ref, color.ref);
  /// Draw a triangle fan defined by points within an image (first vertex is the center)
  void DrawTriangleFan(List<Vector2> points, Color color)
  {
    if (points.length < 3 || points.length == 0) return;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x]._ptr.ref;
      }

      _imageDrawTriangleFan(_pointer, cpoints, points.length, color.ref);

    });
  }
  
  /// Draw a triangle strip defined by points within an image
  void DrawTriangleStrip(List<Vector2> points, Color color)
  {
    if (points.length < 3 || points.length == 0) return;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x]._ptr.ref;
      }

      _imageDrawTriangleStrip(_pointer, cpoints, points.length, color.ref);

    });
  }

  /// Draw a source image within a destination image (tint applied to source)
  void DrawImage(Image src, Rectangle srcRec, Rectangle dstRec, Color tint) => _imageDraw(_pointer, src.ref, srcRec.ref, dstRec.ref, tint.ref);

  /// Draw text (using default font) within an image (destination)
  void DrawText(String text, int posX, int posY,{ required int fontSize, required Color color })
  {
    using ((Arena arena) {
      Pointer<Utf8> ctext = text.toNativeUtf8(allocator: arena);

      _imageDrawText(_pointer, ctext, posX, posY, fontSize, color.ref);
    });
  }

  /// Draw text (custom sprite font) within an image (destination)
  void DrawTextEx(Font font, String text, Vector2 position,{ required double fontSize, required double spacing, Color? tint })
  {
    final finaltint = tint ?? Color.WHITE;
    using ((Arena arena) {
      Pointer<Utf8> ctext = text.toNativeUtf8(allocator: arena);

      _imageDrawTextEx(_pointer, font.ref, ctext, position.ref, fontSize, spacing, finaltint.ref);
    });
  }

//--------------------------------Deconstructors--------------------------------------

  /// Unload image from CPU memory (RAM)
  void Unload() => dispose();

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
      if (_palletPtr != null && _palletPtr!.address != 0) {
        _unloadImagePalette(_palletPtr!);
        _palletPtr = null; _pallet = null;
      }
      if(_colorsPtr != null && _colorsPtr!.address != 0) {
        _unloadImageColors(_colorsPtr!);
        _colorsPtr = null; _pixels = null;
      }
      _memory!.dispose();
    }
  }
}
