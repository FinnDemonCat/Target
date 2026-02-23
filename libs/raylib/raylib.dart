library raylib;

import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:math' as math;

part 'struct_bindings.dart';
part 'vectors.dart';
part 'matrix.dart';
part 'rectangle.dart';
part 'rinput.dart';
part 'rcolor.dart';
part 'rimage.dart';
part 'rtexture.dart';
part 'npatchinfo.dart';
part 'rfont.dart';
part 'rtext.dart';
part 'rcamera.dart';
part 'rboundingbox.dart';
part 'rmesh.dart';
part 'rtransform.dart';
part 'rmodel.dart';
part 'rshapes.dart';
part 'rsplines.dart';
part 'rcollision.dart';
part 'rvrstereo.dart';

//------------------------------------------------------------------------------------
//                                   Window
//------------------------------------------------------------------------------------

/// Window-related functions
abstract class Window
{
  // Initialize window and OpenGL context
  static void Init({required int width, required int height, required String title})
  {
    using ((Arena arena) {
      final cTitle = title.toNativeUtf8(allocator: arena);

      _initWindow(width, height, cTitle);
    });
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

  /// Setup init configuration flags (view FLAGS)
  /// 
  /// The parameter `flag` expects a ConfigFlags value
  static void SetFlags(int flag) => _setConfigFlags(flag);

  /// Takes a screenshot of current screen (filename extension defines format)
  static void TakeScreenshoot(String fileName)
  {
    using ((Arena arena) {
      Pointer<Utf8> cfileName = fileName.toNativeUtf8(allocator: arena);

      _takeScreenshot(cfileName);
    });
  }

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
  /// Set icon for window (single image, RGBA 32bit)
  static void SetIcon(Image image) => _setWindowIcon(image.ref);
  /// Set icon for window (multiple images, RGBA 32bit)
  static void SetIcons(List<Image> images)
  {
    using((Arena arena) {
      Pointer<_Image> ref = arena.allocate<_Image>(sizeOf<_Image>() * images.length);

      for(int x = 0; x < images.length; x++)
        ref[x] = images[x].ref;

      _setWindowIcons(ref, images.length);      
    });
  }
  /// Set title for window
  static void SetTitle(String title)
  {
    using((Arena arena) {
      Pointer<Utf8> pointer = title.toNativeUtf8(allocator: arena);

      _setWindowTitle(pointer);
    });
  }

  /// Set window position on screen
  static void SetPosition(int x, int y) => _setWindowPosition(x, y);
  /// Set monitor for the current window
  static void SetMonitor(int monitor) => _setWindowMonitor(monitor);
  /// Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
  static void SetMinSize(int width, int height) => _setWindowMinSize(width, height);
  /// Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)
  static void SetMaxSize(int width, int height) => _setWindowMaxSize(width, height);
  /// Set window dimensions
  static void SetSize(int width, int height) => _setWindowSize(width, height);
  /// Set window opacity [0.0f..1.0f]
  static void SetOpacity(double opacity) => _setWindowOpacity(opacity);
  /// Set window focused
  static void SetFocused() => _setWindowFocused();
  /// Get native window handle
  static Pointer<Void> GetHandle() => _getWindowHandle();
  /// Get current screen width
  static int Width() => _getScreenWidth();
  /// Get current screen height
  static int Height() => _getScreenHeight();
  /// Get current render width (it considers HiDPI)
  static int RenderWidth() => _getRenderWidth();
  /// Get current render height (it considers HiDPI)
  static int RenderHeight() => _getRenderHeight();
  /// Get number of connected monitors
  static int GetMonitorCount() => _getMonitorCount();
  /// Get specified monitor position
  static int GetCurrentMonitor() => _getCurrentMonitor();
  /// Get specified monitor position
  static Vector2 GetMonintorPosition(int monitor)
  {
    Vector2 position = Vector2();
    position._setmemory(_getMonitorPosition(monitor));

    return position;
  }
  /// Get specified monitor width (current video mode used by monitor)
  static int GetMonitorWidth(int monitor) => _getMonitorWidth(monitor);
  /// Get specified monitor height (current video mode used by monitor)
  static int GetMonitorHeight(int monitor) => _getMonitorHeight(monitor);
  /// Get specified monitor physical width in millimetres
  static int GetMonitorPhysicalWidth(int monitor) => _getMonitorPhysicalWidth(monitor);
  /// Get specified monitor physical height in millimetres
  static int GetMonitorPhysicalHeight(int monitor) => _getMonitorPhysicalHeight(monitor);
  /// Get specified monitor refresh rate
  static int GetMonitorRefreshRate(int monitor) => _getMonitorRefreshRate(monitor);
  /// Get window position XY on monitor
  static Vector2 GetPosition()
  {
    Vector2 position = Vector2();
    position._setmemory(_getWindowPosition());

    return position;
  }
  /// Get window scale DPI factor
  static Vector2 GetScaleDPI()
  {
    Vector2 position = Vector2();
    position._setmemory(_getWindowScaleDPI());
    
    return position;
  }
  /// Get the human-readable, UTF-8 encoded name of the specified monitor
  static String GetMonitorName(int monitor) => _getMonitorName(monitor).toDartString();
  /// Set clipboard text content
  static void SetClipboardText(String text)
  {
    using((Arena arena) {
      Pointer<Utf8> cText = text.toNativeUtf8(allocator: arena);

      _setClipboardText(cText);
    });
  }
  /// Get clipboard text content
  static String GetClipboardText() => _getClipboardText().toDartString();
  /// Get clipboard image content
  static Image GetClipboardImage() => Image._internal(_getClipboardImage());
  /// Enable waiting for events on EndDrawing(), no automatic event polling
  static void EnableEventWaiting() => _enableEventWaiting();
  /// Disable waiting for events on EndDrawing(), automatic events polling
  static void DisabelEventWaiting() => _disableEventWaiting();
  /// Set a custom key to exit program (default is ESC)
  static void SetExitKey(int key) => _setExitKey(key);
}

//------------------------------------------------------------------------------------
//                                   Frame
//------------------------------------------------------------------------------------

/// Timing-related functions
abstract class Frame
{
  /// Set target FPS (maximum)
  static void SetTargetFPS(int fps) => _setTargetFPS(fps);
  /// Get time in seconds for last frame drawn (delta time)
  static double GetFrameTime() => _getFrameTime();
  /// Get elapsed time in seconds since InitWindow()
  static double GetTime() => _getTime();
  /// Get current FPS
  static int GetFPS() => _getFPS();
}

/*
  Wave
  VrDeviceInfo
  VrStereoConfig
  FilePathList
  AutomationEvent
  AutomationEventList
*/


//------------------------------------------------------------------------------------
//                                   FilePath List
//------------------------------------------------------------------------------------

class FilePathList implements Disposeable
{
  NativeResource<_FilePathList>? _memory;
  _FilePathList get ref => _memory!.pointer.ref;
  final bool droppedFiles;

  List<String> paths = [];

  void _setmemory(_FilePathList result, bool dropped)
  {
    Pointer<_FilePathList> pointer = malloc.allocate<_FilePathList>(sizeOf<_FilePathList>());
    pointer.ref = result;

    for (int x = 0; x < pointer.ref.count; x++) {
      final cstring = pointer.ref.paths[x].toDartString();
      paths.add(cstring);
    }

    _memory = NativeResource<_FilePathList>(pointer);
    _finalizer.attach(this, {'ptr': pointer, 'type': dropped}, detach: this);
  }
  /* 
  FilePathList._recieve(_FilePathList result)
  {
    _setmemory(result);
  }
  */
  /// Load directory filepaths
  FilePathList(String dirPath) : droppedFiles = false
  {
    using ((Arena arena) {
      final cdirPath = dirPath.toNativeUtf8(allocator: arena);

      _FilePathList result = _loadDirectoryFiles(cdirPath);
      _setmemory(result, false);
    });
  }

  /// Load directory filepaths with extension filtering and recursive directory scan. Use 'DIR' in the filter string to include directories in the result
  FilePathList.Ex(String basePath, String filter, bool scanSubdirs) : droppedFiles = false
  {
    using ((Arena arena) {
      final cbasePath = basePath.toNativeUtf8(allocator: arena);
      final cfilter = filter.toNativeUtf8(allocator: arena);

      _FilePathList result = _loadDirectoryFilesEx(cbasePath, cfilter, scanSubdirs);
      _setmemory(result, false);
    });
  }

  FilePathList.Dropped() : droppedFiles = true
  {
    _FilePathList result = _loadDroppedFiles();
    _setmemory(result, false);
  }

  /// Check if a file has been dropped into window
  static bool IsFileDropped() => _isFileDropped();

  static final Finalizer _finalizer = Finalizer<Map<String, dynamic>>((pointer) {
    if (pointer['type']) _unloadDroppedFiles(pointer['ptr'].ref);
    else _unloadDirectoryFiles(pointer['ptr'].ref);
    malloc.free(pointer['ptr']);
  });

  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed) {
      _finalizer.detach(this);
      if (droppedFiles) _unloadDroppedFiles(ref);
      else _unloadDirectoryFiles(ref);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                ScreenToWorld
//------------------------------------------------------------------------------------

abstract class ScreenToWorld
{
  /// Get a ray trace from screen position (i.e mouse)
  static Ray GetRay(Vector2 position, Camera camera) => Ray._recieve(_getScreenToWorldRay(position.ref, camera.ref));
  /// Get a ray trace from screen position (i.e mouse) in a viewport
  static Ray GetRayEx(Vector2 position, Camera camera,{ required int width, required int height }) => Ray._recieve(_getScreenToWorldRayEx(position.ref, camera.ref, width, height));
  /// Get the screen space position for a 3d world space position
  static Vector2 GetWorldToScreen(Vector3 position, Camera camera) => Vector2._internal(_getWorldToScreen(position.ref, camera.ref));
  /// Get size position for a 3d world space position
  static Vector2 GetWorldToScreenEx(Vector3 position, Camera camera,{ required int width, required int height }) => Vector2._internal(_getWorldToScreenEx(position.ref, camera.ref, width, height));
  /// Get the screen space position for a 2d camera world space position
  static Vector2 GetWorldToScreen2D(Vector2 position, Camera2D camera) => Vector2._internal(_getWorldToScreen2D(position.ref, camera.ref));
  /// Get the world space position for a 2d camera screen space position
  static Vector2 GetScreenToWorld2D(Vector2 position, Camera2D camera) => Vector2._internal(_getScreenToWorld2D(position.ref, camera.ref));
  /// Get camera transform matrix (view matrix)
  static Matrix GetMatrix(Camera camera) => Matrix._recieve(_getCameraMatrix(camera.ref));
  /// Get camera 2d transform matrix
  static Matrix GetCameraMatrix2D(Camera2D camera) => Matrix._recieve(_getCameraMatrix2D(camera.ref));
}

//------------------------------------------------------------------------------------
//                                   Draw
//------------------------------------------------------------------------------------

/// Drawing-related functions
abstract class Draw
{
  /// Set background color (framebuffer clear color)
  static void ClearBackground(Color color) => _clearBackground(color.ref);
  /// Setup canvas (framebuffer) to start drawing
  static void Begin() => _beginDrawing();
  /// End canvas drawing and swap buffers (double buffering)
  static void End() => _endDrawing();
  /// Update screen by calling `Begin()` `renderLogic()` and `End()` while also clearing the background
  static void RenderFrame({
    required void Function() renderLogic,
  }) {
    Begin();
    renderLogic();
    End();
  }

  /// Begin 2D mode with custom camera (2D)
  static void Begin2DMode(Camera2D camera) => _beginMode2D(camera.ref);
  /// Ends 2D mode with custom camera
  static void End2DMode() => _endMode2D();
  /// Update screen by calling `Begin2D()` `renderLogic()` and `End2D()` while also clearing the backgroundbackground
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void Render2DMode({
    required void Function() renderLogic,
    required Camera2D camera,
  }) {
    Begin2DMode(camera);
    renderLogic();
    End2DMode();
  }

  /// Begin 3D mode with custom camera (3D)
  static void Begin3DMode(Camera3D camera) => _beginMode3D(camera.ref);
  /// Ends 3D mode and returns to default 2D orthographic mode
  static void End3DMode() => _endMode3D();
  /// Update screen by calling `Begin3D()` `renderLogic()` and `End3D()` while also clearing the background
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void Render3DMode({
    required void Function() renderLogic,
    required Camera3D camera,
  }) {
    Begin3DMode(camera);
    renderLogic();
    End3DMode();
  }

  /// Begin drawing to render texture
  static void BeginTextureMode(RenderTexture2D render) => _beginTextureMode(render.ref);
  /// Ends drawing to render texture
  static void EndTextureMode() => _endTextureMode();
  /// Update screen by calling `BeginTextureMode()` `renderLogic()` and `EndTextureMode()` while also clearing the backgroundbackground
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void RenderTextureMode({
    required void Function() renderLogic,
    required RenderTexture2D render,
  }) {
    BeginTextureMode(render);
    renderLogic();
    EndTextureMode();
  }

  /// Begin custom shader drawing
  static void BeginShaderMode(Shader shader) => _beginShaderMode(shader.ref);
  /// End custom shader drawing (use default shader)
  static void EndShaderMode() => _endShaderMode();
  /// Update screen by calling `BeginShaderMode()` `renderLogic()` and `EndShaderMode()`
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void RenderShaderMode({
    required Shader shader,
    required void Function() renderLogic,
  }) {
    BeginShaderMode(shader);
    renderLogic();
    EndShaderMode();
  }

  /// Begin blending mode (alpha, additive, multiplied, subtract, custom)
  static void BeginBlendMode(int mode) => _beginBlendMode(mode);
  /// End blending mode (reset to default: alpha blending)
  static void EndBlendMode() => _endBlendMode();
  /// Update screen by calling `BeginBlendMode()` `renderLogic()` and `EndBlendMode()`
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void RenderBlendMode({
    required int mode,
    required void Function() renderLogic,
  }) {
    BeginBlendMode(mode);
    renderLogic();
    EndBlendMode();
  }

  /// Begin scissor mode (define screen area for following drawing)
  static void BeginScissorMode(int x, int y, int width, int height) => _beginScissorMode(x, y, width, height);
  /// End scissor mode
  static void EndScissorMode() => _endScissorMode();
  /// Update screen by calling `BeginScissorMode()` `renderLogic()` and `EndScissorMode()`
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void RenderScissorMode({
    required Rectangle rect,
    required void Function() renderLogic,
  }) {
    BeginScissorMode(
      rect.x.round(), rect.y.round(),
      rect.width.round(), rect.height.round()
    );
    renderLogic();
    EndScissorMode();
  }

  /// Begin stereo rendering (requires VR simulator)
  static void BeginVrStereoMode(VrStereoConfig config) => _beginVrStereoMode(config.ref);
  /// End stereo rendering (requires VR simulator)
  static void EndVrStereoMode() => _endVrStereoMode();
  /// Update screen by calling `BeginVrStereoMode()` `renderLogic()` and `EndVrStereoMode()`
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void RenderVrStereoMode({required VrStereoConfig config, required void Function() renderLogic}) {
    BeginVrStereoMode(config);
    renderLogic();
    EndVrStereoMode();
  }
}