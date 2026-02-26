import '../libs/raylib/raylib.dart';

///class Widget
class Widget extends Rectangle
{
  Widget([super.x = 0, super.y = 0, super.width = 0, super.height = 0]);
  void mount() {}
  void draw() {}
}

/// Column vertical axis aligment
enum HayYAxisAlign
{
  LEFT,
  RIGHT,
  CENTER
}

/// Column horizontal axis aligment
enum HayXAxisAlign
{
  TOP,
  CENTER,
  BOTTOM
}

class Columm extends Widget
{
  HayYAxisAlign mainAxis = HayYAxisAlign.LEFT;
  HayXAxisAlign horizontalAxis = HayXAxisAlign.TOP;
  List<Widget> widgets = [];
  int spacing = 10;

  Columm([super.x = 0, super.y = 0, super.width = 0, super.height = 0]);

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

    double widgetsH = widgets.fold(0, (x, y) => x + y.height);
    widgetsH += (widgets.length - 1) * spacing;

    switch(horizontalAxis)
    {
      case HayXAxisAlign.CENTER:
        startY = (super.height - widgetsH) / 2;
        break;
      case HayXAxisAlign.BOTTOM:
        startY = super.height - widgetsH;
        break;
      default:
        break;
    }
    
    for (int x = 0; x < widgets.length; x++)
    {
      switch (mainAxis)
      {
        case HayYAxisAlign.CENTER:
          widgets[x].x = (super.width - widgets[x].width) / 2;
          widgets[x].x += super.x;
          break;
        case HayYAxisAlign.RIGHT:
          widgets[x].x = super.width - widgets[x].width;
          break;
        default:
          widgets[x].x = super.x;
          break;
      }

      widgets[x].y = startY + (x * (widgets[x].height + spacing));
    }
  }
}