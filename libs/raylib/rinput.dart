part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                            Input handling functions
//------------------------------------------------------------------------------------

abstract class Cursor
{
  /// Shows cursor
  static void Show() => _showCursor();
  /// Hides cursor
  static void Hide() => _hideCursor();
  /// Check if cursor is not visible
  static bool IsHidden() => _isCursorHidden();
  /// Enables cursor (unlock cursor)
  static void Enable() => _enableCursor();
  /// Disables cursor (lock cursor)
  static void Disable() => _disableCursor();
  /// Check if cursor is on the screen
  static bool IsOnScreen() => _isCursorOnScreen();
  /// Set mouse cursor
  static void Set(int cursor) => _setMouseCursor(cursor);
}

abstract class Gestures
{
  /// Enable a set of gestures using flags
  static void SetEnabled(int flags) => _setGesturesEnabled(flags);
  /// Check if a gesture have been detected
  static void IsDetected(int gesture) => _isGestureDetected(gesture);
  /// Get latest detected gesture
  static int GetDetected() => _getGestureDetected();
  /// Get gesture hold time in seconds
  static double GetHoldDuration() => _getGestureHoldDuration();
  /// Get gesture drag vector
  static Vector2 GetDragVector() => Vector2._internal(_getGestureDragVector());
  /// Get gesture drag angle
  static double GetDragAngle() => _getGestureDragAngle().toDouble();
  /// Get gesture pinch delta
  static Vector2 GetPinchVector() => Vector2._internal(_getGesturePinchVector());
  /// Get gesture pinch angle
  static double GetPinchAngle() => _getGesturePinchAngle().toDouble();
}

//------------------------------------------------------------------------------------
//                            Input trigger functions
//------------------------------------------------------------------------------------

/// Keyboard related functions
abstract class Key
{
  /// Check if a key has been pressed once
  static bool IsPressed(int key) => _isKeyPressed(key);
  /// Check if a key has been pressed again
  static bool IsPressedRepeat(int key) => _isKeyPressedRepeat(key);
  /// Check if a key is being pressed
  static bool IsDown(int key) => _isKeyDown(key);
  /// Check if a key is NOT being pressed
  static bool IsUp(int key) => _isKeyUp(key);
  /// Check if a key has been released once
  static bool IsReleased(int key) => _isKeyReleased(key);
  /// Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
  static int Get() => _getKeyPressed();
  /// Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
  static String GetChar() => _getCharPressed().toString();
  /// Get name of a QWERTY key on the current keyboard layout (eg returns string 'q' for KEY_A on an AZERTY keyboard)
  static String GetName() => _getKeyName().toDartString();
}

/// Mouse related functions
abstract class Mouse
{ 
  /// Check if a mouse button has been pressed once
  static bool IsButtonDown(int button) => _isMouseButtonDown(button);
  /// Check if a mouse button is NOT being pressed
  static bool IsButtonUp(int button) => _isMouseButtonUp(button);
  /// Check if a mouse button has been pressed once
  static bool IsPressed(int button) => _isMouseButtonPressed(button);
  /// Check if a mouse button has been released once
  static bool IsReleased(int button) => _isMouseButtonReleased(button);
  // Get mouse position X
  static int GetX() => _getMouseX();
  /// Get mouse position Y
  static int GetY() => _getMouseY();
  /// Get mouse position XY
  static Vector2 GetPosition() => Vector2._internal(_getMousePosition());
  /// Get mouse delta between frames
  static Vector2 GetPositionDelta() => Vector2._internal(_getMouseDelta());
  /// Set mouse position XY
  static void SetPosition(int x, int y) => _setMousePosition(x, y);
  /// Set mouse offset
  static void SetOffset(int offsetX, int offsetY) => _setMouseOffset(offsetX, offsetY);
  /// Set mouse scaling
  static void SetScale(double scaleX, double scaleY) => _setMouseScale(scaleX, scaleY);
  /// Get mouse wheel movement for X or Y, whichever is larger
  static double GetWheelMove() => _getMouseWheelMove().toDouble();
  /// Get mouse wheel movement for both X and Y
  static Vector2 GetWheelMoveV() => Vector2._internal(_getMouseWheelMoveV());
}

/// Gamepad related functions
abstract class Gamepad
{
  /// Check if a gamepad is available
  static bool IsAvaiable(int gamepad) => _isGamepadAvailable(gamepad);
  /// Get gamepad internal name id
  static String GetName(int gamepad) => _getGamepadName(gamepad).toDartString();
  /// Check if a gamepad button is being pressed
  static bool IsButtonDown(int gamepad, int button) => _isGamepadButtonDown(gamepad, button);
  /// Check if a gamepad button is NOT being pressed
  static bool IsButtonUp(int gamepad, int button) => _isGamepadButtonUp(gamepad, button);
  /// Check if a gamepad button has been pressed once
  static bool IsButtonPressed(int gamepad, int button) => _isGamepadButtonPressed(gamepad, button);
  /// Get the last gamepad button pressed
  static int GetButtonPressed() => _getGamepadButtonPressed();
  /// Check if a gamepad button is being pressed
  static bool IsButtonReleased(int gamepad, int button) => _isGamepadButtonReleased(gamepad, button);
  /// Get axis count for a gamepad
  static int GetAxisCount(int gamepad) => _getGamepadAxisCount(gamepad);
  /// Get movement value for a gamepad axis
  static double GetAxisMovement(int gamepad, int axis) => _getGamepadAxisMovement(gamepad, axis);
  /// Set internal gamepad mappings (SDL_GameControllerDB)
  static int SetMappins(String mappings)
  {
    return using ((Arena arena) {
      Pointer<Utf8> cmappings = mappings.toNativeUtf8(allocator: arena);

      return _setGamepadMappings(cmappings);
    });
  }
  /// Set gamepad vibration for both motors (duration in seconds)
  static void SetVibration(int gamepad,{ required double leftMotor, required double rightMotor, required double duration })
  {
    _setGamepadVibration(gamepad, leftMotor, rightMotor, duration);
  }
}

/// Touch related functions
abstract class Touch
{
  // I could probably setup some type of initializer which gets the points count
  /// Get touch position X for touch point 0 (relative to screen size)
  static int GetX() => _getTouchX();
  /// Get touch position Y for touch point 0 (relative to screen size)
  static int GetY() => _getTouchY();
  /// Get touch position XY for a touch point index (relative to screen size)
  static Vector2 GetPosition(int index) => Vector2._internal(_getTouchPosition(index));
  /// Get touch point identifier for given index
  static int GetPointId(int index) => _getTouchPointId(index);
  /// Get number of touch points
  static int GetPointCount() => _getTouchPointCount();
}
