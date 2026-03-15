import '../libs/raylib/raylib.dart';

/// # HayXAxisAlign Enum
/// 
/// Defines horizontal text and widget alignment options.
/// 
/// ## Purpose
/// 
/// The `HayXAxisAlign` enum specifies how widgets are aligned along the horizontal axis (cross-axis in layout):
/// - **LEFT**: Align to the left edge
/// - **CENTER**: Center horizontally
/// - **RIGHT**: Align to the right edge
/// 
/// ## Usage
/// 
/// ```dart
/// Column myColumn = Column(
///   sizing: HaySize.Grow(),
///   crossAxis: HayXAxisAlign.CENTER,  // Center children horizontally
///   children: [...]
/// );
/// 
/// Row myRow = Row(
///   sizing: HaySize.Grow(),
///   crossAxis: HayXAxisAlign.RIGHT,   // Align children to the right
///   children: [...]
/// );
/// 
/// TextBox myText = TextBox(
///   textAlign: HayXAxisAlign.LEFT,    // Left-align text
///   ...
/// );
/// ```
enum HayXAxisAlign {
  LEFT,
  RIGHT,
  CENTER
}

/// # HayYAxisAlign Enum
/// 
/// Defines vertical widget alignment options.
/// 
/// ## Purpose
/// 
/// The `HayYAxisAlign` enum specifies how widgets are aligned along the vertical axis (main-axis in layout):
/// - **TOP**: Align to the top edge
/// - **CENTER**: Center vertically
/// - **BOTTOM**: Align to the bottom edge
/// 
/// ## Usage
/// 
/// ```dart
/// Column myColumn = Column(
///   sizing: HaySize.Grow(),
///   mainAxis: HayYAxisAlign.CENTER,   // Center children vertically
///   children: [...]
/// );
/// 
/// Row myRow = Row(
///   sizing: HaySize.Grow(),
///   mainAxis: HayYAxisAlign.BOTTOM,   // Align children to the bottom
///   children: [...]
/// );
/// ```
enum HayYAxisAlign {
  TOP,
  CENTER,
  BOTTOM
}

/// # HaySize Parameter
/// 
/// Defines widget sizing with support for fixed and flexible dimensions.
/// 
/// ## Purpose
/// 
/// The `HaySize` parameter class controls how widgets are sized within the layout system:
/// - Specifies both width and height for a widget
/// - Supports fixed pixel values or dynamic expansion
/// - Provides convenient factory constructors for common sizing patterns
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
/// ## Purpose
/// 
/// The `HayPadding` parameter class manages empty space around widget content:
/// - Adds uniform or custom padding on all sides
/// - Supports symmetric padding for common use cases
/// - Provides individual control over each side (top, bottom, left, right)
/// 
/// ## Features
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
/// ## Features
/// 
/// - **Base Lifecycle**: Provides `Mount()` for initialization, `DrawWidget()` for rendering, and `Dispose()` for cleanup
/// - **Sizing Control**: Uses `HaySize` for flexible and fixed dimension specifications
/// - **Rectangle Foundation**: Inherits positioning (x, y) and dimension (width, height) properties from `Rectangle`
/// - **Extensibility**: Designed to be extended by all specialized widget types (layout, interactive, text, etc.)
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

  @override
  void Dispose() {
    super.Dispose();
  }
}


/// # Container Widget
/// 
/// A single-child widget that applies padding around its child widget.
/// 
/// ## Purpose
/// 
/// The `Container` widget wraps a single child widget and manages padding space around it:
/// - Applies uniform or custom padding on all sides
/// - Automatically positions and sizes the child widget based on available space
/// - Provides a simple way to add spacing around UI elements
/// 
/// ## Features
/// 
/// - **Flexible Padding**: Supports uniform, symmetric, or custom padding values
/// - **Child Sizing**: Automatically expands child to fill available space when configured
/// - **Cascading Layout**: Properly mounts child widgets in the layout hierarchy
/// 
/// ## Example
/// 
/// ```dart
/// Container myContainer = Container(
///   sizing: HaySize.FullWidth(heigth: 100),
///   padding: HayPadding.All(10),
///   child: MyWidget()
/// );
/// 
/// void main() {
///   Window.Init(width: 800, height: 600, title: "Container Example");
///   Canvas canvas = Canvas(800.0, 600.0);
///   canvas.AddWidgetToLayer([myContainer], "default", 1);
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
class Container extends Widget
{
  HayPadding padding;
  Widget? child;
  double get width => super.width - padding.left - padding.right;
  double get height => super.height - padding.bottom - padding.top;
  double get x => super.x - padding.left;
  double get y => super.y - padding.top;

  Container({
    required HaySize sizing, 
    Widget? this.child,
    HayPadding? padding,
  }) :
    padding = padding ?? HayPadding.All(),
    super(sizing: sizing);

  @override
  void Mount()
  {
    if (child == null)
      return;

    child!.y = super.y + padding.top;
    child!.x = super.x + padding.left;
    child!.width = (child!.sizing.width == -1) ? width : child!.width;
    child!.height = (child!.sizing.height == -1) ? height : child!.height;

    child!.Mount();
  }

  @override
  void DrawWidget() => child?.DrawWidget();

  @override
  void Dispose() {
    child?.Dispose();
    super.Dispose();
  }
}

/// # Column Widget
/// 
/// A layout widget that arranges child widgets vertically with customizable alignment and spacing.
/// 
/// ## Purpose
/// 
/// The `Column` widget stacks multiple child widgets vertically and provides control over their alignment:
/// - Arranges children in a vertical column
/// - Controls main axis (vertical) and cross axis (horizontal) alignment
/// - Adds customizable spacing between children
/// - Automatically handles child sizing and positioning
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
  }

  @override
  void Mount()
  {
    for (Widget widget in widgets) {
      if (widget.sizing.width == -1) widget.width = width;
      if (widget.sizing.height == -1) widget.height = height;
    }

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

      widgets[index].y = startY + index*(widgets[index].height + spacing);
    }

    for (Widget widget in widgets)
      widget.Mount();
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
/// ## Purpose
/// 
/// The `Row` widget places multiple child widgets side-by-side horizontally and provides control over their alignment:
/// - Arranges children in a horizontal row
/// - Controls main axis (horizontal) and cross axis (vertical) alignment
/// - Adds customizable spacing between children
/// - Automatically handles child sizing and positioning
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
  void DrawWidget()
  {
    for (Widget widget in widgets)
      widget.DrawWidget();
  }

  @override
  void Mount()
  {
    for (Widget widget in widgets) {
      if (widget.sizing.width == -1) widget.width = width; 
      if (widget.sizing.height == -1) widget.height = height;
    }

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
      
      widgets[index].x = startX + index*(widgets[index].width + spacing); 
    }

    for (Widget widget in widgets)
      widget.Mount();
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
/// - Supports horizontal text alignment (LEFT, CENTER, RIGHT)
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
    required this.font,
    required this.text,
    required this.textAlign,
    required this.fontSize,
    required this.spacing,
    Color? color
  }) :
    this.color = color ?? Color.WHITE,
    super(sizing: HaySize.Grow());

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
    Draw.BeginScissorMode(x.toInt(), y.toInt(), width.toInt(), height.toInt());

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

    Draw.EndScissorMode();
  }

  @override
  void Dispose() {
    font.Dispose();
    text.Dispose();

    super.Dispose();
  }
}

Interactible? _PinnedWidget;
Vector2 _MousePosition = Vector2.Zero();

/// # Interactible Widget
/// 
/// An interactive widget that responds to mouse input and collision detection.
/// 
/// ## Purpose
/// 
/// The `Interactible` widget is the base class for all interactive UI elements that respond to user input:
/// - Detects mouse position and collision with the widget area
/// - Manages press and release states for left and right mouse buttons
/// - Provides cursor feedback by changing the mouse cursor on hover
/// - Executes callbacks when the widget is interacted with
/// - Implements a "pinning" system to track which widget is currently being interacted with
/// 
/// ## Features
/// 
/// - **Mouse Detection**: Automatically detects when the mouse is over the widget using collision detection
/// - **State Tracking**: Maintains `selected` (hover) and `pressed` (click) states
/// - **Cursor Feedback**: Changes the mouse cursor to provide visual feedback (customizable via `cursor` parameter)
/// - **Click Callbacks**: Executes the `OnPress` callback when the widget is clicked
/// - **Global Input Tracking**: Uses static methods and variables to manage mouse position across all interactive widgets
/// 
/// ## Example
/// 
/// ```dart
/// // Create an interactive button widget
/// Interactible myButton = Interactible(
///   sizing: HaySize(width: 150, heigth: 50),
///   OnPress: () {
///     print("Button clicked!");
///   },
///   cursor: .POINTING_HAND
/// );
/// 
/// void main() {
///   Window.Init(width: 800, height: 600, title: "Interactive Widget Example");
///   Canvas canvas = Canvas(800.0, 600.0);
///   canvas.AddWidgetToLayer([myButton], "default", 1);
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
///   
///   // Update mouse position for interaction tracking
///   Interactible.SetMousePosition(Mouse.GetX(), Mouse.GetY());
///   
///   if (Window.IsResized()) canvas.Mount();
///   canvas.DrawWidget();
/// }
/// ```
class Interactible extends Widget
{
  static void SetMousePosition(int x, int y) {
    _MousePosition.Set(x.toDouble(), y.toDouble());
  } 

  void Function()? OnPress;

  bool selected = false;
  bool pressed = false;
  MouseCursor cursor;
  Interactible({required super.sizing, void Function()? OnPress, this.cursor = .POINTING_HAND}) :
    OnPress = OnPress;

  @override
  void DrawWidget() {
    // Custom Draw logic
    selected = false;
    Cursor.Set(.DEFAULT);

    // If the interacted widget is this, continue
    if (
      _PinnedWidget != null
      && this == _PinnedWidget
      && (Mouse.IsReleased(.LEFT) || Mouse.IsReleased(.RIGHT))
    ) {
      _PinnedWidget = null;
      pressed = false;

      return;
    }

    // Logic breaker
    if (!Collision.CheckPointRec(_MousePosition, this))
      return;
    
    selected = true;
    Cursor.Set(cursor);

    // If no widget is pinned
    if (
      _PinnedWidget == null
      && (Mouse.IsPressed(.LEFT) || Mouse.IsPressed(.RIGHT))
    ) {
      _PinnedWidget = this;
      pressed = true;
      OnPress?.call();

      return;
    }
  }
}

typedef Sheet = ({String layer, double scale, List<Widget> children});

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
        if (widget.sizing.width == -1) widget.width = width * sheet.scale;
        else widget.width = widget.sizing.width * sheet.scale;

        if (widget.sizing.height == -1) widget.height = height * sheet.scale;
        else widget.height = widget.sizing.height * sheet.scale;

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

      Draw.RenderTextureMode(
        render: renderTexture,
        renderLogic: () {
          Draw.ClearBackground(.BLANK);
          for (Widget widget in sheet.children)
            widget.DrawWidget();
        }
      );

      src.Set(width: renderWidth.toDouble(), height: -renderHeight.toDouble());
      Texture2D.DrawPro(renderTexture.texture, src, this);
    }

    Shapes.DrawCircle((width / 2).round(), (height / 2).round(), 10.0, color: .SKYBLUE);
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
    if (value <= 0.0) value = 1.0;
    _sensitivity = value;
  }

  List<Widget> widgets;

  Grid({
    required super.sizing,
    required this.cellSize,
    this.spacing = 0.0,
    List<Widget>? children
  }) :
    widgets = children ?? []
  {
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
  }

  
  @override
  void Mount() {
    for (Widget widget in widgets)
      widget.Set(width: cellSize.x, height: cellSize.y);
    
    // Determing start (visible) row to mount
    /*
    for (int row = (_scroll / _rowStride).floor(); row < _rows; row++) {
      for (int col = 0; col < _cols; col++) {
        int index = (row * _cols) + col;
        if (index > widgets.length) break;

        Widget widget = widgets[index];
        widget.Set(
          x: col * (cellSize.x + spacing),
          y: (_rowStride * row) - _scroll
        );
      }
    }
    */

    super.Mount();
  }

  @override
  void DrawWidget() {
    // Updating scoll on update
    Vector2 scroll = Mouse.GetWheelMoveV();
    _scroll += scroll.y * _sensitivity;
    final offset = _scroll.clamp(0.0, (_totalHeight - height).abs());

    // Drawing from the first visible row
    for (int row = (offset / _rowStride).floor(); row < _rows; row++) {
      for (int col = 0; col < _cols; col++) {
        int index = (row * _cols) + col;
        if (index > widgets.length) break;

        widgets[index].Set(
          x: super.x + col * _colStride,
          y: super.y + (row * _rowStride) - _scroll
        );

        widgets[index].DrawWidget();
      }
    }

    super.DrawWidget();
  }

  @override
  void Dispose() {
    for (Widget widget in widgets)
      widget.Dispose();
    
    super.Dispose();
  }
}