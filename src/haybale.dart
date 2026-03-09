import 'package:collection/collection.dart';
import '../libs/raylib/raylib.dart';

/// AI generated extension for double comparison
extension DoublePrecision on double {
  bool isApprox(double other, [double epsilon = 0.0001]) {
    return (this - other).abs() < epsilon;
  }
}

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
  final double width, heigth;

  static const double ExpandWidth = -1;
  static const double ExpandHeight = -1;

  const HaySize({required this.width, required this.heigth});
  const HaySize.Grow() : width = ExpandWidth, heigth = ExpandHeight;
  const HaySize.FullWidth({required this.heigth}) : width = ExpandWidth;
  const HaySize.FullHeight({required this.width}) : heigth = ExpandHeight;
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
    super(0.0, 0.0, sizing.width, sizing.heigth);

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
  double get heigth => super.heigth - padding.bottom - padding.top;
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
    child!.heigth = (child!.sizing.heigth == -1) ? heigth : child!.heigth;

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
      if (widget.sizing.heigth == -1) widget.heigth = heigth;
    }

    double startY = super.y;

    double widHeight = widgets.fold(0, (x, y) => x + y.heigth);
    widHeight += (widgets.length - 1) * spacing;
    if (widHeight > heigth) widHeight = heigth;

    switch(MainAxis)
    {
      case HayYAxisAlign.CENTER:
        startY = (heigth - widHeight) / 2;
        break;
      case HayYAxisAlign.BOTTOM:
        startY = heigth - widHeight;
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

      widgets[index].y = startY + index*(widgets[index].heigth + spacing);
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
      if (widget.sizing.heigth == -1) widget.heigth = heigth;
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
          widgets[index].y = heigth - widgets[index].heigth;
          widgets[index].y += y;
          break;
        case HayYAxisAlign.CENTER:
          widgets[index].y = (heigth - widgets[index].heigth) / 2;
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
      } else if (textHeight > heigth) {
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
    Draw.BeginScissorMode(x.toInt(), y.toInt(), width.toInt(), heigth.toInt());

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

typedef _Sheet = ({String layer, double scale, List<Widget> children});
class Canvas extends Widget
{
  List<_Sheet> _sheets = [];
  List<_Sheet> get sheets => _sheets;
  RenderTexture frame;

  double get width => frame.width.toDouble();
  double get heigth => frame.heigth.toDouble();

  void AddWidgetToLayer(List<Widget> widgets, [String layer = "default", double scale = 1.0]) {
    _Sheet? page = _sheets.firstWhereOrNull((record) => record.layer == layer);
    if (page == null) {
      page = (layer: layer, scale: scale, children: []);
      _sheets.add(page);
    }

    page.children.addAll(widgets);
  }

  Canvas(double width, double height) :
    frame = RenderTexture(width.toInt(), height.toInt()),
    super(sizing: HaySize(width: width, heigth: height));

  @override
  void Mount() {
    super.width = Window.Width().toDouble();
    super.heigth = Window.Height().toDouble();

    for (int index = 0; index < _sheets.length; index++) {
      _Sheet sheet = _sheets[index];

      for (int offset = 0; offset < sheet.children.length; offset++) {
        Widget widget = sheet.children[offset];

        if (widget.sizing.width == -1) widget.width = super.width * sheet.scale;
        else widget.width = widget.sizing.width * sheet.scale;

        if (widget.sizing.heigth == -1) widget.heigth = super.heigth * sheet.scale;
        else widget.heigth = widget.sizing.heigth * sheet.scale;

        widget.Mount();
      }
    }
    super.Mount();
  }

  @override
  void DrawWidget () {
    Rectangle normal = Rectangle();

    for (int index = 0; index < _sheets.length; index++) {
      _Sheet sheet = _sheets[index]; 
      double scale = sheet.scale;

      if (
          frame.width != (super.width * scale).round()
          || frame.heigth != (super.heigth * scale).round()
      ) {
        frame.Dispose();
        int newWidth = (super.width * scale).round();
        int newHeigth = (super.heigth * scale).round();

        frame = RenderTexture(newWidth, newHeigth);
      }

      Draw.BeginTextureMode(frame);
        Draw.ClearBackground(.BLANK);
        for (Widget widget in sheet.children)
          widget.DrawWidget();
      Draw.EndTextureMode();

      normal.Set(0, 0, frame.width.toDouble(), -frame.heigth.toDouble());
      Texture2D.DrawPro(frame.texture, normal, this);
    }

    normal.Dispose();
    super.DrawWidget();
  }

  @override
  void Dispose() {
    for (_Sheet page in _sheets)
      for (Widget widget in page.children)
        widget.Dispose();

    super.Dispose();
  }
}