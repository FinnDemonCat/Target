import '../libs/raylib/raylib.dart';
import 'dart:math' as math;
import 'package:meta/meta.dart';

/// ## HayXAxisAlign Enum
/// 
/// Defines horizontal text and widget alignment options.
/// 
/// - **LEFT**: Align to the left edge
/// - **CENTER**: Center horizontally
/// - **RIGHT**: Align to the right edge
enum HayXAxisAlign {
  LEFT,
  RIGHT,
  CENTER
}

/// ## HayYAxisAlign Enum
/// 
/// The `HayYAxisAlign` enum specifies how widgets are aligned along the vertical axis (main-axis in layout):
/// - **TOP**: Align to the top edge
/// - **CENTER**: Center vertically
/// - **BOTTOM**: Align to the bottom edge
enum HayYAxisAlign {
  TOP,
  CENTER,
  BOTTOM
}

/// ## HaySize Parameter
/// 
/// Defines widget sizing with support for fixed and flexible dimensions.
/// 
/// ## Purpose
/// 
/// The `HaySize` parameter class controls how widgets are sized within the layout system:
/// - Specifies both width and height for a widget
/// - Supports fixed pixel values or dynamic expansion
/// 
/// ## Features
/// 
/// - **Fixed Sizing**: Define exact pixel dimensions
/// - **Factory Constructors**: Predefined patterns like `Grow()`, `FullWidth()`, `FullHeight()`
/// - **Responsive Design**: Widgets automatically adjust size based on parent constraints
/// 
/// ## Usage
/// 
/// ```dart
/// // Fixed size: 200x100 pixels
/// HaySize fixed = HaySize(width: 200, heigth: 100);
/// 
/// // Expand to fill all available space
/// HaySize grow = HaySize.Grow();
/// 
/// // Expand width, fixed height
/// HaySize fullWidth = HaySize.FullWidth(heigth: 50);
/// 
/// // Fixed width, expand height
/// HaySize fullHeight = HaySize.FullHeight(width: 150);
/// ```
class HaySize
{
  final double width, height;

  static const double ExpandWidth = -1;
  static const double ExpandHeight = -1;

  const HaySize({required this.width, required this.height});
  const HaySize.Grow() : width = ExpandWidth, height = ExpandHeight;
  const HaySize.FullWidth({required this.height}) : width = ExpandWidth;
  const HaySize.FullHeight({required this.width}) : height = ExpandHeight;
}

/// # HayPadding Parameter
/// 
/// Defines spacing around widget content in a Container.
/// 
/// - **Uniform Padding**: Same padding on all sides
/// - **Symmetric Padding**: Different values for vertical and horizontal spacing
/// - **Custom Padding**: Individual control over each edge (Bottom, Top, Left, Right)
/// 
/// ## Usage
/// 
/// ```dart
/// // Equal padding on all sides: 10 pixels
/// HayPadding uniform = HayPadding.All(10);
/// 
/// // Symmetric padding: 5px vertical, 10px horizontal
/// HayPadding symmetric = HayPadding.Symetric(5, 10);
/// 
/// // Custom padding: bottom, top, left, right
/// HayPadding custom = HayPadding.BTLR(5, 10, 15, 20);
/// ```
class HayPadding
{
  double bottom, top, left, right;

  HayPadding.All([double value = 0])
    : bottom = value, top = value, left = value, right = value;

  HayPadding.BTLR([this.bottom = 0, this.top = 0, this.left = 0, this.right = 0]);

  HayPadding.Symetric([double vertical = 0, double horizontal = 0])
    : bottom = vertical, top = vertical, left = horizontal, right = horizontal;
}

/// # Widget Base Class
/// 
/// The foundational class for all UI widgets in the Haybale layout system.
/// 
/// ## Purpose
/// 
/// The `Widget` class serves as the base class for all UI components in the Haybale framework:
/// - Extends `Rectangle` to provide positioning and sizing capabilities
/// - Defines the core lifecycle methods: `Mount()`, `DrawWidget()`, and `Dispose()`
/// - Establishes a consistent interface that all widget subclasses must implement
/// - Manages widget sizing through the `HaySize` parameter class
/// 
/// ## Example
/// 
/// ```dart
/// // Create a custom widget by extending Widget
/// class MyCustomWidget extends Widget {
///   MyCustomWidget() : super(sizing: HaySize.Grow());
///   
///   @override
///   void Mount() {
///     // Initialize or recalculate widget layout
///     super.x = 0;
///     super.y = 0;
///   }
///   
///   @override
///   void DrawWidget() {
///     // Render the widget to screen
///     Draw.Rectangle(this, Color.BLUE);
///   }
/// }
/// ```
class Widget extends Rectangle
{
  final HaySize sizing;

  Widget({
    required this.sizing
  }) :
    super(0.0, 0.0, sizing.width, sizing.height);

  void Mount() {}
  void DrawWidget() {}

  void SetSizing([double width = 0.0, double height = 0.0]) {
    if (sizing.width == -1) this.width = width;
    else this.width = sizing.width;

    if (sizing.height == -1) this.height = height;
    else this.height = sizing.height;
  }

  @mustCallSuper
  @override
  void Dispose() {
    super.Dispose();
  }
}

class Center extends Widget
{
  Widget widget;

  Center({
    required HaySize sizing,
    required this.widget,
  }) :
    super(sizing: sizing);

  @override
  void Mount() {
    widget.SetSizing(width, height);
    widget.Set(x: (width - widget.width) / 2, y: (height - widget.height) / 2);

    widget.Mount();
  }

  @override
  void DrawWidget() {
    if (widget case Interactible interactible)
      interactible.UpdateState();
    
    widget.DrawWidget();
  }

  @override
  void Dispose() {
    widget.Dispose();
    super.Dispose();
  }
}

/// # Column Widget
/// 
/// A layout widget that arranges child widgets vertically with customizable alignment and spacing.
/// 
/// ## Features
/// 
/// - **Flexible Alignment**: `mainAxis` controls vertical alignment (TOP, CENTER, BOTTOM)
/// - **Cross Axis Control**: `crossAxis` controls horizontal alignment (LEFT, CENTER, RIGHT)
/// - **Spacing**: Configurable gap between child widgets
/// - **Responsive Sizing**: Expands children to fill available space when configured
/// 
/// ## Example
/// 
/// ```dart
/// Column myColumn = Column(
///   sizing: HaySize.FullHeight(width: 200),
///   spacing: 10,
///   mainAxis: .CENTER,
///   crossAxis: .CENTER,
///   children: [
///     ChildWidget(),
///     ChildWidget(),
///     ChildWidget()
///   ]
/// );
/// 
/// void main() {
///   Window.Init(width: 800, height: 600, title: "Column Example");
///   Canvas canvas = Canvas(800.0, 600.0);
///   canvas.AddWidgetToLayer([myColumn], "default", 1);
///   canvas.Mount();
///   
///   while(!Window.ShouldClose()) {
///     Draw.RenderFrame(renderLogic: DrawScreen);
///   }
///   
///   canvas.Dispose();
///   Window.Close();
/// }
/// 
/// void DrawScreen() {
///   Draw.ClearBackground(Color.WHITE);
///   if (Window.IsResized()) canvas.Mount();
///   canvas.DrawWidget();
/// }
/// ```
class Column extends Widget
{
  HayYAxisAlign MainAxis;
  HayXAxisAlign CrossAxis;
  List<Widget> widgets;
  double spacing;

  Column({
    required super.sizing,
    List<Widget>? children,
    this.spacing = 0.0,
    HayYAxisAlign? mainAxis,
    HayXAxisAlign? crossAxis,
  }) : 
    widgets = children ?? [],
    MainAxis = mainAxis ?? HayYAxisAlign.TOP,
    CrossAxis = crossAxis ?? HayXAxisAlign.LEFT;

  @override
  void DrawWidget()
  {
    for (Widget widget in widgets)
      widget.DrawWidget();
    
    Interactible.UpdateWidgets(widgets);
  }

  @override
  void Mount()
  {
    double startY = super.y;
    double widHeight = widgets.fold(0, (x, y) => x + y.height);

    widHeight += (widgets.length - 1) * spacing;
    if (widHeight > height) widHeight = height;

    switch(MainAxis)
    {
      case HayYAxisAlign.CENTER:
        startY = (height - widHeight) / 2;
        break;
      case HayYAxisAlign.BOTTOM:
        startY = height - widHeight;
        break;
      default:
        break;
    }
    
    for (int index = 0; index < widgets.length; index++)
    {
      switch (CrossAxis)
      {
        case HayXAxisAlign.CENTER:
          widgets[index].x = (width - widgets[index].width) / 2;
          widgets[index].x += x;
          break;
        case HayXAxisAlign.RIGHT:
          widgets[index].x = width - widgets[index].width;
          widgets[index].x += x;
          break;
        default:
          widgets[index].x = x;
          break;
      }

      widgets[index].SetSizing(width, height);
      widgets[index].y = startY + index*(widgets[index].height + spacing);
      widgets[index].Mount();
    }
  }

  @override
  void Dispose() {
    for (Widget widget in widgets)
      widget.Dispose();
    
    super.Dispose();
  }
}

/// # Row Widget
/// 
/// A layout widget that arranges child widgets horizontally with customizable alignment and spacing.
/// 
/// ## Features
/// 
/// - **Flexible Alignment**: `mainAxis` controls vertical alignment (TOP, CENTER, BOTTOM)
/// - **Cross Axis Control**: `crossAxis` controls horizontal alignment (LEFT, CENTER, RIGHT)
/// - **Spacing**: Configurable gap between child widgets
/// - **Responsive Sizing**: Expands children to fill available space when configured
/// 
/// ## Example
/// 
/// ```dart
/// Row myRow = Row(
///   sizing: HaySize.Grow(),
///   spacing: 15,
///   mainAxis: .CENTER,
///   crossAxis: .CENTER,
///   children: [
///     ChildWidget(),
///     ChildWidget(),
///     ChildWidget()
///   ]
/// );
/// 
/// void main() {
///   Window.Init(width: 800, height: 600, title: "Row Example");
///   Canvas canvas = Canvas(800.0, 600.0);
///   canvas.AddWidgetToLayer([myRow], "default", 1);
///   canvas.Mount();
///   
///   while(!Window.ShouldClose()) {
///     Draw.RenderFrame(renderLogic: DrawScreen);
///   }
///   
///   canvas.Dispose();
///   Window.Close();
/// }
/// 
/// void DrawScreen() {
///   Draw.ClearBackground(Color.WHITE);
///   if (Window.IsResized()) canvas.Mount();
///   canvas.DrawWidget();
/// }
/// ```
class Row extends Widget
{
  HayYAxisAlign MainAxis = HayYAxisAlign.TOP;
  HayXAxisAlign CrossAxis = HayXAxisAlign.LEFT;

  List<Widget> widgets;
  double spacing;

  Row({
    required super.sizing,
    List<Widget>? children,
    this.spacing = 0.0,
    HayYAxisAlign? mainAxis,
    HayXAxisAlign? crossAxis,
  }) :
    widgets = children ?? [],
    MainAxis = mainAxis ?? HayYAxisAlign.TOP,
    CrossAxis = crossAxis ?? HayXAxisAlign.LEFT;

  @override
  void Mount()
  {
    double widWidth = widgets.fold(0, (x, y) => x + y.width);
    widWidth += (widgets.length - 1) * spacing;
    if (widWidth > width) widWidth = width;

    double startX = x;

    switch(CrossAxis)
    {
      case HayXAxisAlign.CENTER:
        startX = (width - widWidth) / 2;
        break;
      case HayXAxisAlign.RIGHT:
        startX = width - widWidth;
        break;
      default:
        break;
    }

    for (int index = 0; index < widgets.length; index++)
    {
      switch(MainAxis)
      {
        case HayYAxisAlign.BOTTOM:
          widgets[index].y = height - widgets[index].height;
          widgets[index].y += y;
          break;
        case HayYAxisAlign.CENTER:
          widgets[index].y = (height - widgets[index].height) / 2;
          widgets[index].y += y;
          break;
        default:
          widgets[index].y = y;
          break;
      }
      
      widgets[index].SetSizing(width, height);
      widgets[index].x = startX + index*(widgets[index].width + spacing);
      widgets[index].Mount();
    }
  }

  @override
  void DrawWidget()
  {
    for (Widget widget in widgets)
      widget.DrawWidget();

    Interactible.UpdateWidgets(widgets);
  }

  @override
  void Dispose() {
    for (Widget widget in widgets)
      widget.Dispose();
    
    super.Dispose();
  }
}

/// # TextBox Widget
/// 
/// A widget for displaying and rendering multi-line text with custom font, size, and alignment.
/// 
/// ## Purpose
/// 
/// The `TextBox` widget handles text rendering with advanced layout features:
/// - Displays text with custom fonts and sizes
/// - Automatically wraps text when it exceeds available width
/// - Manages line breaking and text metrics
/// 
/// ## Features
/// 
/// - **Font Support**: Uses custom fonts for text rendering
/// - **Text Wrapping**: Automatically wraps text to fit container width
/// - **Alignment Options**: Horizontal alignment for wrapped text
/// - **Color Customization**: Supports custom text colors (defaults to white)
/// - **Spacing Control**: Configurable character spacing
/// 
/// ## Example
/// 
/// ```dart
/// Font arialFont = Font("assets/arial.ttf");
/// 
/// TextBox myTextBox = TextBox(
///   font: arialFont,
///   text: "Hello, this is some sample text that will wrap!",
///   textAlign: .CENTER,
///   fontSize: 24,
///   spacing: 2,
///   color: Color.BLACK
/// );
/// 
/// void main() {
///   Window.Init(width: 800, height: 600, title: "TextBox Example");
///   Canvas canvas = Canvas(800.0, 600.0);
///   canvas.AddWidgetToLayer([myTextBox], "default", 1);
///   canvas.Mount();
///   
///   while(!Window.ShouldClose()) {
///     Draw.RenderFrame(renderLogic: DrawScreen);
///   }
///   
///   canvas.Dispose();
///   arialFont.Dispose();
///   Window.Close();
/// }
/// 
/// void DrawScreen() {
///   Draw.ClearBackground(Color.WHITE);
///   if (Window.IsResized()) canvas.Mount();
///   canvas.DrawWidget();
/// }
/// ```
class TextBox extends Widget
{
  Font font;
  TextCodepoint text;
  HayXAxisAlign textAlign;
  double fontSize;
  double spacing;
  Color color;

  List<({int cut, double width})> lines = [];

  TextBox({
    Font? font,
    required String text,
    this.textAlign = .LEFT,
    required this.fontSize,
    this.spacing = 2.0,
    Color? color
  }) :
    text = TextCodepoint.fromString(text),
    color = color ?? Color.WHITE,
    font = font ?? Font.Default(),
    super(sizing: .Grow());

  @override
  void Mount()
  {
    lines.clear();
    Vector2 size = font.MeasureCodepoints(text, fontSize: fontSize, spacing: spacing);

    if (size.x <= width) {
      lines.add((cut: text.length, width: size.x));
      return;
    }

    double scale = fontSize / font.baseSize;
    double textWidth = 0.0;
    double textHeight = 0.0;
    double widthAtLastSpace = 0.0;
    int pin = 0;
    int lineBreak = 0;

    for (int index = 0; index <= text.length; index++) {      
      if (index == text.length) {
        lines.add((cut: index, width: textWidth));
        break;
      } else if (textHeight > height) {
        break;
      }

      // Get glyph index of codepoints text.buffer[index]
      int codepoint = text.buffer[index];
      int glyphIndex = font.GetGlyphIndex(codepoint);
      // Get glyph info of codepoints `index`
      GlyphInfo glyph = font.GetGlyphInfo(glyphIndex);

      double advanceX = (glyph.advanceX + spacing) * scale;

      if (textWidth + advanceX > width) {
        if (pin > lineBreak){
          textWidth = widthAtLastSpace;
          index = pin;
        } else {
          index--;
        }

        lines.add((cut: index, width: textWidth));
        lineBreak = index;
        textWidth = 0.0;

        textHeight += fontSize;
      } else {
        textWidth += advanceX;
      }

      if (codepoint == 32) {
        pin = index + 1;
        widthAtLastSpace = textWidth;
      }
    }
  }

  @override
  void DrawWidget()
  {
    Draw.WithScissorMode(rect: this, renderLogic: () {
      if (lines.isEmpty) return;
      Vector2 pos = Vector2();

      for(int index = 0; index < lines.length; index++) {
        double posX = 0.0;
        double posY = 0.0;

        switch (textAlign)
        {
          case HayXAxisAlign.RIGHT:
            posX = (width - lines[index].width).clamp(0, width);
            break;
          case HayXAxisAlign.CENTER:
            posX = (width - lines[index].width).clamp(0, width);
            posX /= 2;
            break;
          default:
            break;
        }
        
        pos.x = posX + x;
        posY = index * (fontSize + spacing);
        pos.y = posY + y;

        int length = 0;
        if (index == 0) length = lines[index].cut;
        else length = lines[index].cut - lines[index - 1].cut;

        TextCodepoint.DrawCodepoints(
          font,
          text,
          length,
          fontSize: fontSize,
          spacing: spacing,
          position: pos,
          tint: color,
          index: index == 0 ? 0 : lines[index - 1].cut
        );
      }
    });
  }

  @override
  void Dispose() {
    font.Dispose();
    text.Dispose();

    super.Dispose();
  }
}

enum InteractState {
  Idle,
  Selected,
  Pressed
}

/// # Interactible Widget
/// 
/// A utility base class designed to provide standardized interaction logic 
/// for widgets that respond to mouse input.
/// 
/// ## Architectural Responsibility
/// 
/// `Interactible` is a **passive utility**. For it to function, the **Mouse Position must be set manually** before processing interactions. 
/// 
/// - **Manual Setup**: The user or parent container must update the static [MousePosition] field 
///   at the beginning of every frame/update cycle.
/// - **Canvas Automation**: The [Canvas] widget performs this operation by default, 
///   ensuring all its children have access to the correct global mouse coordinates with the layer defined scale.
/// - **Event Consumption**: It is responsible for breaking interaction loops via [UpdateState] 
///   returning `true`, effectively preventing "click-through" on overlapping elements.
/// 
/// ## Features
/// 
/// - **State Processing**: Encapsulates logic for `Idle`, `Selected`, and `Pressed` states.
/// - **Global Focus Lock**: Uses [PinnedWidget] to maintain interaction (like dragging) 
///   even if the mouse leaves the widget bounds during a hold.
/// - **Visual Feedback**: Automatically requests system [cursor] changes upon interaction.
/// 
/// ## Example: Parent Orchestration
/// 
/// ```dart
/// // Manual orchestration (if not using Canvas)
/// Interactible.MousePosition = currentMousePos;
/// Interactible.UpdateWidgets(myWidgetList); 
/// ```
class Interactible extends Widget
{
  InteractState state;
  MouseCursor cursor;
  static Interactible? PinnedWidget;
  static Vector2 MousePosition = Vector2.Zero();
  void Function()? _OnPress;
  bool Function() _OnFocus;
  bool Function() _OnUnfocus;

  void OnPress() => _OnPress?.call();
  
  Interactible({
    required super.sizing,
    void Function()? OnPress,
    bool Function()? OnFocus,
    bool Function()? OnUnfocus,
    this.cursor = .POINTING_HAND
  }) :
    _OnPress = OnPress,
    _OnFocus = OnFocus ?? (() { return Mouse.IsPressed(.LEFT) || Mouse.IsPressed(.RIGHT); }),
    _OnUnfocus = OnUnfocus ?? (() { return Mouse.IsReleased(.LEFT) || Mouse.IsReleased(.RIGHT); }),
    state = .Idle;

  /// ## Processes mouse interaction and returns the consumption status.
  /// 
  /// ### Logic Flow:
  /// 1. **Pinned Priority**: If this is the [PinnedWidget], it handles [_OnUnfocus] 
  ///    logic and returns `true` to maintain exclusive focus.
  /// 2. **Hit Testing**: Checks if [MousePosition] is within bounds. 
  ///    Returns `false` if not, allowing other widgets to be checked.
  /// 3. **Capture**: If a collision occurs, it updates [state], sets the [cursor], 
  ///    and checks [_OnFocus] to capture the [PinnedWidget].
  /// 
  /// @return `true` if the interaction was consumed (preventing click-through).
  bool UpdateState() {
    if (this == PinnedWidget) {
      if (_OnUnfocus.call()) {
        PinnedWidget = null;
        state = .Selected;

        OnPress();
      }

      return true;
    }

    if (!Collision.CheckPointRec(MousePosition, this)) {
      if (state == .Selected) {
        Cursor.Set(.DEFAULT);
        state = .Idle;
      }
      
      return false;
    }
    
    if (state == .Idle) {
      state = .Selected;
      Cursor.Set(cursor);
    }

    // Compute iteraction
    if (_OnFocus.call()) {
      PinnedWidget = this;
      state = .Pressed;
    }

    // When interacted, skip all the remaining Interactible Widgets Updates
    return true;
  }

  /// ## Centralized logic to update multiple Widgets
  /// 
  /// Orchestrates interaction for a list of widgets. It gives absolute priority 
  /// to the [PinnedWidget] if it exists. Otherwise, it iterates through 
  /// [Interactible] widgets and breaks the loop as soon as one consumes the input.
  static void UpdateWidgets(List<Widget> list) {
    if (PinnedWidget != null) {
      PinnedWidget!.UpdateState();
      return;
    }

    final widgets = list.whereType<Interactible>().toList();

    for (Interactible widget in widgets)
      if (widget.UpdateState()) break;
  }

  @override
  void Dispose() {
    if (PinnedWidget != null && this == PinnedWidget) {
      state = .Idle;
      Cursor.Set(.DEFAULT);
    }

    super.Dispose();
  }
}

typedef Sheet = ({String layer, double scale, List<Widget> children});
/// # Canvas Widget
/// 
/// A root-level container that manages multiple rendering layers (Sheets) using [RenderTexture].
/// 
/// ## Purpose
/// 
/// The `Canvas` acts as the primary orchestrator for the UI system. It:
/// - Manages a list of [Sheet] layers, each with its own scale.
/// - Coordinates the [Mount] and [DrawWidget] lifecycle for all child widgets.
/// - Projects independent layer scales onto the screen space.
/// 
/// ## Features
/// 
/// - **Multi-Layering**: Supports stacked sheets for complex UI depth.
/// - **Dynamic Scaling**: Each sheet can have a unique scale.
/// - **Adaptive Sizing**: Grows to fill the window or follow explicit sizing constraints.
/// 
/// ## Example
/// 
/// ```dart
/// // Create a canvas that fills the screen
/// Canvas mainCanvas = Canvas(
///   layer: "UI",
///   scale: 1.0,
///   children: [myButton, myTextBox]
/// );
/// 
/// // Inside the main loop
/// while(!Window.ShouldClose()) {
///   Draw.RenderFrame(renderLogic: () {
///     Draw.ClearBackground(Color.BLACK);
///     
///     if (Window.IsResized()) mainCanvas.Mount();
///     mainCanvas.DrawWidget();
///   });
/// }
/// ```
class Canvas extends Widget
{
  List<Sheet> layers;
  RenderTexture renderTexture;
  
  Canvas({List<Widget>? children, String layer = "default", double scale = 1.0}) :
    renderTexture = RenderTexture2D(10, 10),
    layers = [(layer: layer, scale: scale, children: children ?? [])],
    super(sizing: HaySize.Grow());
  
  @override
  void Mount() {
    if (sizing.width == -1) width = Window.Width().toDouble();
    if (sizing.height == -1) height = Window.Height().toDouble();

    for (Sheet sheet in layers)
      for (Widget widget in sheet.children) {
        widget.SetSizing(width, height);
        widget.Mount();
      }

    super.Mount();
  }

  @override
  void DrawWidget() {
    Rectangle src = Rectangle();

    for (Sheet sheet in layers) {
      int renderWidth = (width * sheet.scale).round();
      int renderHeight = (height * sheet.scale).round();

      // Resizing RenderTexture to sheet scale
      if (
        renderTexture.width != renderWidth
        || renderTexture.heigth != renderHeight 
      ) {
        renderTexture.Dispose();

        renderTexture = RenderTexture2D(renderWidth, renderHeight);
      }

      Draw.WithTextureMode(
        render: renderTexture,
        renderLogic: () {
          Draw.ClearBackground(.BLANK);

          // Updates Screen
          for (Widget widget in sheet.children)
            widget.DrawWidget();
        }
      );

      Vector2 mouse = Mouse.GetPosition();
      mouse.Scale(sheet.scale);

      Interactible.MousePosition.Set(mouse.x, mouse.y);
      Interactible.UpdateWidgets(sheet.children);

      mouse.Dispose();

      src.Set(width: renderWidth.toDouble(), height: -renderHeight.toDouble());
      Texture2D.DrawPro(renderTexture.texture, src, this);
    }

    src.Dispose();
    super.DrawWidget();
  }

  @override
  void Dispose() {
    for (Sheet sheet in layers)
      for (Widget widget in sheet.children)
        widget.Dispose();
    
    super.Dispose();
  }
}

/// # Grid Widget
/// 
/// A layout container that organizes child widgets into an adaptive grid system with vertical scrolling.
/// 
/// ## Purpose
/// 
/// The `Grid` widget is designed to efficiently display large collections of items by:
/// - Calculating the optimal number of columns based on available [width] and [cellSize].
/// - Distributing [spacing] evenly between columns to fill the container (when spacing is set to `0.0`).
/// - Implementing a vertical scroll system with adjustable [sensitivity].
/// - Optimizing performance by only rendering rows currently visible in the viewport (Row-based Culling).
/// 
/// ## Features
/// 
/// - **Automatic Column Calculation**: Dynamically adapts the column count based on parent constraints and cell size.
/// - **Integrated Padding**: Supports [HayPadding] to manage internal spacing without affecting external layout.
/// - **Smart Scrolling**: Automatically manages the vertical [_scroll] state using mouse wheel input.
/// - **Memory Efficient**: Only processes and draws widgets that are within the active scrollable area.
/// 
/// ## Example
/// 
/// ```dart
/// Grid inventoryGrid = Grid(
///   sizing: HaySize.Fixed(400, 600),
///   cellSize: Vector2(80, 80),
///   padding: HayPadding.All(10.0),
///   sensitivity: 20.0,
///   children: myItemIcons,
/// );
/// 
/// // During the Mount phase, it determines if it fits 4, 5, or more columns.
/// inventoryGrid.Mount();
/// ```
class Grid extends Widget
{
  late int _rows, _cols;
  int get columns => _cols;
  int get rows => _rows;

  Vector2 cellSize;
  double spacing;
  double _scroll = 0.0;
  double _sensitivity = 1.0;
  double _totalHeight = 0.0;
  double _rowStride = 0.0;
  double _colStride = 0.0;

  double get sensitivity => _sensitivity;
  set sensitivity (double value) {
    if (value <= 0.0) value = 0.0;
    _sensitivity = value;
  }

  List<Widget> widgets;
  HayPadding padding;

  double get x => super.x + padding.left;
  double get y => super.y + padding.top;
  double get width => super.width - padding.left - padding.right;
  double get height => super.height - padding.bottom - padding.top;

  Grid({
    required super.sizing,
    required this.cellSize,
    this.spacing = 0.0,
    HayPadding? padding,
    double sensitivity = 0.0,
    List<Widget>? children
  }) :
    widgets = children ?? [],
    padding = padding ?? .All(0.0) {
    this.sensitivity = sensitivity;
  }

  @override
  void Mount() {
    // Clamp cellSize to grid width
    if (cellSize.x > width) cellSize.x = width;

    _cols = (width / cellSize.x).floor();
    _rows = (widgets.length / _cols).ceil();

    if (_cols == 1) return;
    double widWidth = cellSize.x * _cols;
    spacing = (width - widWidth) / (_cols - 1);

    _totalHeight = (cellSize.y * _rows) + (spacing * (_rows - 1));
    _rowStride = (cellSize.y + spacing);
    _colStride = (cellSize.x + spacing);

    for (Widget widget in widgets)
      widget.Set(width: cellSize.x, height: cellSize.y);

    super.Mount();
  }

  @override
  void DrawWidget() {
    // Updating scoll on update
    _scroll -= Mouse.GetWheelMove() * _sensitivity;
    _scroll = _scroll.clamp(0.0, math.max(0.0, _totalHeight - height));

    Draw.WithScissorMode(rect: this, renderLogic: () {
      for (int row = (math.max(0.0, _scroll) / _rowStride).floor(); row < _rows; row++) {
        for (int col = 0; col < _cols; col++) {
          int index = (row * _cols) + col;
          if (index >= widgets.length) break;

          widgets[index].Set(
            x: x + col * _colStride,
            y: y + (row * _rowStride) - _scroll
          );

          widgets[index].DrawWidget();
        }

        for (int col = 0; col < _cols; col++) {
          int index = (row * _cols) + col;
          if (index >= widgets.length) break;
          
          Widget widget = widgets[index];

          if (widget is Interactible)
            if (widget.UpdateState()) break;
        }
      }
    });

    super.DrawWidget();
  }

  @override
  void Dispose() {
    for (Widget widget in widgets)
      widget.Dispose();
    
    super.Dispose();
  }
}

/// # ListView Widget
/// 
/// A linear layout container that arranges child widgets in a single vertical column with scrolling support.
/// 
/// ## Purpose
/// 
/// The `ListView` is the primary tool for creating expanded vertical menus and lists where:
/// - Widgets are placed sequentially in a vertical stack with optional [spacing].
/// - Horizontal positioning is governed by the [alignment] property (LEFT, CENTER, RIGHT).
/// - Large lists are efficiently handled via a clipping-based culling system to maintain performance.
/// 
/// ## Features
/// 
/// - **Flexible Alignment**: Automatically calculates horizontal offsets for each child based on [HayXAxisAlign].
/// - **Interactive Scrolling**: Features a built-in scroll system mapped to the mouse wheel with configurable [sensitivity].
/// - **Collision Culling**: During [DrawWidget], only widgets intersecting the current viewport are rendered, saving draw calls.
/// 
/// ## Example
/// 
/// ```dart
/// ListView sideMenu = ListView(
///   sizing: HaySize.Fixed(200, 400),
///   alignment: HayXAxisAlign.CENTER,
///   padding: HayPadding.Horizontal(20.0),
///   spacing: 10.0,
///   children: [buttonHome, buttonSettings, buttonExit],
/// );
/// 
/// // Mount calculates the total height and initial internal positions.
/// sideMenu.Mount();
/// ```
class ListView extends Widget
{
  HayXAxisAlign aligment;
  HayPadding padding;
  List<Widget> widgets;

  double spacing;
  double _scroll = 0.0;
  double _totalHeight = 0.0;
  double _sensitivity = 1.0;

  double get sensitivity => _sensitivity;
  set sensitivity (double value) {
    if (value <= 0.0) value = 0.0;
    _sensitivity = value;
  }

  double get x => super.x + padding.left;
  double get y => super.y + padding.top;
  double get width => super.width - padding.left - padding.right;
  double get height => super.height - padding.bottom - padding.top;

  ListView({
    required super.sizing,
    this.aligment = .LEFT,
    HayPadding? padding,
    List<Widget>? children,
    this.spacing = 0.0,
    double sensitivity = 0.0
  }) :
    widgets = children ?? [],
    this.padding = padding ?? .All(0.0) {
    this.sensitivity = sensitivity;
  }
    

  @override
  void Mount() {
    _totalHeight = 0.0;

    for (Widget widget in widgets) {
      _totalHeight += widget.height;

      widget.Set(x: x, y: y);
      widget.SetSizing(width, height);

      switch (aligment) {
        case .RIGHT:
          widget.x = x + widget.width - width;
          break;
        case .CENTER:
          widget.x = x + (widget.width - width) / 2;
          break;
        default:
          widget.x = x;
      }

      widget.Mount();
    }

    _totalHeight += spacing * widgets.length - 1;
  }

  @override
  void DrawWidget() {
    // Updating scoll on update
    _scroll -= Mouse.GetWheelMove() * _sensitivity;
    _scroll = _scroll.clamp(0.0, math.max(0.0, _totalHeight - height));

    Draw.WithScissorMode(rect: this, renderLogic: () {
      for (int index = 0; index < widgets.length; index++){
        Widget widget = widgets[index];

        widget.Set(y: y + (widget.height + spacing) * index);
        widget.y -= _scroll;

        if (!Collision.CheckRecs(this, widget))
          continue;

        widget.DrawWidget();
      }
    });

    Interactible.UpdateWidgets(widgets);
    super.DrawWidget();
  }

  @override
  void Dispose() {
    for (Widget widget in widgets)
      widget.Dispose();
    
    super.Dispose();
  }
}

typedef WidgetBuilder = Widget Function();
/// # Page Widget
/// 
/// A layout orchestrator and routing manager that handles the lifecycle of 
/// primary views and overlays.
/// 
/// ## Architectural Responsibility
/// 
/// The `Page` widget acts as a **Root Router**. It manages a [Map] of [WidgetBuilder] 
/// functions to instantiate UI trees on demand, ensuring efficient memory usage 
/// by disposing of unused hierarchies.
/// 
/// - **Route Management**: Handles full-screen widgets defined in [routes].
/// - **Overlay Management**: Manages temporary or persistent top-level widgets (like HUDs or Modals) in [overlays].
/// - **Lifecycle Control**: Automatically calls [Dispose] on active widgets when 
///   switching routes to prevent memory leaks and state pollution.
/// 
/// ## Features
/// 
/// - **Z-Order Rendering**: Always draws the active overlay on top of the active page.
/// - **Automatic Sizing**: Scales the active widget and overlay to the [Window] 
///   dimensions if their sizing is set to [Grow].
/// - **Dynamic URI Switching**: Allows changing the current view via string-based identifiers.
/// 
/// ## Technical Implementation Note
/// 
/// This widget uses [WidgetBuilder] functions instead of direct instances. This allows 
/// each page to be freshly initialized upon entry, which is ideal for resetting state 
/// or passing new data through constructors.
/// 
/// ```dart
/// // Example usage:
/// var root = Page(
///   page: () => MainMenu(),
///   overlay: () => GameHUD()
/// );
/// root.routes['settings'] = () => SettingsScreen();
/// root.PutPage('settings'); // Disposes MainMenu and mounts SettingsScreen
/// ```
class Page extends Widget
{
  Map<String, WidgetBuilder> routes = {};
  Map<String, WidgetBuilder> overlays = {};
  Widget? _activeWidget;
  Widget? _activeOverlay;

  List<String> history = [];

  Page({ 
    required WidgetBuilder homePage,
    WidgetBuilder? overlay,
    Map<String, WidgetBuilder> route = const {}
  }) :
    routes = route,
    super(sizing: .Grow()) {
    width = Window.Width().toDouble();
    height = Window.Height().toDouble();

    routes['home/'] = homePage;
    _activeWidget = routes['home/']!.call();

    if (overlay != null)
      overlays = { "main/": overlay };
  }

  bool PutPage(String uri) {
    if (!routes.containsKey(uri))
      return false;

    _activeWidget?.Dispose();
    _activeWidget = routes[uri]!.call();

    Mount();
    return true;
  }

  bool PushPage(String uri) {
    if (history.length >= 8) return false;

    bool result = PutPage(uri);
    history.add(uri);

    return result;
  }

  bool PopPage() {
    if (history.length <= 1) return PutPage('home/');

    history.remove(history.last);
    bool result = PutPage(history.last);

    return result;
  }

  bool PutOverlay(String uri) {
    _activeOverlay?.Dispose();
    _activeOverlay = overlays[uri]!.call();

    Mount();
    return true;
  }
  
  @override void Mount() {
    _activeWidget?.SetSizing(width, height);
    _activeWidget?.Mount();

    _activeOverlay?.SetSizing(width, height);
    _activeOverlay?.Mount();

    super.Mount();
  }

  @override
  void DrawWidget() {
    _activeWidget?.DrawWidget();
    _activeOverlay?.DrawWidget();

    super.DrawWidget();
  }

  @override
  void Dispose() {
    _activeWidget?.Dispose();
    _activeOverlay?.Dispose();

    super.Dispose();
  }
}