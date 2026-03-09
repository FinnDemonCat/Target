import '../libs/raylib/raylib.dart';

/// Column vertical axis aligment
enum HayXAxisAlign {
  LEFT,
  RIGHT,
  CENTER
}

/// Column horizontal axis aligment
enum HayYAxisAlign {
  TOP,
  CENTER,
  BOTTOM
}

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

class HayPadding
{
  double bottom, top, left, right;

  HayPadding.All([double value = 0])
    : bottom = value, top = value, left = value, right = value;

  HayPadding.BTLR([this.bottom = 0, this.top = 0, this.left = 0, this.right = 0]);

  HayPadding.Symetric([double vertical = 0, double horizontal = 0])
    : bottom = vertical, top = vertical, left = horizontal, right = horizontal;
}

///class Widget
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

class Column extends Widget
{
  HayYAxisAlign MainAxis;
  HayXAxisAlign CrossAxis;
  List<Widget> widgets;
  double spacing;

  Column({
    required HaySize sizing,
    List<Widget>? children,
    this.spacing = 0.0,
    HayYAxisAlign? mainAxis,
    HayXAxisAlign? crossAxis,
  }) : 
    widgets = children ?? [],
    MainAxis = mainAxis ?? HayYAxisAlign.TOP,
    CrossAxis = crossAxis ?? HayXAxisAlign.LEFT,
    super(sizing: sizing);

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
    if (widHeight > super.height) widHeight = super.height;

    switch(MainAxis)
    {
      case HayYAxisAlign.CENTER:
        startY = (super.height - widHeight) / 2;
        break;
      case HayYAxisAlign.BOTTOM:
        startY = super.height - widHeight;
        break;
      default:
        break;
    }
    
    for (int x = 0; x < widgets.length; x++)
    {
      switch (CrossAxis)
      {
        case HayXAxisAlign.CENTER:
          widgets[x].x = (super.width - widgets[x].width) / 2;
          widgets[x].x += super.x;
          break;
        case HayXAxisAlign.RIGHT:
          widgets[x].x = super.width - widgets[x].width;
          widgets[x].x += super.x;
          break;
        default:
          widgets[x].x = super.x;
          break;
      }

      widgets[x].y = startY + x*(widgets[x].height + spacing);
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

class Row extends Widget
{
  HayYAxisAlign MainAxis = HayYAxisAlign.TOP;
  HayXAxisAlign CrossAxis = HayXAxisAlign.LEFT;

  List<Widget> widgets;
  double spacing;

  Row({
    required HaySize sizing,
    List<Widget>? children,
    this.spacing = 0.0,
    HayYAxisAlign? main,
    HayXAxisAlign? cross,
    void Function()? callback
  }) :
    widgets = children ?? [],
    MainAxis = main ?? HayYAxisAlign.TOP,
    CrossAxis = cross ?? HayXAxisAlign.LEFT,
    super(sizing: sizing);

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
    if (widWidth > super.width) widWidth = super.width;

    double startX = super.x;

    switch(CrossAxis)
    {
      case HayXAxisAlign.CENTER:
        startX = (super.width - widWidth) / 2;
        break;
      case HayXAxisAlign.RIGHT:
        startX = super.width - widWidth;
        break;
      default:
        break;
    }

    for (int x = 0; x < widgets.length; x++)
    {
      switch(MainAxis)
      {
        case HayYAxisAlign.BOTTOM:
          widgets[x].y = super.height - widgets[x].height;
          widgets[x].y += super.y;
          break;
        case HayYAxisAlign.CENTER:
          widgets[x].y = (super.height - widgets[x].height) / 2;
          widgets[x].y += super.y;
          break;
        default:
          widgets[x].y = super.y;
          break;
      }
      
      widgets[x].x = startX + x*(widgets[x].width + spacing); 
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

// Area to display text
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

class Interactible extends Widget
{
  static void SetMousePosition(int x, int y) {
    _MousePosition.Set(x.toDouble(), y.toDouble());
  } 

  void Function()? OnPress;

  bool selected = false;
  bool pressed = false;
  Interactible({required super.sizing, void Function()? OnPress}) :
    OnPress = OnPress;

  @override
  void DrawWidget() {
    // Custom Draw logic
    selected = false;
    Cursor.Set(MouseCursor.DEFAULT);

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
    Cursor.Set(MouseCursor.POINTING_HAND);

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