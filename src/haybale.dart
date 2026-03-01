import '../libs/raylib/raylib.dart';

///class Widget
class Widget extends Rectangle
{
  Widget({
    double width = 0.0,
    double height = 0.0,
  }) :
    super(0.0, 0.0, width, height);

  void mount() {}
  void draw() {}

  @override
  void dispose() {
    super.dispose();
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

class HayPadding
{
  double bottom, top, left, right;

  HayPadding.All([double value = 0])
    : bottom = value, top = value, left = value, right = value;

  HayPadding.BTLR([this.bottom = 0, this.top = 0, this.left = 0, this.right = 0]);

  HayPadding.Symetric([double vertical = 0, double horizontal = 0])
    : bottom = vertical, top = vertical, left = horizontal, right = horizontal;
}

class Container extends Widget
{
  HayPadding padding;
  Widget? child;
  double get width => super.width - padding.left - padding.right;
  double get height => super.height - padding.bottom - padding.top;

  Container({
    required double width,
    required double height, 
    Widget? this.child,
    HayPadding? padding,
  }) :
    padding = padding ?? HayPadding.All(),
    super(width: width, height: height);

  @override
  void mount()
  {
    if (child == null)
      return;

    child!.y = super.y + padding.top;
    child!.x = super.x + padding.left;

    child!.mount();
  }

  @override
  void draw() => child?.draw();

  @override
  void dispose() {
    child?.dispose();
    super.dispose();
  }
}

class Column extends Widget
{
  HayYAxisAlign MainAxis;
  HayXAxisAlign CrossAxis;
  List<Widget> widgets;
  double spacing;

  Column({
    required double width,
    required double height, 
    List<Widget>? children,
    this.spacing = 0.0,
    HayYAxisAlign? main,
    HayXAxisAlign? cross,
    void Function()? callback
  }) : 
    widgets = children ?? [],
    MainAxis = main ?? HayYAxisAlign.TOP,
    CrossAxis = cross ?? HayXAxisAlign.LEFT,
    super(width: width, height: height);

  @override
  void draw()
  {
    Shapes.DrawRectangleLines(x.round(), y.round(), width.round(), height.round());

    for (Widget widget in widgets)
      widget.draw();
  }

  @override
  void mount()
  {
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
      widget.mount();
  }

  @override
  void dispose() {
    for (Widget widget in widgets)
      widget.dispose();
    
    super.dispose();
  }
}

class Row extends Widget
{
  HayYAxisAlign MainAxis = HayYAxisAlign.TOP;
  HayXAxisAlign CrossAxis = HayXAxisAlign.LEFT;

  List<Widget> widgets;
  double spacing;

  Row({
    required double width,
    required double height, 
    List<Widget>? children,
    this.spacing = 0.0,
    HayYAxisAlign? main,
    HayXAxisAlign? cross,
    void Function()? callback
  }) :
    widgets = children ?? [],
    MainAxis = main ?? HayYAxisAlign.TOP,
    CrossAxis = cross ?? HayXAxisAlign.LEFT,
    super(width: width, height: height);

  @override
  void draw()
  {
    for (Widget widget in widgets)
      widget.draw();
  }

  @override
  void mount()
  {
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
      widget.mount();
  }

  @override
  void dispose() {
    for (Widget widget in widgets)
      widget.dispose();
    
    super.dispose();
  }
}