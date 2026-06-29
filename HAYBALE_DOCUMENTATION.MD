# Haybale UI Builder Manual

Haybale is a simple UI package built on top of the `Raylib` bindings package, inspired by Flutter, that implements basic widgets for layout management.

## Widgets Reference

| Widget | Description |
|--------|-------------|
| Center | Centers its child within the widget rectangle pivot |
| Padding | Adjusts the child's `width`, `height`, `x`, and `y`, drawing it inside the padded bounds |
| Column | Arranges `children` vertically with `mainAxis` and `crossAxis` |
| Row | Arranges `children` horizontally with `mainAxis` and `crossAxis` |
| TextBox | Renders `text` inside the defined size with line wrapping and clipping at the bottom |
| Grid | Draws a grid of widgets using a fixed `cellSize` for all `children` |
| ListView | Draws a scrollable list of widgets inside the defined size, offsetting children by `scroll` |
| Stack | Draws children on top of one another in order from first to last |
| Canvas | Manages a `RenderTexture` with a `scale` parameter, updates input coordinates, and adjusts mouse position for `IInteractible` children |
| IInteractible | A base class for input-interactable widgets that maintains interaction state |
| Router | Static navigation manager for route widgets and transitions |

| Widget Parameters | Description |
|--------|-------------|
| HaySize | Tells how the widget should be scaled on the size change of the parent |
| HayXAxisAlign | Defines horizontal text and widget alignment options |
| HayYAxisAlign | Defines vertical text and widget alignment options |
| HayPadding | Defines spacing around widget content in a Container | 

## Creating a Widget tree

The Widget class defines two cycles/methods by default:

- **Mount:** called on parameter change and propagates to its children
- **DrawWidget:** calls Raylib draw functions on the current and the children
  
The Mount method is equivalent to a fixed update loop. It is to be called on window resize, widget resize, or any logic procedure.

The DrawWidget method contains the functions to draw that widget to the screen, proceeding with drawing the children in the hierarchy.

```dart
// DEV NOTE: Its recomended to write these procedures outside of the main loop
// so they are caught in Dart VM hot reload.

// stopWatch instance to time the fixed update
final stopWatch = Stopwatch()..start();

// Example on a fixed time loop update 
void FixedUpdate() {
  final deltaTime = stopWatch.elapsedMilliseconds / 1000;
  if (deltaTime < updateTime) return;
  stopWatch.reset();
  
  if (Window.IsResized())
    screen.Mount();
}

// Example on a simple draw update call
void DrawUpdate() {
  Draw.Begin();
    Draw.ClearBackground(Color.GOLD);

    screen.DrawWidget();
  Draw.End();
}

void main() {
  Window.SetFlags(vsync: true, resizable: true);
  Window.Init(width: 1280, height: 720, title: "Raylib - Example");
  Frame.SetTargetFPS(FPS);

  while(!Window.ShouldClose()) {
    FixedUpdate();
    DrawUpdate();
  }

  Window.Close();
}
```

### HaySize
All widgets must have this parameter implemented to compute the size and position changes. The `HaySize` parameter supports fixed dimensions or flexible layout behavior:
- `HaySize(width: 300, height: 200)`: fixed size.
- `HaySize.Expand()`: takes all available space.
- `HaySize.FullWidth(height: 50)`: takes all available width and a fixed height.
- `HaySize.FullHeight(width: 150)`: takes all available height and a fixed width.

Haybale's main purpose is to give the user the foundation to create new widgets without worrying about position and interaction computations. All visual widgets must be implemented by the user.

### HayPadding
The `HayPadding` parameter defines inset spacing for child widgets.
- `HayPadding.All(value)`: same padding on all sides.
- `HayPadding.BTLR(bottom, top, left, right)`: custom values for each side.
- `HayPadding.Symetric(vertical, horizontal)`: separate vertical and horizontal padding.

## Building The Widget Tree

All UIs begin with a root widget, a layout widget:
```dart
// Root widget
Canvas screen = Canvas(
  child: Stack(
    children: [
      Card(
        sizing: HaySize.Expand(), // Fill the background
        panel: viggnete,
        panelSelected: viggnete,
        nPtach: 0
      ), // User defined Card widget to draw a vignete texture
      Card(
        sizing: HaySize(width: 300, height: 200),
        panel: panel,
        panelSelected: panelSelected,
        nPtach: 12,
        child: Padding(
          padding: HayPadding.All(5.0),
          child: TextBox(text: 'Placeholder', fontSize: 24.0)
        ) // Padding
      ) // User defined Card widget to draw a NPATCH texture
    ]
  ) // Stack
);
```

Among the default classes, two are built to work as the root of the hierarchy:
- Canvas: defines an internal RenderTexture with a scale modifier, automatically mirroring the y axis.
- Router: manages which route widget is active and handles page transitions and widget draw call.
  
Then, the `Mount` and `DrawWidget` methods should be called in the user defined Update Loop and Draw loop respectivelly.
Should the user not use Canvas widget or Router utility class, `SetSizing()` method should be called with the window `width` and `height` values in their update loop.

## Implementing IInteractible

IInteractible class helps the user manage interaction management in the widget tree, locking onto the active widget when when `onSelect` and `onPress` computes as true.

**Under the hood:**
```dart
// UpdateState method defined for all IInteractible instances
// continuously checks the conditions to check a user interaction
//
// Returns true when [this] widget detects an interaction. Check for return when
// updating a list of widgets as to not overlap the next widget trigger.
bool UpdateState() {
  // After sucessfully detects a user interaction to a widget, it begins to only
  // check if the user has stopped the interaction. Eg. he has released the mouse.
  if (this == PinnedWidget) {
    if (OnUnfocus()) {
      PinnedWidget = null;
      state = .Selected;

      OnPress(); // Function to call when the widget has been interacted with
    }

    return true;
  }

  // Checks the conditions to detect a interactin. The method defayults to check
  // if the mouse is hovering over the widget [interactArea];
  //
  // Skips further checks if, for example, the user is not hovering the mouse
  // over [this].
  if (!OnSelect()) {
    if (state == .Selected) {
      Cursor.Set(.DEFAULT);
      state = .Idle;
    }
    
    return false;
  }
  
  // Selected, but no interaction
  if (state == .Idle) {
    state = .Selected;
    Cursor.Set(cursor);
  }

  // Compute iteraction. Eg. the user has clicked the widget
  if (OnFocus()) {
    PinnedWidget = this;
    state = .Pressed;
  }

  // When interacted, skip all the remaining Interactible Widgets Updates
  return true;
}
```

The IInteractible class inherits form Widget class, define `required super.sizing` to reroute the parameter to the parent constructor, which also goes for the anonymous functions.

### Ex:
```dart
// Button example in the "examples/" folder
// IInteractible extends Widget class and contains the necessary parameters
// to compute a user interaction
class Button extends IInteractible
{
  Texture? buttonTexture;
  late Rectangle buttonRect;
  TextBox text;

  Button({
    required super.sizing,
    this.buttonTexture,
    required this.text,
    super.OnPress,
    super.OnFocus,
    super.OnUnfocus,
    super.OnSelect,
    super.cursor
  }) {
    if (buttonTexture != null)
      buttonRect = Rectangle(0.0, 0.0, buttonTexture!.width.toDouble(), buttonTexture!.height.toDouble());
  }

  @override
  void Mount() {
    if (buttonTexture == null)
      buttonRect = Rectangle(0.0, 0.0, width, height);

	// Updating member widget sizing
    text.SetSizing(width, height);
	// Calling mount after size set
    text.Mount();
	// Centering the widget to the parent's bounds
    text.Set(x: x + (width - text.width) / 2, y: y + (height - text.fontSize) / 2);
  }

  @override
  void DrawWidget() {
    if (buttonTexture != null) {
	  // Computing the source rectangle to draw pull from
      var src = Rectangle(0.0, 0.0, buttonTexture!.width.toDouble(), buttonTexture!.height.toDouble());
	  // DEV NOTE: [interactArea] is a [IInteractible] getter used for custom interaction behavior
      Texture.DrawPro(buttonTexture!, src, interactArea);
      src.Free();
    }
    else {
	  // Using [this] instance as a draw parameter
      Shapes.DrawRectangleRounded(this, 0.1, 1, color: state == .Pressed ? .LIGHTGRAY : .GRAY);
    }
    text.DrawWidget();
  }

  [...]
}
```