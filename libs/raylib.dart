library raylib;

import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'dart:io';
part 'raylib_bindings.dart';

// Window-related functions
abstract class Window
{
  // Initialize window and OpenGL context
  static void Init(int width, int height, String title)
  {
    final cTitle = title.toNativeUtf8();

    _initWindow(width, height, cTitle);

    malloc.free(cTitle);
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

  static void SetIcon(Image image)
  {
    // Here it starts the NativeResource logic
    // A problem to future me
    // Use the binding generator on the python folder
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

  Pointer<Void> get data {
    if (!IsValid()) return nullptr;
    return _memory!.pointer.ref.data;
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
      Pointer<Utf8> cFileName = fileName.toNativeUtf8();

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
        // Not yet implemented
        // _unloadFileData(data);
      }
    });
  }

  bool ExportAsCode(String fileName)
  {
    if(!IsValid()) return false;

    return using((Arena arena) {
      Pointer<Utf8> cFileName = fileName.toNativeUtf8();

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
    _updateTexture(_memory!.pointer.ref, pixels);
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
  NativeResource<_RenderTexture2D>? memory;

	void _setmemory(_RenderTexture2D result)
	{
		if(result.id == 0) throw Exception("[Dart] Couldn't load Texture2D!");
    if (memory != null) dispose();

    // Allocating memory in C heap
    Pointer<_RenderTexture2D> pointer = malloc.allocate<_RenderTexture2D>(sizeOf<_RenderTexture2D>());
    pointer.ref = result;
    this.memory = NativeResource<_RenderTexture2D>(pointer);

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
    if(memory == null) return false;
    return _isRenderTextureValid(memory!.pointer.ref);
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
    if (memory != null && !memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadRenderTexture(memory!.pointer.ref);
      memory!.dispose();
    }
  }
}
