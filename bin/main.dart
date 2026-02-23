// ignore: unused_import
import '../libs/raylib.dart';
int winWidth = 800;
int winHeight = 800;
List<Rectangle> rects = [];

void main()
{
  Window.Init(width: winWidth, height: winHeight, title: "Dart Test");
  Frame.SetTargetFPS(30);

  while(!Window.ShouldClose())
  {
    Draw.RenderFrame(renderLogic: DrawScreen);
  }
}

void DrawScreen()
{
  if (rects.isEmpty) {
    print("Reloading");
    rects.add(Rectangle(0, 0, 200, 50));
    rects.add(Rectangle(0, 0, 300, 75));
    rects.add(Rectangle(0, 0, 200, 50));
    rects.add(Rectangle(0, 0, 200, 50));
  }

  for (int x = 0; x < rects.length; x++) {
    rects[x].y = (winHeight - rects.fold(0, (x, y) => x + y.height)) / 2 + (x * (rects[x].height + 10));
    rects[x].x = (winWidth - rects[x].width) / 2;
    Shapes.DrawRectangleRounded(rects[x], 0.25, 1);
  }
  
  Draw.ClearBackground(Color.GOLD);
}
